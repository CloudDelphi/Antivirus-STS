unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ImgList, shellapi,
  DCPblockciphers, DCPrijndael, DCPsha512, DCPcrypt2,
  UDirChangeNotifier,
  sts_processlist,
  TLHelp32,
  TcpIpHlp,
  ComObj,
  Wininet,
  Winsock,
  ActiveX,
  sts_lib, CoolTrayIcon, Menus, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, ExtCtrls;

CONST
  WM_ASYNCSELECT = WM_USER + 1;

type
  TAsyncEvent  = procedure (Sender: TObject; Socket: TSocket) of object;
  TMainForm = class(TForm)
    CloseBtn: TButton;
    ScanBtn: TButton;
    StopBtn: TButton;
    BackBtn: TButton;
    Pages: TPageControl;
    SelectPathTab: TTabSheet;
    ScanProcessTab: TTabSheet;
    ClearResults: TCheckBox;
    ScanProcess: TEdit;
    ScanView: TListView;
    PathView: TTreeView;
    DriveImages: TImageList;
    ReportImages: TImageList;
    DBLabel: TLabel;
    LoadedLabel: TLabel;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    SB: TStatusBar;
    rb1: TRadioButton;
    rb2: TRadioButton;
    CoolTrayIcon1: TCoolTrayIcon;
    pm1: TPopupMenu;
    sClose: TMenuItem;
    IdHTTP1: TIdHTTP;
    TabSheet3: TTabSheet;
    ProgressBar1: TProgressBar;
    updprg: TButton;
    TabSheet2: TTabSheet;
    grp4: TGroupBox;
    TopLabel: TLabel;
    grp5: TGroupBox;
    mmo1: TMemo;
    LogMemo: TMemo;
    ALabel: TLabel;
    InterfaceComboBox: TComboBox;
    startx: TButton;
    FileCheckBox: TCheckBox;
    TabSheet4: TTabSheet;
    lst1: TListBox;
    svlog: TCheckBox;
    tmr1: TTimer;
    function KillProcess(ProcCapt: String): boolean;
    procedure FormCreate(Sender: TObject);
    procedure PathViewExpanded(Sender: TObject; Node: TTreeNode);
    procedure PathViewCollapsed(Sender: TObject; Node: TTreeNode);
    procedure ScanBtnClick(Sender: TObject);
    procedure BackBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure PathViewChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure FindFileDecrypt(Dir:String);
    procedure FindFileEncrypt(Dir:String);
    procedure FindFileEncryptdb(Dir:String);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure sCloseClick(Sender: TObject);
    function tictac(i: Integer; tc: Integer) : string;
    procedure updprgClick(Sender: TObject);
    procedure startxClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  protected
    procedure WMASyncSelect(var msg: TMessage); message WM_ASYNCSELECT;
  private
    tk: Integer;
    ScanFile: string;
    FSocket: TSocket;
    FLogOpen: Boolean;
    FLogFile: Textfile;
    FLogName: String;
    FLogInProgress: Boolean;
    FAsyncWrite:   TAsyncEvent;
    FAsyncOOB:     TAsyncEvent;
    FAsyncAccept:  TAsyncEvent;
    FAsyncConnect: TAsyncEvent;
    FAsyncClose:   TAsyncEvent;
    FChangeThread: TDirChangeNotifier;    
    procedure Log(s: String);
    function  StartLogging: Boolean;
    function  StopLogging: String;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure SthChange(Sender: TDirChangeNotifier; const FileName,
     OtherFileName: WideString; Action: TDirChangeNotification);
    procedure ThreadTerminated(Sender: TObject);
    procedure ThreadStart(Sender: TObject);
    function isInternetConnection: Boolean;
  public
    FAsyncRead:    TAsyncEvent;  
    //Driver
    hDriver,hDrv: THandle;
    TrId: Cardinal;
    access: Boolean;
    PrtCode: cardinal;
    /////////////////
    function UnloadDriver(dName: PChar): boolean;
    function InstallSecurityUsers(drName: PChar; dType: dword): boolean;
    procedure AddLogStr(LogString: String);
    procedure AddInterface(value: String; iff_types: Integer);
    procedure HandleData(Sender: TObject; Socket: TSocket);
  end;

type
PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
end;

type
  TArrayOfString = array of String;

const
  SubKey: string = '\SOFTWARE\Microsoft\Windows NT';  

const
  DrvName = 'STS';  

const
  PROTECT_OK = $00FE;
  PROTECT_ERROR = $011F;
  DrvReg = '\registry\machine\system\CurrentControlSet\Services\';
  Driver = '\registry\machine\system\CurrentControlSet\Services\Stalker';

procedure RtlInitUnicodeString(DestinationString: PUnicodeString;
                               SourceString: PWideChar);
                                stdcall; external 'ntdll.dll';
function ZwLoadDriver(DriverServiceName: PUnicodeString): cardinal;
                  stdcall;external 'ntdll.dll';

function ZwUnloadDriver(DriverServiceName: PUnicodeString): cardinal;
                  stdcall;external 'ntdll.dll';
function ZwSetInformationProcess(cs1: THandle; cs2: ULONG; cs3: Pointer;
         cs4: ULONG): ULONG; stdcall; external 'ntdll.dll';

var
    MainForm: TMainForm;
    engine: psts_engine;
    unarchfl, scanfile, sdsk: string;
    stopped: boolean = true;
    statth: Boolean;
    scanned, infected: integer;
    path: string = '';
    indx,indy: Integer;
    TMPF: TStringList;
    Buf: array[0..255] of Char;
    //SNIFFER//
    WarnedAboutW2k: Boolean = FALSE;
    //////////
    TMPHack     : TStringList;
    TMP1,TMP2   : TStringList;
    KeyRelease:string = 'DJFDKSFghjyg;KH9bn6CRTXCx4hUGLB.8.nkVTJ6FJfjylk7gl7GLUHm'+
                        'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                        'gnkBkL1om4XbALjhgkk7sDkJ2_8JvYmWFn LR3CRxyfswstoPp5DkJ2_8JvYmWFn_LR3CRxyf'+
                        'Go0NLL1om23;d923NrUdkzkk7sda823r23;d923NrUdkzPp5DkJ2_8JvYmWFn_LR3CRxyfsws'+
                        'cvnkscv78h2lk8HHKhlkjdfvsd;vlkvsd0vvds;ldvhyB[NXzl5y5Z';

    
implementation

uses uMessage;

///////////////////////////////////////////////////////

function InstallDriver(drName, drPath: PChar): boolean;
var
 Key, Key2: HKEY;              
 dType: dword;
 Err: dword;
 NtPath: array[0..MAX_PATH] of Char;
begin
 Result := false;
 dType := 1;
 Err := RegOpenKeyA(HKEY_LOCAL_MACHINE, 'system\CurrentControlSet\Services', Key);
 if Err = ERROR_SUCCESS then
   begin
    Err := RegCreateKeyA(Key, drName, Key2);
    if Err <> ERROR_SUCCESS then Err := RegOpenKeyA(Key, drName, Key2);
    if Err = ERROR_SUCCESS then
      begin
       lstrcpy(NtPath, PChar('\??\' + drPath));
       RegSetValueExA(Key2, 'ImagePath', 0, REG_SZ, @NtPath, lstrlen(NtPath));
       RegSetValueExA(Key2, 'Type', 0, REG_DWORD, @dType, SizeOf(dword));
       RegCloseKey(Key2);
       Result := true;
      end;
    RegCloseKey(Key);
   end;
end;

//if InstallSecurityUsers('UseLogonCredential',0) then
function TMainForm.InstallSecurityUsers(drName: PChar; dType: dword): boolean;
var
 Key, Key2: HKEY;              
 Err: dword;
begin
 Result := false;
 Err := RegOpenKeyA(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\SecurityProviders', Key);
 if Err = ERROR_SUCCESS then
   begin
    Err := RegCreateKeyA(Key, 'WDigest', Key2);
    if Err <> ERROR_SUCCESS then Err := RegOpenKeyA(Key, drName, Key2);
    if Err = ERROR_SUCCESS then
      begin
       RegSetValueExA(Key2, drName, 0, REG_DWORD, @dType, SizeOf(dword));
       RegCloseKey(Key2);
       Result := true;
      end;
    RegCloseKey(Key);
   end;
end;

function TMainForm.tictac(i: Integer; tc: Integer) : string;
const
  s = '. ';
  s1 = '.. ';
  s2 = '... ';
  s3 = '.... ';
begin
  if i = 5 then Result := s;
  if i = 4 then Result := s1;
  if i = 3 then Result := s2;
  if i = 2 then Result := s3;
  if i <= 1 then Result := '. ';
  sleep(tc);
  Application.ProcessMessages;
end;

function UninstallDriver(drName: PChar): boolean;
var
 Key: HKEY;
begin
  Result := false;
  if RegOpenKeyA(HKEY_LOCAL_MACHINE, 'system\CurrentControlSet\Services', Key) = ERROR_SUCCESS then
    begin
      RegDeleteKey(Key, PChar(drName+'\Enum'));
      RegDeleteKey(Key, PChar(drName+'\Security'));
      Result := RegDeleteKey(Key, drName) = ERROR_SUCCESS;
      RegCloseKey(Key);
    end;
end;

function LoadDriver(dName: PChar): boolean;
var
 Image: TUnicodeString;
 Buff: array [0..MAX_PATH] of WideChar;
begin
  StringToWideChar(DrvReg + dName, Buff, MAX_PATH);
  RtlInitUnicodeString(@Image, Buff);
  Result := ZwLoadDriver(@Image) = 0;
end;

function TMainForm.UnloadDriver(dName: PChar): boolean;
var
 Image: TUnicodeString;
 Buff: array [0..MAX_PATH] of WideChar;
begin
  StringToWideChar(DrvReg + dName, Buff, MAX_PATH);
  RtlInitUnicodeString(@Image, Buff);
  Result := ZwUnloadDriver(@Image) = 0;
end;

//Правильный выход с программы при перезагрузке Винды
procedure TMainForm.WMQueryEndSession(var Message: TMessage);
begin
   Message.Result := 1;
if access = false then Begin
   access := True;
   DeviceIoControl(hDriver, Cardinal(4), nil, 0, nil, 0, TrId, nil);
   UnloadDriver(Driver);
end;
   Application.Terminate;
end;

///////////////////UPDATER/////////////////////////////
function TMainForm.isInternetConnection: Boolean;
begin
  try
    IdHTTP1.Get('http://www.google.com');
  except
    Result := False;
    Exit;
  end;
  Result := True;
end;

function HttpQueryInfoW(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  lpdwReserved: pointer): BOOL; stdcall;
    external 'wininet.dll' name 'HttpQueryInfoW';

function SizeQuery(hRequest: pointer; out Size : cardinal): boolean;
var
  RSize  : cardinal;
begin
  RSize  := 4;
  result := HttpQueryInfoW(hRequest,
    HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,
    @Size, RSize, nil);
  if NOT result then Size := 0;
end;

function GetUrlSize(const URL:string):Integer;
var
  hSession,hFile:hInternet;
  dwBuffer:array[1..20] of Char;
  dwBufferLen,dwIndex:DWORD;
begin
  Result:=0;
  hSession:=InternetOpen('GetUrlSize',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if Assigned(hSession) then begin
    hFile:=InternetOpenURL(hSession,PChar(URL),nil,0,
                           INTERNET_FLAG_RELOAD,0);
    dwIndex:=0;dwBufferLen:=20;
    if HttpQueryInfo(hFile,HTTP_QUERY_CONTENT_LENGTH,
                     @dwBuffer,dwBufferLen,dwIndex)
    then Result:=StrToInt(StrPas(@dwBuffer));
    if Assigned(hFile) then InternetCloseHandle(hFile);
    InternetCloseHandle(hsession);
  end;
end;

//GetUrlInfo(HTTP_QUERY_CONTENT_LENGTH, 'http://some.com/some.zip');
function GetUrlInfo(const dwInfoLevel: DWORD; const FileURL: string):
string;
var
hSession, hFile: hInternet;
dwBuffer: Pointer;
dwBufferLen, dwIndex: DWORD;
begin
Result := '';
hSession := InternetOpen('Download',
INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
if Assigned(hSession) then begin
hFile := InternetOpenURL(hSession, PChar(FileURL), nil, 0,
INTERNET_FLAG_RELOAD, 0);
dwIndex := 0;
dwBufferLen := 20;
if HttpQueryInfo(hFile, dwInfoLevel, @dwBuffer, dwBufferLen, dwIndex)
then Result := PChar(@dwBuffer);
if Assigned(hFile) then InternetCloseHandle(hFile);
InternetCloseHandle(hsession);
end;
end;

function GetInetFile(const fileURL, FileName: string): boolean;
const
  BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  fSize: Cardinal;
  f: file;
  sAppName: string;
begin
  sAppName := ExtractFileName(Application.ExeName);
  hSession := InternetOpen(PChar(sAppName),
  INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0, 0, 0);
    InternetQueryDataAvailable(hURL, fSize,0,0);
    MainForm.ProgressBar1.Max:=fSize;
    MainForm.ProgressBar1.Position:=0;
    try
      AssignFile(f, FileName);
      Rewrite(f,1);
      repeat
      if ExtractFileName(FileName) = 'DataBase.sts.crypt.new' then MainForm.ProgressBar1.Max:=157000;
        InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        BlockWrite(f, Buffer, BufferLen);
        Application.ProcessMessages;
        MainForm.ProgressBar1.StepBy(BufferLen);
      until BufferLen = 0;
      if ExtractFileName(FileName) = 'DataBase.sts.crypt.new' then MainForm.ProgressBar1.Position:=157000;
      CloseFile(f);
      Result := True;
    finally
      InternetCloseHandle(hURL);
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;

//Парсинг XML
function Pars(T_, ForS, _T: string): string;
var
  a, b: integer;
begin
  Result := ''; // обнуляем результат
  if (T_ = '') or (ForS = '') or (_T = '') then
    Exit; // если параметры пусты, то выходим
  a := Pos(T_, ForS); // ищем заданный параметр T_ в строке ForS
  if a = 0 then // если не нашли, то
    Exit // выходим
  else // иначе
    a := a + Length(T_); // а=а+длина T_
  ForS := Copy(ForS, a, Length(ForS) - a + 1); // ForS = копируем из ForS начиная с символа а символов длина Fors - a + 1
  b := Pos(_T, ForS); // ищем 2ую часть
  if b > 0 then // если нашли, то
    Result := Copy(ForS, 1, b - 1); // результат функции равен копированию из ForS начиная с индекса 1 символов b - 1
// получается, что функция просто обрезает всё, что до параметра T_ и параметр T_, и параметр _T и всё, что после него
end;

procedure UpdMine;
var
  i,y,x: Integer;
  s: string;
  p1,p2,p3: Word;
begin
  TMP1:= TStringList.Create;
  TMP2:= TStringList.Create;
  MainForm.AddLogStr('Обновление AntiMine blacklist ...');
  if GetInetFile('https://github.com/keraf/NoCoin/blob/master/src/blacklist.txt','blacklist.txt') then begin
  MainForm.AddLogStr('Загрузка защиты AntiMine blacklist ... OK');
  if FileExists('blacklist.txt') then
     TMP1.LoadFromFile('blacklist.txt');
  y:=1;
  for i:=0 to TMP1.Count-1 do begin
      s:=TMP1.Strings[i];
      x:=Pos('LC'+IntToStr(y),s);
      if x > 0 then begin
      s:=Pars('<td id="LC'+IntToStr(y)+'" class="blob-code blob-code-inner js-file-line">',s,'</td>');
      x:=Length(s);
      p1:=pos('//',s);
      p2:=pos('*.',s);
      p3:=pos('*/*',s);
      if p3 > 0 then
         s:=Copy(s,p3+3,x-1)
      else   
      if p2 > 0 then
         s:=Copy(s,p2+2,x-1)
      else   
      if p1 > 0 then
         s:=Copy(s,p1+2,x-1);
         p1:=pos('/*',s);
      if p1 > 0 then begin
         s:=Copy(s,1,p1-1);
         TMP2.Add(s);
      end else begin
         p1:=pos('*',s);
      if p1 > 0 then
         s:=Copy(s,1,p1-1);
         TMP2.Add(s);
      end;
      y:=y+1;
      end;
  end;
  TMP2.SaveToFile('BlackList.txt');
  end else begin
  MainForm.AddLogStr('Загрузка защиты AntiMine blacklist ... ERROR');
  Exit;
  end;
  TMP1.Free;
  TMP2.Free;
  if FileExists('blacklist.txt') then DeleteFile('blacklist.txt');
end;


function Mince(PathToMince: String; InSpace: Integer): String;
{=========================================================} 
// "C:\Program Files\Delphi\DDrop\TargetDemo\main.pas"
// "C:\Program Files\..\main.pas"
Var 
  sl: TStringList; 
  sHelp, sFile: String; 
  iPos: Integer;

begin 
  sHelp := PathToMince; 
  iPos := Pos('\', sHelp); 
  If iPos = 0 Then 
  begin 
    Result := PathToMince; 
  end 
  Else
  begin 
    sl := TStringList.Create; 
    // Decode string 
    While iPos <> 0 Do 
    begin 
      sl.Add(Copy(sHelp, 1, (iPos - 1))); 
      sHelp := Copy(sHelp, (iPos + 1), Length(sHelp)); 
      iPos := Pos('\', sHelp); 
    end; 
    If sHelp <> '' Then 
    begin 
      sl.Add(sHelp); 
    end; 
    // Encode string 
    sFile := sl[sl.Count - 1]; 
    sl.Delete(sl.Count - 1); 
    Result := ''; 
    While (Length(Result + sFile) < InSpace) And (sl.Count <> 0) Do 
    begin 
      Result := Result + sl[0] + '\'; 
      sl.Delete(0); 
    end; 
    If sl.Count = 0 Then 
    begin 
      Result := Result + sFile; 
    end 
    Else 
    begin 
      Result := Result + '..\' + sFile; 
    end; 
    sl.Free; 
  end; 
end;

(* -------------------------------------------------------------------------- *)
function DiskInDrive(const Drive: char): Boolean;
var
    DrvNum: byte;
    EMode : Word;
begin
    result := false;
    if Drive = 'A' then Exit;
    DrvNum := ord(Drive);
    if DrvNum >= ord('a') then
        dec(DrvNum, $20);
    EMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
        if DiskSize(DrvNum - $40) <> -1 then
            result := true;
    finally
        SetErrorMode(EMode);
    end;
end;

function GetFullNodeName(Node: TTreeNode):string;
var
    CurNode : TTreeNode;
begin
    Result:=''; CurNode := Node;

    if Node.Parent = nil then result := Node.Text;

    while CurNode.Parent<>nil do
    begin
        Result:= CurNode.Text+'\'+Result;
        CurNode := CurNode.Parent;
        if CurNode.Parent = nil then begin result := CurNode.Text+Result; exit; end;
    end;
end;

function GetFullNodeNameEx(Node: TTreeNode):string;
var
    CurNode : TTreeNode;
    i: integer;
    t: string;
begin
    Result:=''; CurNode := Node;

    if Node.Parent = nil then result := Node.Text;

    while CurNode.Parent<>nil do
    begin
        Result:= CurNode.Text+'\'+Result;
        CurNode := CurNode.Parent;
        if CurNode.Parent = nil then begin result := CurNode.Text+Result; break; end;
    end;
    t:='';
    for i := 1 to length(result)-1 do
        t := t+result[i];
    Result := t;
end;

Procedure ShowSubDir(Dir:String; Node: TTreeNode);
Var
    SR        : TSearchRec;
    FindRes   : Integer;
    CurNode   : TTreeNode;
begin
    FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
    While FindRes=0 do
    begin
        if ((SR.Attr and faDirectory)=faDirectory) and
        ((SR.Name='.')or(SR.Name='..')) then
        begin
            FindRes:=FindNext(SR);
            Continue;
        end;
        if ((SR.Attr and faDirectory)=faDirectory) then
        begin
            CurNode := mainform.PathView.Items.AddChild(Node,SR.Name);
            mainform.PathView.Items.AddChild(CurNode,'');
            CurNode.ImageIndex    := 1;
            CurNode.SelectedIndex := 1;
            CurNode.StateIndex    := 1;
            FindRes:=FindNext(SR);
            Continue;
        end;
        FindRes:=FindNext(SR);
    end;
    FindClose(SR);
end;

Procedure ShowSubFiles(Dir:String; Node: TTreeNode);
Var
    SR        : TSearchRec;
    FindRes   : Integer;
    CurNode   : TTreeNode;
begin
    FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
    While FindRes=0 do
    begin
        if FileExists(Dir+SR.Name) then
        begin
            CurNode := mainform.PathView.Items.AddChild(Node,SR.Name);
            CurNode.ImageIndex    := 3;
            CurNode.SelectedIndex := 3;
            CurNode.StateIndex    := 3;
        end;
        FindRes:=FindNext(SR);
    end;
    FindClose(SR);
end;

Procedure ShowSub(Node: TTreeNode);
begin
    while Node.GetFirstChild<>nil do Node.GetFirstChild.Delete;
    ShowSubDir(GetFullNodeName(Node),Node);
    ShowSubFiles(GetFullNodeName(Node),Node);
    if node.Parent <> nil then begin
        node.SelectedIndex := 1;
        node.StateIndex := 1;
        node.ImageIndex := 1;
    end else begin
        node.SelectedIndex := 0;
        node.StateIndex := 0;
        node.ImageIndex := 0;
    end;
end;

procedure CreateDrivesList;
var
    Bufer : array[0..1024] of char;
    RealLen, i : integer;
    S : string;
    root : TTreeNode;
    img  : integer;
begin
    RealLen := GetLogicalDriveStrings(SizeOf(Bufer),Bufer);
    i := 0; S := '';
    while i < RealLen do begin
        if Bufer[i] <> #0 then begin
            S := S + Bufer[i];
            inc(i);
        end else begin
            inc(i);
            img := 0;
            if S <> 'A:\' then
            case GetDriveType(PChar(S)) of
                DRIVE_REMOVABLE : img := 4;
                DRIVE_FIXED     : img := 0;
                DRIVE_CDROM     : img := 5;
            end;
            if S <> 'A:\' then begin
            Root := mainform.PathView.Items.Add(nil,S);
            Root.SelectedIndex := img;
            Root.StateIndex    := img;
            Root.ImageIndex    := img;
            mainform.PathView.Items.AddChild(root,'');
            end;
            S := '';
        end;
    end;
end;
(* -------------------------------------------------------------------------- *)
procedure xc_debug (msg: dword; const args: array of const);
begin
    if msg = sts_UNARCH_FL then begin
        unarchfl := format('%s',args);
    end;

    case msg of

        sts_INIT_ERROR : begin
                            showmessage('Kernel Initialization error.');
                            ExitProcess(0);
                        end;
    end;
end;

procedure xc_progress(progres: integer);
begin
    if progres < 0 then begin
        mainform.ScanProcess.Text := scanfile +' [-]';
    end
    else begin
        if unarchfl = '' then
            mainform.ScanProcess.Text := scanfile +' ['+ inttostr(progres)+'%]'
        else begin
            mainform.ScanProcess.Text := scanfile +'/'+ unarchfl +' ['+ inttostr(progres)+'%]'
        end;
    end;

    Application.ProcessMessages;
end;

function RestoreLongName(fn: string): string;
    function LookupLongName(const filename: string): string;
    var
        sr: TSearchRec;
    begin
        if FindFirst(filename, faAnyFile, sr) = 0 then
            Result := sr.Name
        else
            Result := ExtractFileName(filename);
        SysUtils.FindClose(sr);
    end;
    function GetNextFN: string;
    var
        i: integer;
    begin
        Result := '';
        if Pos('\\', fn) = 1 then
        begin
            Result := '\\';
            fn := Copy(fn, 3, length(fn) - 2);
            i := Pos('\', fn);
            if i <> 0 then
            begin
                Result := Result + Copy(fn, 1, i);
                fn := Copy(fn, i + 1, length(fn) - i);
            end;
        end;
        i := Pos('\', fn);
        if i <> 0 then
        begin
            Result := Result + Copy(fn, 1, i - 1);
            fn := Copy(fn, i + 1, length(fn) - i);
        end
        else begin
            Result := Result + fn;
            fn := '';
        end;
    end;
var
    name: string;
begin
    fn := ExpandFileName(fn);
    Result := GetNextFN;
    repeat
        name := GetNextFN;
        Result := Result + '\' + LookupLongName(Result + '\' + name);
    until length(fn) = 0;
end;

procedure BootReplaceFile(TargetFileName, SourceFileName: string);
var
    WinInitName: string;
    P: PChar;

    procedure InternalGetShortPathName(var S: string);
    begin
        UniqueString(S);
        GetShortPathName(PChar(S), PChar(S), Length(S));
        SetLength(S, StrLen(@S[1]));
        CharToOEM(PChar(S), PChar(S));
    end;

begin
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
        if TargetFileName <> '' then P:=PChar(TargetFileName)
        else P:=nil;
            MoveFileEx(PChar(SourceFileName), P, MOVEFILE_DELAY_UNTIL_REBOOT or MOVEFILE_REPLACE_EXISTING);
    end else begin
        try
            SetLength(WinInitName, MAX_PATH);
            GetWindowsDirectory(@WinInitName[1], MAX_PATH);
            SetLength(WinInitName, StrLen(@WinInitName[1]));
            WinInitName:=IncludeTrailingBackslash(WinInitName)+'WININIT.INI';
            if TargetFileName = '' then TargetFileName := 'NUL'
            else InternalGetShortPathName(TargetFileName);
            InternalGetShortPathName(SourceFileName);
            WritePrivateProfileString('Rename', PChar(TargetFileName),
            PChar(SourceFileName), PChar(WinInitName));
        except
        end;
    end;
end;

function BakFN(FileName: String): String;
var
    temp: string;
    name: string;
    i: integer;
begin
    result := '';
    Result := ExtractFilePath(FileName);
    temp   := ExtractFileName(FileName);
    name   := '';
    (* *)
    for i := 1 to length(temp) do
        if temp[i] <> '.' then
            name := name + temp[i]
        else
            break;
    (* *)
    Result := Result + name + '.bak';
end;

function SmartDeleteFile(FileName: String): boolean;
begin
    Result := sts_deletefile(pchar(FileName));
    if not Result then begin
        if RenameFile(FileName, BakFN(FileName)) then
           BootReplaceFile('',BakFN(FileName))
        else
           BootReplaceFile('',FileName);
    end;
end;

function TMainForm.KillProcess(ProcCapt: String): boolean;
var
    hSnapShot     : THandle;
    uProcess      : PROCESSENTRY32;
    r             : longbool;
    KillProc      : DWORD;
    hProcess      : THandle;
    cbPriv        : DWORD;
    Priv,PrivOld  : TOKEN_PRIVILEGES;
    hToken        : THandle;
begin
    KillProc:=0;
    hProcess:=0;
    hSnapShot:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
    uProcess.dwSize := Sizeof(uProcess);
    try
        if(hSnapShot<>0)then
        begin
            r:=Process32First(hSnapShot, uProcess);
            while r <> false do
            begin
                hProcess:=OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,false,uProcess.th32ProcessID);
                if LowerCase(ProcCapt) = LowerCase(RestoreLongName(sts_getPathbyPID(hProcess))) then
                   KillProc:= uProcess.th32ProcessID;
                   r:=Process32Next(hSnapShot, uProcess);
            end;
            CloseHandle(hProcess);
            CloseHandle(hSnapShot);
        end;
    except
    end;
    hProcess:=OpenProcess(PROCESS_TERMINATE,false,KillProc);
    if hProcess = 0 then
    begin
        cbPriv:=SizeOf(PrivOld);
        OpenThreadToken(GetCurrentThread,TOKEN_QUERY or TOKEN_ADJUST_PRIVILEGES,false,hToken);
        OpenProcessToken(GetCurrentProcess,TOKEN_QUERY or  TOKEN_ADJUST_PRIVILEGES,hToken);
        Priv.PrivilegeCount:=1;
        Priv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
        LookupPrivilegeValue(nil,'SeDebugPrivilege',Priv.Privileges[0].Luid);
        AdjustTokenPrivileges(hToken,false,Priv,SizeOf(Priv),PrivOld,cbPriv);
        hProcess:=OpenProcess(PROCESS_TERMINATE,false,KillProc);
        cbPriv:=0;
        AdjustTokenPrivileges(hToken,false,PrivOld,SizeOf(PrivOld),nil,cbPriv);
        CloseHandle(hToken);
    end;
    if TerminateProcess(hProcess,$FFFFFFFF) then
    begin
        Result := True;
        MainForm.AddLogStr('Завершен процесс: '+ProcCapt);
    end
    else
    begin
        Result := False;
        MainForm.AddLogStr('Ошибка! Завершения процесса: '+ProcCapt);
    end;
end;

function ScanDir(Dir:String) : Boolean;
Var
    SR: TSearchRec;
    FindRes: Integer;
    vn: pchar;
    ret: integer;
begin
    Result := false;

    FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
    While FindRes=0 do
    begin

        if stopped then exit;

        if ((SR.Attr and faDirectory)=faDirectory) and
        ((SR.Name='.')or(SR.Name='..')) then
        begin
            FindRes:=FindNext(SR);
            Continue;
        end;

        if ((SR.Attr and faDirectory)=faDirectory) then
        begin
            ScanDir(Dir+SR.Name+'\');
            FindRes:=FindNext(SR);
            Continue;
        end;

        if FileExists(Dir+SR.Name) then
        begin
            if stopped then exit;
            try
            scanfile := Dir + SR.Name;
            unarchfl := '';
            Application.ProcessMessages;
            inc(scanned);
            ret := sts_matchfile(engine, pchar(Dir+SR.Name), vn, xc_progress, xc_debug,true);
            Sleep(100);
            if ret = sts_VIRUS then begin
            if not statth then
               statth:=True;
               inc(infected);
               with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := dir + SR.Name;
                    SubItems.Add(vn);
               end;
               path:=dir + SR.Name;
               if MainForm.rb1.Checked then
               if MainForm.KillProcess(ExtractFileName(path)) then begin
               if SmartDeleteFile(path) then begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 1;
                    Caption := path;
                    SubItems.Add('Удален');
                    MainForm.AddLogStr('Удален: '+SR.Name);
                  end;
               end else begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := path;
                    SubItems.Add('Ошибка удаления');
                    MainForm.AddLogStr('Ошибка удаления: '+SR.Name);
                  end;
               end;
               end else
               if SmartDeleteFile(path) then begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 1;
                    Caption := path;
                    SubItems.Add('Удален');
                    MainForm.AddLogStr('Удален: '+SR.Name);
                  end;
               end else begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := path;
                    SubItems.Add('Ошибка удаления');
                    MainForm.AddLogStr('Ошибка удаления: '+SR.Name);
                  end;
               end;
               if MainForm.rb2.Checked then
               if RenameFile(path, BakFN(path)) then
                  BootReplaceFile('',BakFN(path))
               else
                  BootReplaceFile('',path);
            end;
            if ret = sts_EREAD then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 0;
                    Caption := dir + SR.Name;
                    SubItems.Add('Ошибка чтения');
                    MainForm.AddLogStr('Ошибка чтения: '+SR.Name);
                end;
            end;
            if ret = sts_ESIZE then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 2;
                    Caption := dir + SR.Name;
                    SubItems.Add('Пропущен');
                    MainForm.AddLogStr('Пропущен: '+SR.Name);
                end;
            end;
            if ret = sts_EMPTY then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 2;
                    Caption := dir + SR.Name;
                    SubItems.Add('Пустой (0 bytes)');
                    MainForm.AddLogStr('Пустой (0 bytes): '+SR.Name);
                end;
            end;
            if statth then begin
               MainForm.ScanProcess.Text:=path;
               MainForm.ThreadStart(nil);
               statth:=False;
            end;
            except
            end;
        end;
        FindRes:=FindNext(SR);
    end;
    SysUtils.FindClose(SR);
    Result := true;
end;

Procedure ScanFileEx(path: string);
var
    ret: integer;
    vn: pchar;
begin
    if FileExists(path) then
    begin
        if stopped then exit;
        try
            scanfile := Path;
            unarchfl := '';
            Application.ProcessMessages;
            inc(scanned);
            ret := sts_matchfile(engine, pchar(path), vn, xc_progress, xc_debug,true);
            Sleep(100);
            if ret = sts_VIRUS then begin
            if not statth then
               statth:=True;
               inc(infected);
               with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := path;
                    SubItems.Add(vn);
               end;
               if MainForm.rb1.Checked then
               if MainForm.KillProcess(ExtractFileName(path)) then begin
               if SmartDeleteFile(path) then begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 1;
                    Caption := path;
                    SubItems.Add('Удален');
                    MainForm.AddLogStr('Удален: '+ExtractFileName(path));
                  end;
               end else begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := path;
                    SubItems.Add('Ошибка удаления');
                    MainForm.AddLogStr('Ошибка удаления: '+ExtractFileName(path));
                  end;
               end;
               end else
               if SmartDeleteFile(path) then begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 1;
                    Caption := path;
                    SubItems.Add('Удален');
                    MainForm.AddLogStr('Удален: '+ExtractFileName(path));
                  end;
               end else begin
                  with mainform.ScanView.Items.Add do begin
                    ImageIndex := 3;
                    Caption := path;
                    SubItems.Add('Ошибка удаления');
                    MainForm.AddLogStr('Ошибка удаления: '+ExtractFileName(path));
                  end;
               end;
               if MainForm.rb2.Checked then
               if RenameFile(path, BakFN(path)) then
                  BootReplaceFile('',BakFN(path))
               else
                  BootReplaceFile('',path);
            end;
            if ret = sts_EREAD then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 0;
                    Caption := path;
                    SubItems.Add('Ошибка чтения');
                    MainForm.AddLogStr('Ошибка чтения: '+ExtractFileName(path));
                end;
            end;
            if ret = sts_ESIZE then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 2;
                    Caption := path;
                    SubItems.Add('Пропущен');
                    MainForm.AddLogStr('Пропущен: '+ExtractFileName(path));
                end;
            end;
            if ret = sts_EMPTY then begin
                with mainform.ScanView.Items.Add do begin
                    ImageIndex := 2;
                    Caption := path;
                    SubItems.Add('Пустой (0 bytes)');
                    MainForm.AddLogStr('Пустой (0 bytes): '+ExtractFileName(path));
                end;
            end;
            if statth then begin
               MainForm.ScanProcess.Text:=path;
               MainForm.ThreadStart(nil);
               statth:=False;
            end;
        except
        end;
    end;
end;

function MsToSec(ms: integer) : String;
var
    tmp: string;
begin
    tmp := inttostr(ms);
    if length(tmp) = 1 then begin
        Result := '0.00'+tmp;
        exit;
    end;
    if length(tmp) = 2 then begin
        Result := '0.0'+tmp;
        exit;
    end;
    if length(tmp) = 3 then begin
        Result := '0.'+tmp;
        exit;
    end;
    if length(tmp) >= 4 then begin
        Insert('.',tmp,length(tmp)-2);
        Result := tmp;
        exit;
    end;
end;
(* -------------------------------------------------------------------------- *)
{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
    tk:=3;
    indx:=0;
    indy:=0;
    statth:=False;
    stopped:=False;
    StopBtn.Enabled := True;
    ExtractFilePath(Application.ExeName);
    Pages.Pages[0].Enabled:=True;
    TMPF:= TStringList.Create;
    TMPHack:= TStringList.Create;
    TMP1:= TStringList.Create;
    TMP2:= TStringList.Create;
    GetWindowsDirectory(@Buf, SizeOf(Buf));
    CreateDrivesList;
    if DirectoryExists(ExtractFilePath(ParamStr(0))+'database\') then
    FindFileDecrypt(ExtractFilePath(ParamStr(0))+'database\');
    init_engine(engine, @xc_debug);
    //sts_unpack_xdb(pchar('database\sts000001.sts.xpb')); //Для теста
    //sts_packing_db(pchar('database\sts000001.sts.xpb.xdb'),PChar('19022018'),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
    sts_load_dbdir(engine,'database\', true);
    MainForm.AddLogStr('Загрузка базы данных ...');
    Caption := 'Kernel: '+sts_version;
    MainForm.AddLogStr('Версия ядра сканера - '+'Kernel: '+sts_version);
    LoadedLabel.caption := inttostr(sts_sigcount(engine))+' сигнатур';
    MainForm.AddLogStr('Количество сигнатур в базе данных - '+inttostr(sts_sigcount(engine)));
    CoolTrayIcon1.IconVisible:=True;
    ThreadStart(Self);
end;

procedure TMainForm.PathViewExpanded(Sender: TObject; Node: TTreeNode);
begin
    if DiskInDrive(GetFullNodeName(Node)[1]) then
        ShowSub(Node)
    else Node.Expanded := false;
    if Node.Parent <> nil then
        if Node.ImageIndex <> 3 then
            if Node.Expanded then begin
                if Node.GetLastChild <> nil then begin
                   Node.ImageIndex := 2;
                   Node.SelectedIndex := 2;
                end;
            end else begin
                Node.ImageIndex := 1;
                Node.SelectedIndex := 1;
            end;
end;

procedure TMainForm.PathViewCollapsed(Sender: TObject; Node: TTreeNode);
begin
    if Node.Parent <> nil then
        if Node.ImageIndex <> 3 then
            if Node.Expanded then begin
                if Node.GetNext <> nil then begin
                   Node.ImageIndex := 2;
                   Node.SelectedIndex := 2;
                end;
            end else begin
                Node.ImageIndex := 1;
                Node.SelectedIndex := 1;
            end;
end;

procedure TMainForm.ScanBtnClick(Sender: TObject);
var
    te, ts: integer;
begin
    MainForm.AddLogStr('Запуск сканирование файлов ...');
    if not stopped then begin
    SelectPathTab.TabVisible := false;
    ScanProcessTab.TabVisible := true;
    ScanProcessTab.Show;
    end;
    StopBtn.Enabled := true;
    ScanBtn.Enabled := false;
    if ClearResults.Checked then
        ScanView.Clear;
    stopped := false;
    ts := GetTickCount;
    sdsk:=ExtractFileDrive(path);
    if (sdsk = '') or (sdsk = 'A:') then Exit;
    if DirectoryExists(path) then
        ScanDir(path)
    else ScanFileEx(path);
    te := GetTickCount;
    ScanProcess.Text := '';
    ScanBtn.Enabled := true;
    BackBtn.Enabled := true;
    StopBtn.Enabled := false;    
    with ScanView.Items.Add do begin
        Caption := 'Файлов проверено';
        SubItems.Add(inttostr(scanned));
        ImageIndex := 1;
    end;
    with ScanView.Items.Add do begin
        Caption := 'Наидено объектов';
        SubItems.Add(inttostr(infected));
        ImageIndex := 1;
    end;
    with ScanView.Items.Add do begin
        Caption := 'Затрачено времени (мс)';
        SubItems.Add(mstosec(te-ts));
        ImageIndex := 1;
    end;
end;

procedure TMainForm.BackBtnClick(Sender: TObject);
begin
    MainForm.AddLogStr('Остановка сканирование файлов ...');
    SelectPathTab.TabVisible := true;
    ScanProcessTab.TabVisible := false;
    SelectPathTab.Show;
    stopped := False;
    BackBtn.Enabled := false;
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
    MainForm.AddLogStr('Остановка сканирование файлов ...');
    StopBtn.Enabled:=False;
    ScanBtn.Enabled:=True;
    SelectPathTab.TabVisible := true;
    ScanProcessTab.TabVisible := false;
    SelectPathTab.Show;
    stopped := true;
end;

procedure TMainForm.CloseBtnClick(Sender: TObject);
begin
    free_engine(engine);
    FindFileEncrypt(ExtractFilePath(ParamStr(0))+'database\');
    FindFileEncryptdb(ExtractFilePath(ParamStr(0))+'database\');
    Close;
end;

procedure TMainForm.PathViewChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
var
    pth: string;
begin
    pth := GetFullNodeNameEx(Node);
    if FileExists(pth) then
       path := GetFullNodeNameEx(Node)
    else
       path := GetFullNodeName(Node);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   TMPF.Free;
   TMPHack.Free;
   TMP1.Free;
   TMP2.Free;
   stopped := true;
   CoolTrayIcon1.IconVisible:=False;
   Application.Terminate;   
end;

procedure TMainForm.SthChange(Sender: TDirChangeNotifier;
 const FileName, OtherFileName: WideString; Action: TDirChangeNotification);
var
  Fmt, Line: WideString;
  y: integer;
begin
if not stopped then begin
  case Action of
    dcnFileAdd: Fmt := 'Creation file %s';
    dcnFileRemove: Fmt := 'Remove file %s';
    dcnRenameFile, dcnRenameDir: Fmt := '%s renamed to %s';
    dcnModified: Fmt := 'Modification file %s';
    dcnLastAccess: Fmt := 'Date last access file %s  modified';
    dcnLastWrite: Fmt := 'Date last write file %s modified';
    dcnCreationTime: Fmt := 'Creation time file %s modified';
  end;
  Line := FormatDateTime('"["hh":"nn":"ss","zzz"] "', Now);
  Line := Line + Format(Fmt, [FileName, OtherFileName]);
  y:=Pos('Creation',Line);
  if y > 0 then
  if FileName <> Application.ExeName then
  if TMPF.IndexOf(FileName) = -1 then begin
     SelectPathTab.TabVisible := false;
     ScanProcessTab.TabVisible := true;
     ScanProcessTab.Show;
     if ClearResults.Checked then
        ScanView.Clear;
     if DirectoryExists(FileName) then begin
        path:=FileName+'\';
        inc(indx);
        SB.Panels[0].Text := IntToStr(indx)+' | '+path;
        stopped:=False;
        if DirectoryExists(FileName) then begin
           ScanDir(path);
        end;
        with ScanView.Items.Add do begin
             Caption := 'Директорий проверено '+inttostr(indx);
             SubItems.Add(FileName);
             ImageIndex := 1;
        end;        
     end else begin
        path:=FileName;
        inc(indy);
        SB.Panels[1].Text := IntToStr(indy)+' | '+path;
        stopped:=False;
        if FileExists(path) then begin
           ScanFileEx(path);
        end;
        with ScanView.Items.Add do begin
             Caption := 'Файлов проверено '+inttostr(indy);
             SubItems.Add(ExtractFileName(FileName));
             ImageIndex := 1;
        end;
     end;
     ScanBtn.Enabled := true;
     BackBtn.Enabled := true;
     TMPF.Clear;
  end;
  if y > 0 then
  if TMPF.IndexOf(FileName) = -1 then begin
     StopBtn.Click;
     TMPF.Insert(0, FileName);
  if TMPF.Count > 0 then begin
    SB.Panels[1].Text := Format('%d objects', [TMPF.Count]);
    SB.Panels[0].Text :='Scan Files: '+Mince(FileName,15);
  end;
  MainForm.AddLogStr('Проверка файла: '+ExtractFileName(FileName));
  ScanFile:=FileName;
  tmr1.Enabled:=True;
  Application.ProcessMessages;  
  end;
end;
end;

procedure TMainForm.ThreadTerminated(Sender: TObject);
begin
  FChangeThread := nil;
  SB.Panels[0].Text := 'Stels stopped';
end;

procedure TMainForm.ThreadStart(Sender: TObject);
begin
  /////////////////////Stels////////////////////////
  FChangeThread := TDirChangeNotifier.Create(ExtractFileDrive(Buf), CAllNotifications);
  FChangeThread.OnChange := SthChange;
  FChangeThread.OnTerminate := ThreadTerminated;
  SB.Panels[0].Text := 'Stels start ...';
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose:=False;
   CoolTrayIcon1.IconVisible:=False;
   CoolTrayIcon1.IconVisible:=True;
   CoolTrayIcon1.HideMainForm;
end;

procedure TMainForm.CoolTrayIcon1Click(Sender: TObject);
begin
  CoolTrayIcon1.ShowMainForm;
end;

procedure TMainForm.sCloseClick(Sender: TObject);
begin
  FindFileEncrypt(ExtractFilePath(ParamStr(0))+'database\');
  FindFileEncryptdb(ExtractFilePath(ParamStr(0))+'database\');
  Application.Terminate;
end;

procedure TMainForm.updprgClick(Sender: TObject);
begin
   if isInternetConnection then begin
      MainForm.AddLogStr('Обновление запущено ...');
   if not FileExists(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt') then UpdMine;
      MainForm.AddLogStr('Обновление сигнатур базы данных ...');
   end else begin
      MainForm.AddLogStr('Нет доступа в интернет!');
   end;
end;

/////////////////FILTER TCP////////////////////////////
procedure TMainForm.AddLogStr(LogString: String);
begin
  MainForm.lst1.Items.Add(FormatDateTime('[hh:mm:ss]',now) + ' ' + LogString);
end;

procedure WarnAboutW2k;
begin
  if NOT WarnedAboutW2k then
  begin
    WarnedAboutW2k := TRUE;
    if NOT Win2KDetected then
    MainForm.AddLogStr('Warning: This application requires Windows 2000/XP, '
                      +'which weren''t detected on this computer. '
                      +'Therefore you are likely to get socket errors because '
                      +'of the insufficient MS Winsock implementation.');
  end
end;

//Определяем IP по хосту
function HostToIP(Name: string; var Ip: string): Boolean; 
var 
  wsdata : TWSAData; 
  hostName : array [0..255] of char; 
  hostEnt : PHostEnt; 
  addr : PChar; 
begin 
  WSAStartup ($0101, wsdata); 
  try 
    gethostname (hostName, sizeof (hostName)); 
    StrPCopy(hostName, Name); 
    hostEnt := gethostbyname (hostName); 
    if Assigned (hostEnt) then 
      if Assigned (hostEnt^.h_addr_list) then begin 
        addr := hostEnt^.h_addr_list^; 
        if Assigned (addr) then begin 
          IP := Format ('%d.%d.%d.%d', [byte (addr [0]), 
          byte (addr [1]), byte (addr [2]), byte (addr [3])]); 
          Result := True; 
        end 
        else 
          Result := False; 
      end 
      else 
        Result := False 
    else begin 
      Result := False; 
    end; 
  finally 
    WSACleanup; 
  end 
end;

procedure RaiseException(msg: String; eCode: Integer);
//
// Format the message and throw a nice exception
//
  function AdditionalMessage: String;
  begin
    Result := SysErrorMessage(eCode);
    if Result <> '' then Result := ': ' + Result
  end;
begin
  if eCode = 0 then
    raise Exception.Create(msg)
  else
    raise Exception.Create('ERROR: '+msg+' [SocketError '+IntToStr(eCode)
                          +AdditionalMessage+']')
end;

function LogFilename: String;
VAR this_computer: Array [0..MAXCHAR] of Char;
    len: DWORD;
begin
  len := sizeof(this_computer)-1;
  GetComputerName(@this_computer, len);
  if len = 0 then
    Result := 'IPLOGGER'
  else begin
    SetLength(Result, len);
    Move(this_computer, Result[1], len);
  end;
  Result := Result+'.log';
end;

function PadStr(s: String; w: Word): String;
// A little helper function to make things pretty
begin
  FmtStr(Result, '%*s', [w, s])
end;

function LogCaption: String;
// A little helper function to make things pretty
begin
  Result := 'Протокол'+' :'+PadStr('Локальный IP',15)+PadStr(':Порт',18)+#9+PadStr('Внешний IP',15)+#9+PadStr(':Порт',11)+#9+PadStr(':SVC/TYPE',9)+#9+PadStr('Данные',18);
  Application.ProcessMessages;
end;

procedure TMainForm.AddInterface(value: String; iff_types: Integer);
begin
  InterfaceComboBox.Items.Add(value)
end;

function MakeReadable(s: String): String;
// A little helper function to make things pretty
CONST MAX_UNWRAPPED_LENGTH=950;
VAR i: Integer;
begin
  for i := 1 to Length(s) do
  begin
    if Byte(s[i]) <  32 then s[i] := '.';{ not printable }
    if Byte(s[i]) > 127 then s[i] := '.';{ not printable?}
  end;

  if Length(s) > MAX_UNWRAPPED_LENGTH then
    Result := Copy(s, 1, MAX_UNWRAPPED_LENGTH)+'<!SNIPPED!>'
  else
    Result := s
end;

///////////////////Блокировка IP адреса////////////////
procedure AddExceptionToFirewall(Const NameIP, DescriptionIP: String; IPADR: string; Port : Word);
const
//Profile Type
NET_FW_PROFILE2_DOMAIN  = 1;
NET_FW_PROFILE2_PRIVATE = 2;
NET_FW_PROFILE2_PUBLIC  = 4;
//Protocol
NET_FW_IP_PROTOCOL_TCP = 6;
NET_FW_IP_PROTOCOL_UDP = 17;
NET_FW_IP_PROTOCOL_ICMPv4 = 1;
NET_FW_IP_PROTOCOL_ICMPv6 = 58;
//Action
NET_FW_ACTION_ALLOW    = 1;
NET_FW_ACTION_BLOCK    = 0;
//Direction
NET_FW_RULE_DIR_IN  = 1;
NET_FW_RULE_DIR_OUT = 2;
var
  fwPolicy2      : OleVariant;
  RulesObject    : OleVariant;
  Profile        : Integer;
  NewRule        : OleVariant;
begin
  Profile             := NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC;
  fwPolicy2           := CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject         := fwPolicy2.Rules;
  NewRule             := CreateOleObject('HNetCfg.FWRule');
  NewRule.Name        := NameIP;
  NewRule.Description := DescriptionIP;
  NewRule.Applicationname := DescriptionIP;
  NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
  NewRule.LocalPorts :=  Port;
  NewRule.Direction := NET_FW_RULE_DIR_IN;
  NewRule.Direction := NET_FW_RULE_DIR_OUT;
  NewRule.Enabled := TRUE;
  NewRule.InterfaceTypes := 'All';
  NewRule.Grouping := 'Block Group';
  NewRule.Profiles := Profile;
  NewRule.Action := NET_FW_ACTION_BLOCK;//NET_FW_ACTION_ALLOW;
  NewRule.RemoteAddresses := IPADR;
  RulesObject.Add(NewRule);
end;

procedure TMainForm.HandleData(Sender: TObject; Socket: TSocket);
VAR
  p_iphdr: PHdrIP;
  p_tcphdr: PHdrTCP;
  p_udphdr: PHdrUDP;
  surl: string;
  y,q: Integer;
  IP: string;
  s_port, d_port, len: Integer;
  src_ip, dst_ip, src_port, dst_port: String;
  protocol, comments, data: String;
  IpBuffer: Array[0..$2000] of Char;
  function GetDataByOffset(d_offset: Integer): String;
  VAR data_start: PChar;
      i: Integer;
  begin
      data_start := PChar(PChar(p_iphdr)+d_offset);
    if ntohs(p_iphdr.tot_len) < sizeof(IpBuffer) then
      i := ntohs(p_iphdr.tot_len) - d_offset
    else
      i := sizeof(IpBuffer) - d_offset;
      SetLength(Result, i);
      Move(data_start^, Result[1], i);
  end;
begin
  y:=0;
  Application.ProcessMessages; { always a good idea }
  if SOCKET_ERROR = recv(FSocket, IpBuffer, sizeof(IpBuffer), 0) then
  begin
    Exit;
  end;
  p_iphdr := PHdrIP(@IpBuffer);
  src_ip  := inet_ntoa(TInAddr(p_iphdr.saddr));
  dst_ip  := inet_ntoa(TInAddr(p_iphdr.daddr));
  protocol := GetIPProtoName(p_iphdr.protocol);
  data := '';
  len := GetIHlen(p_iphdr^);
  if p_iphdr.protocol = IPPROTO_ICMP then // is ICMP?
  begin
    comments := GetICMPType(PByte(PChar(p_iphdr)+len)^);
    src_port := '-'; { port does not apply to ICMP }
    dst_port := '-';
  end
  else begin
    s_port := 0;
    d_port := 0;
    if p_iphdr.protocol = IPPROTO_TCP then // is TCP
    begin
      p_tcphdr := PHdrTCP(PChar(p_iphdr)+len);
      s_port   := ntohs(p_tcphdr.source);
      d_port   := ntohs(p_tcphdr.dest);
      data := GetDataByOffset(len + GetTHdoff(p_tcphdr^));
    end;
    if p_iphdr.protocol = IPPROTO_UDP then // is UDP
    begin
      p_udphdr := PHdrUDP(PChar(p_iphdr)+len);
      s_port   := ntohs(p_udphdr.src_port);
      d_port   := ntohs(p_udphdr.dst_port);
      data := GetDataByOffset(len + sizeof(THdrUDP));
    end;
    src_port   := IntToStr(s_port);
    dst_port   := IntToStr(d_port);
    comments := GetServiceName(s_port, d_port);
  end;
  if TMPHack.Count > 0 then
  for q:=0 to TMPHack.Count-1 do begin
  if LogMemo.Lines.Text <> '' then
     y:=Pos(TMPHack.Strings[q],LogMemo.Lines.Text);
  if y > 0 then begin
  if HostToIp(TMPHack.Strings[q], IP) then dst_ip := IP;
     surl:=Copy(LogMemo.Lines.Text,y,Length(TMPHack.Strings[q]));
     if surl <> '' then begin
     mmo1.Lines.Add(surl+' '+dst_ip+':'+dst_port);
     if surl = 'authedmine.com' then begin
     lst1.Items.Add('Вредоносный скрипт на сайте:'+#13#10+'URL адрес -> '+surl+#13#10+'IP адрес:порт -> '+dst_ip+':'+dst_port);
     if svlog.Checked then lst1.Items.SaveToFile('LogPrg.txt');
     MessageFrm.Caption := 'Внимание';
     MessageFrm.InformationLabel.Caption := 'Обнаружен вредоносный сайт '+surl;
     MessageFrm.InfoLabel.Caption := 'Скрытый майнинг ... CoinHive.Anonymous';
     MessageFrm.Memo1.Text := 'Тело скрипта: '+#13#10+
     '<script src="https://authedmine.com/lib/authedmine.min.js"></script>'+#13#10+
     '<script>'+#13#10+
     'var miner = new CoinHive.Anonymous('''+'LcGiqhRjFmNQUXZTOtPrPGCmlMXsTQIv'+''', {throttle: 0.3});'+#13#10+
     'if (!miner.isMobile() && !miner.didOptOut(14400)) {'+#13#10+
     'miner.start();'+#13#10+
     '}'+#13#10+
     '</script>'+#13#10+'Вредоносный скрипт на сайте:'+#13#10+'URL адрес -> '+surl+#13#10+'IP адрес:порт -> '+dst_ip+':'+dst_port+#13#10+'Данный сайт занесен в Block Group!';
     MessageFrm.Show;
     Application.ProcessMessages;
     end else begin
     lst1.Items.Add('Вредоносный скрипт на сайте:'+#13#10+'URL адрес -> '+surl+#13#10+'IP адрес:порт -> '+dst_ip+':'+dst_port);
     if svlog.Checked then lst1.Items.SaveToFile('LogPrg.txt');
     MessageFrm.Caption := 'Внимание';
     MessageFrm.InformationLabel.Caption := 'Обнаружен вредоносный сайт '+surl;
     MessageFrm.InfoLabel.Caption := 'Скрытый майнинг ... Coin.Anonymous';
     MessageFrm.Memo1.Text := 'Вредоносный скрипт на сайте:'+#13#10+'URL адрес -> '+surl+#13#10+'IP адрес:порт -> '+dst_ip+':'+dst_port+#13#10+'Данный сайт занесен в Block Group!';
     MessageFrm.Show;
     Application.ProcessMessages;
     end;
     try
      CoInitialize(nil);
      try
       if (dst_ip <> '') and (dst_port <> '') then
       AddExceptionToFirewall(surl,'Block Incoming Connections from IP Address.',dst_ip, StrToInt(dst_port));
      finally
       CoUninitialize;
      end;
     except
      on E:EOleException do
         MainForm.AddLogStr('Ошибка '+Format('EOleException %s %x', [E.Message,E.ErrorCode]));
      on E:Exception do
         MainForm.AddLogStr('Ошибка '+E.Classname+' : '+E.Message);
     end;
     end;
     LogMemo.Lines.Clear;
  end;
  end;
  // Log
  Log(PadStr(protocol,5)+': '
     +PadStr(src_ip, 15)+#9+':'+src_port+#9
     +PadStr(dst_ip, 15)+#9+':'+dst_port+#9
     +': '+comments+#9+MakeReadable(data));
end;

procedure TMainForm.WMASyncSelect(var msg: TMessage);
begin
  case LoWord(msg.lParam) of
    FD_READ:    if Assigned(FAsyncRead)    then FAsyncRead(Self,msg.wParam);
    FD_WRITE:   if Assigned(FAsyncWrite)   then FAsyncWrite(Self,msg.wParam);
    FD_OOB:     if Assigned(FAsyncOOB)     then FAsyncOOB(Self,msg.wParam);
    FD_ACCEPT:  if Assigned(FAsyncAccept)  then FAsyncAccept(Self,msg.wParam);
    FD_CONNECT: if Assigned(FAsyncConnect) then FAsyncConnect(Self,msg.wParam);
    FD_CLOSE:   if Assigned(FAsyncClose)   then FAsyncClose(Self,msg.wParam);
  end;
end;

function  TMainForm.StartLogging: Boolean;
VAR
  host, errStr: String;
  timeout, ret: Integer;
  sa: TSockAddr;
  dwBufferInLen,
  dwBufferOutLen,
  dwDummy: DWORD;
  addr: u_long;
begin
  Result := FALSE; { guilty until proven innocent }
  host := InterfaceComboBox.Text;
  if host = '' then
  begin
    ShowMessage('You must supply a valid IP address!');
    Exit;
  end;
  errStr := InitWinsock(2,2);
  if errStr <> '' then
  begin
    ShowMessage(errStr);
    Exit;
  end;
  try
    FSocket := socket(AF_INET, SOCK_RAW, IPPROTO_IP);
    if FSocket = INVALID_SOCKET then
      RaiseException('Invalid Socket', WSAGetLastError);
    timeout := 3000;
    ret := setsockopt(FSocket, SOL_SOCKET, SO_RCVTIMEO, PChar(@timeout), sizeof(timeout));
    if ret = SOCKET_ERROR Then
      RaiseException('Setsockopt() failed', WSAGetLastError);
    addr := ResolveHostAddress(host);
    if addr = u_long(-1) then
      RaiseException('Interface must be a valid IP address', 0);
    FillChar(sa, sizeof(sa), 0);
    sa.sin_family := AF_INET;
    sa.sin_addr.s_addr := addr;
    ret := bind(FSocket, sa, sizeof(sa));
    if ret = SOCKET_ERROR then
      RaiseException('bind() failed', WSAGetLastError);
    dwBufferInLen := 1;
    dwBufferOutLen := 0;
    ret := WSAIoctl(FSocket, SIO_RCVALL,
        @dwBufferInLen, sizeof(dwBufferInLen),
        @dwBufferOutLen, sizeof(dwBufferOutLen),
        @dwDummy, Nil, Nil);
    if ret = SOCKET_ERROR then
      RaiseException('WSAIoctl() failed', WSAGetLastError);
    // Register our asynchronous socket event handler
    //
    ret := WSAASyncSelect(FSocket, handle, WM_ASYNCSELECT, FD_READ);
    if ret = SOCKET_ERROR then
      RaiseException('WSAAsyncSelect() failed', WSAGetLastError)
    else
      Result := TRUE;
  except
    CleanupWinsock(FSocket);
    raise;
  end;
end;

function  TMainForm.StopLogging: String;
begin
  Result := '';
  {$I-}
  if FLogOpen then
  begin
    Result := 'Log File: '+FLogName;
    CloseFile(FLogFile);
    FLogOpen := FALSE;
  end;
  {$I+}
  // Unregister our event handler, and close the socket
  //
  WSAASyncSelect(FSocket, Handle, WM_ASYNCSELECT, 0);
  CleanupWinsock(FSocket);
end;

procedure TMainForm.Log(s: String);
begin
  // If "LogToFile" is checked and if the log file
  if FileCheckBox.Checked AND NOT FLogOpen then
  begin
    {$I-}
    FLogName := ExtractFilePath(Application.ExeName)+LogFilename;
    AssignFile(FLogFile, FLogName);
    if FileExists(FLogName) then
      Append(FLogFile)
    else
      Rewrite(FLogFile);
    {$I-}
    FLogOpen := IOResult = 0;
    if FLogOpen then
    begin
     // Start the log with a time stamp
     WriteLn(FLogFile);
     WriteLn(FLogFile, 'LOG start: '+FormatDateTime('yyyy-mm-dd hh:nn:ss', now));
     WriteLn(FLogFile);
     WriteLn(FLogFile, LogCaption);
     WriteLn(FLogFile);
    end;
  end;
  // Write to log file, if it's open
  if FLogOpen then WriteLn(FLogFile, s);
  // No matter what we write to our memo, of course
  LogMemo.Lines.Add(s)
end;

//удаление двойных строк из списка строк
procedure RemoveDuplicates(const stringList : TStringList);
var
  buffer: TStringList;
  cnt: Integer;
begin
  stringList.Sort;
  buffer := TStringList.Create;
  try
    buffer.Sorted := True;
    buffer.Duplicates := dupIgnore;
    buffer.BeginUpdate;
    for cnt := 0 to stringList.Count - 1 do
      buffer.Add(stringList[cnt]) ;
    buffer.EndUpdate;
    stringList.Assign(buffer) ;
  finally
    FreeandNil(buffer) ;
  end;
end;

//Зашифрование/расшифрование файла:
function EncryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.EncryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

function DecryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.DecryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

function ExtractOnlyFileName(const FileName: string): string;
begin
   result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;
///////////////////////////////////////////////

procedure TMainForm.FindFileDecrypt(Dir:String);
Var SR:TSearchRec; 
    FindRes:Integer;
    sf,Fname: string;
begin 
FindRes:=FindFirst(Dir+'*.c',faAnyFile,SR);
While FindRes=0 do 
   begin 
      if ((SR.Attr and faDirectory)=faDirectory) and 
         ((SR.Name='.')or(SR.Name='..')) then 
         begin 
            FindRes:=FindNext(SR);
            Continue; 
         end;
      if ((SR.Attr and faDirectory)=faDirectory) then // если найден каталог, то
         begin 
            FindFileDecrypt(Dir+SR.Name+'\'); // входим в процедуру поиска с параметрами текущего каталога + каталог, что мы нашли
            FindRes:=FindNext(SR); // после осмотра вложенного каталога мы продолжаем поиск в этом каталоге 
            Continue; // продолжить цикл 
         end else
          if ExtractFileExt(Dir+SR.Name) = '.c' then begin
             sf:=Dir+SR.Name;
             Fname:=ExtractOnlyFileName(sf);
          if FileExists(sf) then
             DecryptFile(sf,ExtractFilePath(sf)+Fname,KeyRelease);
          end;
      FindRes:=FindNext(SR);
   end; 
FindClose(SR);
end;

procedure TMainForm.FindFileEncrypt(Dir:String);
Var SR:TSearchRec; 
    FindRes:Integer;
    sf: string;
begin 
FindRes:=FindFirst(Dir+'*.xpb',faAnyFile,SR);
While FindRes=0 do 
   begin 
      if ((SR.Attr and faDirectory)=faDirectory) and 
         ((SR.Name='.')or(SR.Name='..')) then 
         begin 
            FindRes:=FindNext(SR);
            Continue; 
         end;
      if ((SR.Attr and faDirectory)=faDirectory) then // если найден каталог, то
         begin 
            FindFileDecrypt(Dir+SR.Name+'\'); // входим в процедуру поиска с параметрами текущего каталога + каталог, что мы нашли
            FindRes:=FindNext(SR); // после осмотра вложенного каталога мы продолжаем поиск в этом каталоге 
            Continue; // продолжить цикл 
         end else
          if ExtractFileExt(Dir+SR.Name) = '.xpb' then begin
             sf:=Dir+SR.Name;
             sf:=ExtractOnlyFileName(Dir+SR.Name);
             sf:=sf+'.xdb';
          if FileExists(sf) then
             EncryptFile(sf,sf+'.c',KeyRelease);
             DeleteFile(sf);
          end;
      FindRes:=FindNext(SR);
   end; 
FindClose(SR);
end;

procedure TMainForm.FindFileEncryptdb(Dir:String);
Var SR:TSearchRec;
    FindRes:Integer;
    sf: string;
begin 
FindRes:=FindFirst(Dir+'*.xdb',faAnyFile,SR);
While FindRes=0 do 
   begin 
      if ((SR.Attr and faDirectory)=faDirectory) and 
         ((SR.Name='.')or(SR.Name='..')) then 
         begin 
            FindRes:=FindNext(SR);
            Continue; 
         end;
      if ((SR.Attr and faDirectory)=faDirectory) then // если найден каталог, то
         begin 
            FindFileDecrypt(Dir+SR.Name+'\'); // входим в процедуру поиска с параметрами текущего каталога + каталог, что мы нашли
            FindRes:=FindNext(SR); // после осмотра вложенного каталога мы продолжаем поиск в этом каталоге 
            Continue; // продолжить цикл 
         end else
          if ExtractFileExt(Dir+SR.Name) = '.xdb' then begin
             sf:=Dir+SR.Name;
          if FileExists(sf) then
             EncryptFile(sf,sf+'.c',KeyRelease);
             DeleteFile(sf);
          end;
      FindRes:=FindNext(SR);
   end; 
FindClose(SR);
end;

procedure TMainForm.startxClick(Sender: TObject);
label vx;
var
  sl : TStringList;
  str: string;
  cnt : integer;
begin
  if FLogInProgress then
  begin
    FLogInProgress := FALSE;
    MainForm.AddLogStr('Остановка мониторинга сети ...');
    TopLabel.Caption := StopLogging;
    startx.Caption := 'Старт';
    FileCheckBox.Enabled := TRUE;
    InterfaceComboBox.Enabled := TRUE;
    Log('Logging stopped by user ['+FormatDateTime('yyyy-mm-dd hh:nn:ss', now)+']');
  end
  else begin
  vx:
  if FileExists(ExtractFilePath(ParamStr(0))+'BlackList.txt') then begin
     //EncryptFile('BlackList.txt','BlackList.txt.crypt',KeyRelease); //Криптовка информации
  if TMPHack.IndexOf('authedmine.com') = -1 then begin
     TMPHack.LoadFromFile(ExtractFilePath(ParamStr(0))+'BlackList.txt');
     TMPHack.Add('authedmine.com');
     sl := TStringList.Create;
    try
     for cnt := 1 to TMPHack.Count-1 do
     sl.Add(TMPHack.Strings[cnt]) ;
     RemoveDuplicates(sl) ;
     TMPHack.Clear;
     TMPHack.Text:=sl.Text;
     RemoveDuplicates(TMPHack);
    finally
     sl.Free;
    end;
     TMPHack.Sorted:=True;
     TMPHack.SaveToFile(ExtractFilePath(ParamStr(0))+'BlackList.txt');
     TMPHack.LoadFromFile(ExtractFilePath(ParamStr(0))+'BlackList.txt');
     Caption:='Загрузка защиты AntiMine ...';
     lst1.Items.Add('Загрузка защиты AntiMine ...');
     Application.ProcessMessages;
     EncryptFile(ExtractFilePath(ParamStr(0))+'BlackList.txt',ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt',KeyRelease); //Криптовка информации
  end else TMPHack.LoadFromFile(ExtractFilePath(ParamStr(0))+'BlackList.txt');
     grp5.Caption:='Фильтрация вредоносных сайтов: - '+IntToStr(TMPHack.Count);
  end else
  if FileExists(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt') then begin
     str:=ExtractOnlyFileName(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt');
     DecryptFile(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt',ExtractFilePath(ParamStr(0))+str,KeyRelease);
     if FileExists(ExtractFilePath(ParamStr(0))+str) then begin
     AddLogStr('Список вредоносных сайтов расшифрован!');
     lst1.Items.Add('Список вредоносных сайтов расшифрован!');
     Caption:='Список защиты AntiMine расшифрован.';
     lst1.Items.Add('Список защиты AntiMine расшифрован.');
     Application.ProcessMessages;
     goto vx;
     end else begin
     AddLogStr('Ошибка расшифровки списка вредоносных сайтов!');
     lst1.Items.Add('Ошибка расшифровки списка вредоносных сайтов!');
     Caption:='Ошибка расшифровки списка AntiMine.';
     lst1.Items.Add('Ошибка расшифровки списка AntiMine.');
     Application.ProcessMessages;
     end;
  end;
  if svlog.Checked then lst1.Items.SaveToFile('LogPrg.txt');
     WarnAboutW2k;      // We want Win2K
    if StartLogging then
    begin
      MainForm.AddLogStr('Запуск мониторинга сети ...');
      FLogInProgress := TRUE;
      startx.Caption := 'Стоп';
      FileCheckBox.Enabled := FALSE;
      InterfaceComboBox.Enabled := FALSE;
      TopLabel.Caption := LogCaption;
      LogMemo.Clear;
      LogMemo.Visible := TRUE;
      Log('Logging started ['+FormatDateTime('yyyy-mm-dd hh:nn:ss', now)+']');
    end
  end;
end;

procedure TMainForm.tmr1Timer(Sender: TObject);
begin
     tk:=tk-1;
     DBLabel.Caption:=' Parameters '+IntToStr(tk);
  if tk <= 0 then begin
     tk:=3;
     tmr1.Enabled:=False;
     if FileExists(ScanFile) then ScanFileEx(ScanFile);
     if DirectoryExists(ExtractFilePath(ScanFile)) then ScanDir(ExtractFilePath(ScanFile));
     Sleep(500);
     ScanBtn.Click;
  end;
end;

end.
