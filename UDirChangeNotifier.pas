{$I Directives.inc}

unit UDirChangeNotifier;

interface

uses
  Windows, SysUtils, Classes;

type
  TDirChangeNotifier = class;

  { Liste des notifications possibles }
  TDirChangeNotification = (dcnFileAdd, dcnFileRemove, dcnRenameFile,
   dcnRenameDir, dcnModified, dcnLastWrite, dcnLastAccess,
   dcnCreationTime);
  TDirChangeNotifications = set of TDirChangeNotification;

  { Evenement de notification de changement }
  TDirChangeEvent = procedure (Sender: TDirChangeNotifier;
   const FileName, OtherFileName: WideString;
   Action: TDirChangeNotification) of object;

  TDirChangeNotifier = class(TThread)
  private
    { Dossier à surveiller }
    FDir: WideString;
    { Handle du dossier }
    FDirHandle: THandle;
    { Liste dee notifications }
    FNotifList: TDirChangeNotifications;
    { Evenement de fin }
    FTermEvent: THandle;
    { Structure d'attente de notification }
    FOverlapped: TOverlapped;
    { Evenement }
    FOnChange: TDirChangeEvent;
    FFileName: WideString;
    FOtherFileName: WideString;
    FAction: TDirChangeNotification;
  protected
    function WhichAttrChanged(const AFileName: WideString): TDirChangeNotification;
    procedure Execute; override;
    procedure DoChange;
  public
    constructor Create(const ADirectory: WideString;
     WantedNotifications: TDirChangeNotifications);
    destructor Destroy; override;
    procedure Terminate; reintroduce;
    property OnChange: TDirChangeEvent read FOnChange write FOnChange;
  end;

const
  { Constantes pour CreateFile()  }
  FILE_LIST_DIRECTORY = $0001;
  FILE_READ_ATTRIBUTES = $0080;

  { Liste des notifications }
  CNotificationFilters: array[TDirChangeNotification] of Cardinal = (0, 0,
   FILE_NOTIFY_CHANGE_FILE_NAME,
   FILE_NOTIFY_CHANGE_DIR_NAME,
   FILE_NOTIFY_CHANGE_SIZE,
   FILE_NOTIFY_CHANGE_LAST_WRITE,
   FILE_NOTIFY_CHANGE_LAST_ACCESS,
   FILE_NOTIFY_CHANGE_CREATION);

  { Constante de toutes les notifications }
  CAllNotifications: TDirChangeNotifications = [dcnFileAdd, dcnFileRemove,
   dcnRenameFile, dcnRenameDir, dcnModified, dcnLastWrite,
   dcnLastAccess, dcnCreationTime];

implementation

constructor TDirChangeNotifier.Create(const ADirectory: WideString;
 WantedNotifications: TDirChangeNotifications);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FDir := ExcludeTrailingPathDelimiter(ADirectory);
  FNotifList := WantedNotifications;
end;

destructor TDirChangeNotifier.Destroy;
begin
  //
  inherited Destroy;
end;

function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
  SysTime: TSystemTime;
  TimeZoneInfo: TTimeZoneInformation;
  Bias: Double;
begin
  FileTimeToSystemTime(FileTime, SysTime);
  GetTimeZoneInformation(TimeZoneInfo);
  Bias := TimeZoneInfo.Bias / 1440; // = 60 * 24
  Result := SystemTimeToDateTime(SysTime) - Bias;
end;

function TDirChangeNotifier.WhichAttrChanged(const AFileName: WideString):
  TDirChangeNotification;
var
  hFile: THandle;
  FCreation, FModification, FAccess: TFileTime;
  Creation, Modification, Access: TDateTime;
begin
  {>> Lecture des dates du fichier et conversion en TDateTime }
  hFile := CreateFileW(PWideChar(AFileName), FILE_READ_ATTRIBUTES,
    FILE_SHARE_READ or FILE_SHARE_DELETE or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, 0, 0);

  {>> Y'a des fichiers que Windows modifie mais qu'on ne peut pas lire ... }
  if hFile = 0 then
  begin
    Result := dcnModified;
    Exit;
  end;

  GetFileTime(hFile, @FCreation, @FAccess, @FModification);
  Creation := FileTimeToDateTime(FCreation);
  Access := FileTimeToDateTime(FAccess);
  Modification := FileTimeToDateTime(FModification);

  {>> Détermine l'heure la plus proche du temps actuel
  (moins de 20 secondes de décalage sinon on considère que ce n'est
  pas l'heure qui a déclenché l'évenement) }
  if Now - Access <= 20.0 then
    Result := dcnLastAccess
  else if Now - Modification <= 20.0 then
    Result := dcnLastWrite
  else if Now - Creation <= 20.0 then
    Result := dcnCreationTime

  {>> Sinon, on considère que c'est la taille du fichier, donc que celui-ci à
  été modifié }
  else
    Result := dcnModified;

  {>> Libère le fichier }
  CloseHandle(hFile);
end;

procedure TDirChangeNotifier.Execute;
var
  Buffer: array[0..4095] of Byte;
  BytesReturned: Cardinal;
  WaitHandles: array[0..1] of THandle;
  NotifyFilter, I, Next, Action, FileNameLength: Cardinal;
  FileName: WideString;
  FmtSettings: TFormatSettings;
  N: TDirChangeNotification;
begin
  {>> Création des évenements }
  FTermEvent := CreateEvent(nil, True, False, nil);
  FillChar(FOverlapped, SizeOf(TOverlapped), 0);
  FOverlapped.hEvent := CreateEvent(nil, True, False, nil);

  {>> Ouverture du dossier }
  FDirHandle := CreateFileW(PWideChar(FDir), FILE_LIST_DIRECTORY,
    FILE_SHARE_READ or FILE_SHARE_DELETE or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);

  {>> Création du tableau de handles }
  WaitHandles[0] := FTermEvent;
  WaitHandles[1] := FOverlapped.hEvent;
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT, FmtSettings);

  {>> Création du filtre }
  NotifyFilter := 0;
  for N := Low(TDirChangeNotification) to High(TDirChangeNotification) do
    if N in FNotifList then
      Inc(NotifyFilter, CNotificationFilters[N]);
    
  {>> Boucle du thread }
  while True do
  begin
    {>> Demande de lecture des évenements du dossier }
    ReadDirectoryChangesW(FDirHandle, @Buffer, SizeOf(Buffer), True,
     NotifyFilter, nil, @FOverlapped, nil);

    {>> Attente de qqch ou de la fin }
    if WaitForMultipleObjects(2, @WaitHandles, False,
      INFINITE) = WAIT_OBJECT_0 then
      Break;

    {>> Récupération du nombre d'octets reçus }
    GetOverlappedResult(FDirHandle, FOverlapped, BytesReturned, False);

    {>> Lecture du buffer }
    I := 0;
    repeat
      {>> Offset vers le suivant }
      Move(Buffer[I], Next, 4);

      {>> Action effectuée }
      Move(Buffer[I + 4], Action, 4);

      {>> Transcription de Action en FAction }
      case Action of
        FILE_ACTION_ADDED: FAction := dcnFileAdd;
        FILE_ACTION_REMOVED: FAction := dcnFileRemove;
        FILE_ACTION_MODIFIED: FAction := dcnModified;
        // Ici: on suppose qu'il s'agit d'un fichier
        FILE_ACTION_RENAMED_OLD_NAME,
        FILE_ACTION_RENAMED_NEW_NAME: FAction := dcnRenameFile;
      end;

      {>> Nom de fichier }
      Move(Buffer[I + 8], FileNameLength, 4);
      { "div 2" car Delphi et windows ne gèrent pas la taille des WideString
      de la même manière. Pour delphi, c'est le nombre de caractères,
      pour windows, c'est la taille en octets }
      SetLength(FileName, FileNameLength div 2);
      Move(Buffer[I + 12], FileName[1], FileNameLength);

      {>> Regarde si c'est vraiment la taille ou bien les dates du fichier car
      la notification générée est la même :-( }
      if (FAction = dcnModified) and FileExists(FDir + '\' + FileName) then
        FAction := WhichAttrChanged(FDir + '\' + FileName);

      {>> Choix du nom de fichier à remplir }
      if Action = FILE_ACTION_RENAMED_NEW_NAME then
      begin
        FOtherFileName := FDir + '\' + FileName;
        if DirectoryExists(FOtherFileName) then
          FAction := dcnRenameDir;
      end
      else
      begin
        FFileName := FDir + '\' + FileName;
        FOtherFileName := '';
      end;

      {>> Notification si besoin }
      if (Action <> FILE_ACTION_RENAMED_OLD_NAME)
      and (FAction in FNotifList) then
        Synchronize(DoChange);

      {>> Passe au suivant }
      Inc(I, Next);

    until Next = 0;
  end;

  {>> Libération des évenements }
  CloseHandle(FTermEvent);
  FTermEvent := 0;
  CloseHandle(FOverlapped.hEvent);

  {>> Fermeture du dossier }
  CloseHandle(FDirHandle);
end;

procedure TDirChangeNotifier.Terminate;
begin
  if FTermEvent <> 0 then
    SetEvent(FTermEvent);
end;

procedure TDirChangeNotifier.DoChange;
begin
  if Assigned(FOnChange) then
     FOnChange(Self, FFileName, FOtherFileName, FAction);
end;

end.
