unit uScanning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Richedit,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, sts_lib, Menus, uPathesTools, sts_processlist,
  shellapi;

type
(******************************************************************************)
    TFileCounter = class(TThread)
    private
    protected
        procedure Execute; override;
        procedure GetFileCount(Dir: String);
    public
        Filter  : String;
        Dirs    : TStringList;
        Scanner : Pointer;
        function InExtList(FileName: String): boolean;
    end;

    TAvScanner = class(TThread)
    private
        procedure ScanDir(Dir: String);
    protected
        procedure Execute; override;
    public
        ENGINE       : psts_engine;
        FileName     : String;
        FileProgress : String;
        UnArchName   : String;
        Dirs         : TStringList;
        ScanStopped  : boolean;
        (* *)
        LastCount    : integer;
        FilesCount   : integer;
        Delim        : integer;
        SetProgress  : boolean;
        (* *)
        NeedReboot   : boolean;
        (* *)
        Scanned  , FullScanned,
        Infected , Skipped: integer;
        DirCount     : integer;
        FullSize     : int64;
        (* *)
        Line         : String;
        Color        : TColor;
        Bold         : boolean;
        (* *)
        Memscan      : boolean;
        Filter       : String;
        (* *)
        Procedure Stop;
        Procedure SetMaximalFiles(FilesCount: integer);
        Procedure UpdateProgress;
        Procedure EndProgress;
        procedure ADDREP(AText: string; AColor: TColor; bold: boolean = false);
        procedure ADDTOREPORT;
        procedure SetCtrlsStart;
        procedure SetCtrlsEnd;
        Procedure ShowError;
        procedure SetFileProgress(FP: String);
        procedure UpdateFileProgress;
        function InExtList(FileName: String): boolean;
        function SmartDeleteFile(FileName: String): boolean;
  end;

  TVirRecord = record
      virname: string;
      path: string;
      deleted: boolean;
  end;
(******************************************************************************)

  TScanForm = class(TForm)
    btSaveReport: TButton;
    btStop: TButton;
    ScanLabel: TLabel;
    SaveDialog1: TSaveDialog;
    ReportMemo: TRichEdit;
    ProgressBar1: TProgressBar;
    pnAction: TPanel;
    Animate1: TAnimate;
    btPause: TButton;
    CloseTimer: TTimer;
    lbXCORE: TLabel;
    lbFilesScanned: TLabel;
    procedure btStopClick(Sender: TObject);
    procedure btSaveReportClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    (* *)
    procedure AddLineToReport(AText: string; AColor: TColor; bold: boolean = false);
    (* *)
  private
    { Private declarations }
  public
    (* *)
    VirusList: array of TVirRecord;
    Scanner: TAvScanner;
  protected
    procedure WndProc(var Message: TMessage); override;
    (* *)
  end;

var
    ScanForm: TScanForm;
    CloseTick: integer = 10;
implementation

uses uMain, uReport, uErrorForm;
(******************************************************************************)
procedure TScanForm.WndProc(var Message: TMessage);
var
p: TENLink;
strURL: string;
begin
if (Message.Msg = WM_NOTIFY) then
begin
   if (PNMHDR(Message.lParam).code = EN_LINK) then
   begin
     p := TENLink(Pointer(TWMNotify(Message).NMHdr)^);
     if (p.Msg = WM_LBUTTONDOWN) then
     begin
       SendMessage(ReportMemo.Handle, EM_EXSETSEL, 0, Longint(@(p.chrg)));
       strURL := ReportMemo.SelText;
       ShellExecute(Handle, 'open', PChar(strURL), 0, 0, SW_SHOWNORMAL);
     end
   end
end;

inherited;
end;
(******************************************************************************)
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

function RetDelete(const str : string;
                   index     : cardinal;
                   count     : cardinal = maxInt) : string;
begin
    result := str;
    Delete(result, index, count);
end;

procedure _FillStr(var str: string; fillLen: integer; addLeft: boolean; fillChar: char);
var
    s1 : string;
begin
    if fillLen > 0 then begin
        SetLength(s1, fillLen);
        system.FillChar(pointer(s1)^, fillLen, byte(fillChar));
        if addLeft then begin
            if (fillChar in ['0'..'9']) and (str <> '') and (str[1] = '-') then
               str := '-' + s1 + RetDelete(str, 1, 1)
            else str := s1 + str;
        end else str := str + s1;
    end;
end;

function IntToStrEx(value    : int64;
                    minLen   : integer = 1;
                    fillChar : char    = '0') : string; overload;
begin
    result := IntToStr(value);
    _FillStr(result, abs(minLen) - Length(result), minLen > 0, fillChar);
end;

var FDecSep : char = #0;
function DecSep : char;
var buf : array[0..1] of char;
begin
    if FDecSep = #0 then
        if GetLocaleInfo(GetThreadLocale, LOCALE_SDECIMAL, buf, 2) > 0 then
             FDecSep := buf[0]
        else FDecSep := ',';
    result := FDecSep;
end;

function SizeToStr(size: int64) : string;
begin
    if abs(size) >= 1024 then begin
        if abs(size) >= 1024 * 1024 then begin
            if abs(size) >= 1024 * 1024 * 1024 then begin
                result := IntToStrEx(abs(size div 1024 div 1024 * 100 div 1024)) + ' GB';
                Insert(DecSep, result, Length(result) - 4);
            end else begin
                result := IntToStrEx(abs(size div 1024 * 100 div 1024)) + ' MB';
                Insert(DecSep, result, Length(result) - 4);
            end;
        end else begin
            result := IntToStrEx(abs(size * 100 div 1024)) + ' KB';
            Insert(DecSep, result, Length(result) - 4);
        end;
        end else result := IntToStrEx(abs(size)) + ' Bytes';
end;

function BytesToMegaBytes(Bytes: int64): String;
begin
    Result := sizetostr(Bytes);
end;

function MsToStr(time: cardinal) : string;
begin
    if time >= 1000 then begin
        if time >= 1000 * 60 then begin
            if time >= 1000 * 60 * 60 then begin
                time := time div (1000 * 60);
                result := IntToStrEx(time mod 60);
                if Length(result) = 1 then result := '0' + result;
                result := IntToStrEx(time div 60) + ':' + result + ' h';
            end else begin
                time := time div 1000;
                result := IntToStrEx(time mod 60);
                if Length(result) = 1 then result := '0' + result;
                result := IntToStrEx(time div 60) + ':' + result + ' min';
            end;
        end else begin
            result := IntToStrEx(time mod 1000 div 10);
            if Length(result) = 1 then result := '0' + result;
            result := IntToStrEx(time div 1000) + DecSep + result + ' s';
        end;
    end else result := IntToStrEx(time) + ' ms';
end;
(******************************************************************************)
function sts_format_name(fname: string): string;
const
    __scan    = '%-70s';
    __maxline = 70;
var
    drive, path, name, _name : string;
    i, cn : integer;
begin
    result := fname;
    drive  := extractfiledrive(fname) + '\...\';
    path   := extractfilepath(fname);
    name   := extractfilename(fname);

    if length(fname) < __maxline then exit;

    if length(fname) > __maxline then
        if length(drive + name) < __maxline then
        begin
            result := drive + name;
            exit;
        end else begin
            _name  := '';
            for i := length(name) downto length(drive) do begin
                _name  := name[i] + _name;
                if length(drive + _name) >= __maxline then break;
            end;
            result := drive + _name;
        end;
end;
(******************************************************************************)
function ConvertToDate(Str: String): String;
begin
    Result := Str;
    Insert('.',Result,3);
    Insert('.',Result,6);
end;

function isExpired(date: string): boolean; 
var
    DT,DTNOW: TDateTime;
begin
    Result := False;
    (* *)
    try
        if Date = '000000' then result := true
        else begin
            DT := StrToDate(ConvertToDate(date));
            DTNOW := StrToDate(FormatDateTime('dd.mm.yy',now));
            (* *)
            if DT+14 < DTNOW then Result := true;
        end;
    except
    end;
end;
(******************************************************************************)
procedure ScanDebug(msg: dword; const args: array of const);
begin
    case msg of
        sts_UNARCH_FL :begin
                           ScanForm.Scanner.UnArchName := sts_format_name(ScanForm.Scanner.FileName +'/'+ format('%s',args));
                           inc(ScanForm.Scanner.FullScanned);
                       end;
        sts_LOAD_PDB  : begin
                           ScanForm.Scanner.LastCount := sts_sigcount(ScanForm.Scanner.ENGINE) - ScanForm.Scanner.LastCount;
                           ScanForm.Scanner.ADDREP(format('Загружена База Сигнатур "%s": ' + inttostr(ScanForm.Scanner.LastCount),args), clBlack, false);
                           ScanForm.Scanner.LastCount := sts_sigcount(ScanForm.Scanner.ENGINE);
                       end;
        sts_LOAD_DB   : begin
                           ScanForm.Scanner.LastCount := sts_sigcount(ScanForm.Scanner.ENGINE) - ScanForm.Scanner.LastCount;
                           ScanForm.Scanner.ADDREP(format('Загружена База Сигнатур "%s": ' + inttostr(ScanForm.Scanner.LastCount),args), clMaroon, false);
                           ScanForm.Scanner.LastCount := sts_sigcount(ScanForm.Scanner.ENGINE);
                       end;
    end;
end;

procedure ScanProgress(progres: integer);
begin
    if progres < 0 then begin
        ScanForm.Scanner.SetFileProgress(ScanForm.Scanner.FileName +' [-]');
    end
    else begin
        if ScanForm.Scanner.UnArchName = '' then
            ScanForm.Scanner.SetFileProgress(ScanForm.Scanner.FileName +' ['+ inttostr(progres)+'%]')
        else begin
            ScanForm.Scanner.SetFileProgress(ScanForm.Scanner.UnArchName +' ['+ inttostr(progres)+'%]');
        end;
    end;
end;
(******************************************************************************)
function TFileCounter.InExtList(FileName: String): boolean;
var
    ext: string;
    i: integer;
begin
    ext := LowerCase(ExtractFileExt(FileName))+'|';

    if MainForm.Options.FilterString = '|' then begin
        Result := true;
    end else
    if Pos('.*|', lowercase(Filter)) <> 0 then begin
        Result := true;
    end else
    if Pos(ext, lowercase(Filter)) <> 0 then
        Result := true
        else
        Result := false;
end;

procedure TFileCounter.GetFileCount(Dir: String);
Var
    SR        : TSearchRec;
    FindRes,i : Integer;
    EX        : String;
begin
    FindRes:=sysutils.FindFirst(Dir+'*.*',faAnyFile,SR);
    While FindRes=0 do
    begin

        if TAvScanner(Scanner).ScanStopped then Exit;

        if ((SR.Attr and faDirectory)=faDirectory) and
        ((SR.Name='.')or(SR.Name='..')) then
        begin
            FindRes:=FindNext(SR);
            Continue;
        end;

        if MainForm.Options.ScanInSubDirectories then
            if ((SR.Attr and faDirectory)=faDirectory) then
            begin
                GetFileCount(Dir+SR.Name+'\');
                FindRes:=sysutils.FindNext(SR);
                Continue;
            end;

        if FileExists(Dir+Sr.Name) then begin
            if InExtList(Sr.Name) then
            TAvScanner(Scanner).FilesCount := TAvScanner(Scanner).FilesCount + 1;
        end;

        FindRes:=sysutils.FindNext(SR);
    end;
    sysutils.FindClose(SR);
end;

Procedure TFileCounter.Execute;
var
    i : integer;
begin
    TAvScanner(Scanner).FilesCount := 0;
    Filter := MainForm.Options.FilterString;
    for i := 0 to Dirs.Count-1 do begin
        if TAvScanner(Scanner).ScanStopped then Exit;
        if FileExists(Dirs[i]) then begin
            if InExtList(ExtractFileName(Dirs[i])) then
                TAvScanner(Scanner).FilesCount := TAvScanner(Scanner).FilesCount + 1;
        end
        else
        begin
            if DirectoryExists(Dirs[i]) then
                GetFileCount(Dirs[i]);
        end;
    end;
    TAvScanner(Scanner).SetMaximalFiles(TAvScanner(Scanner).FilesCount);
end;
(******************************************************************************)
function TAvScanner.SmartDeleteFile(FileName: String): boolean;
begin
    Result := sts_deletefile(pchar(FileName));
    if not Result then begin
        (* *)
        NeedReboot := true;
        (* *)
        if RenameFile(FileName, BakFN(FileName)) then
            BootReplaceFile('',BakFN(FileName))
        else
            BootReplaceFile('',FileName);
        (* *)
        ScanForm.VirusList[Infected-1].deleted := true;
    end;
end;

function TAvScanner.InExtList(FileName: String): boolean;
var
    ext: string;
    i: integer;
begin
    ext := LowerCase(ExtractFileExt(FileName))+'|';

    if Filter = '|' then begin
        Result := true;
    end else
    if Pos('.*|', lowercase(Filter)) <> 0 then begin
        Result := true;
    end else
    if Pos(ext, lowercase(Filter)) <> 0 then
        Result := true
        else
        Result := false;
end;
(******************************************************************************)
procedure TAvScanner.UpdateFileProgress;
begin
    ScanForm.ScanLabel.Caption := FileProgress;
end;

procedure TAvScanner.SetFileProgress(FP: String);
begin
    FileProgress := FP;
    Synchronize(UpdateFileProgress);
end;
(******************************************************************************)
procedure TAvScanner.SetCtrlsEnd;
begin
    ScanForm.ScanLabel.Caption := '';
    ScanForm.btPause.Enabled  := False;
    ScanForm.btSaveReport.Enabled := true;
    ScanForm.btStop.Enabled  := true;
    ScanForm.btStop.Caption  := 'Закрыть';
    ScanForm.btPause.Caption := 'Пауза';
    ScanForm.btStop.Tag      := 1;
    ScanForm.btStop.SetFocus;
    if MainForm.AutoClose then begin
        ScanForm.CloseTimer.Enabled := True;
        ScanForm.btSaveReport.Enabled := False;
    end;
    if MainForm.FastClose then MainForm.Close;
end;

procedure TAvScanner.SetCtrlsStart;
begin
    CloseTick := 10;
    ScanForm.CloseTimer.Enabled    := False;
    ScanForm.ProgressBar1.Position := 0;
    ScanForm.ProgressBar1.Max      := 0;
    ScanForm.ScanLabel.Caption     := '';
    ScanForm.ReportMemo.Clear;
    ScanForm.btSaveReport.Enabled := false;
    ScanForm.btStop.Enabled := true;
    ScanForm.btStop.Caption := 'Стоп';
    ScanForm.btStop.Tag     := 0;
    ScanForm.btStop.SetFocus;
    ScanForm.btPause.Enabled := false;
end;

procedure TAvScanner.ADDTOREPORT;
begin
    Application.ProcessMessages;
    with ScanForm.ReportMemo do
    begin
        SelStart := Length(Text);
        SelAttributes.Color := Self.Color;
        SelAttributes.Size := 8;
        if Self.bold then
            SelAttributes.Style := SelAttributes.Style + [fsBold];
        Lines.Add(self.Line);
    end;
    (* Write Line To Report File *)
    if not DirectoryExists(ExtractFilePath(MainForm.Options.ReportLocFile)) then
        PrepareToSave(MainForm.Options.ReportLocFile);

    sts_writeline(pchar(MainForm.Options.ReportLocFile), pchar(self.Line));
    (* *)
end;

procedure TAvScanner.ADDREP(AText: string; AColor: TColor; bold: boolean = false);
begin
    Self.Line := AText;
    Self.bold := Bold;
    Self.Color := AColor;
    Synchronize(ADDTOREPORT);
end;

procedure TAvScanner.ScanDir(Dir:String);
    procedure setnormattr(filename: string);
    var
        Flags : cardinal;
    begin
        Flags := 0;
        Flags := Flags - faReadOnly;
        SetFileAttributes(PChar(FileName),Flags);
        Flags := 0;
        Flags := Flags - faReadOnly;
        Flags := Flags - faHidden;
        Flags := Flags - faSysFile;
        Flags := Flags - faArchive;
        Flags := Flags + faAnyFile;
        SetFileAttributes(PChar(FileName),Flags);
    end;
var
    SR      : TSearchRec;
    FindRes : Integer;
    vn      : pchar;
    ret     : integer;
begin
    FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
    (* *)
    inc(DirCount);
    (* *)
    While FindRes=0 do
    begin

        if ScanStopped then exit;

        if ((SR.Attr and faDirectory)=faDirectory) and
        ((SR.Name='.')or(SR.Name='..')) then
        begin
            FindRes:=FindNext(SR);
            Continue;
        end;

        if MainForm.Options.ScanInSubDirectories then
            if ((SR.Attr and faDirectory)=faDirectory) then
            begin
                ScanDir(Dir+SR.Name+'\');
                FindRes:=FindNext(SR);
                Continue;
            end;

        if FileExists(Dir+SR.Name) then
        if InExtList(SR.Name) then
        begin
            (* *)
            if ScanStopped then exit;
            try
                try
                    FileName := sts_format_name(Dir + SR.Name);
                except
                end;
                UnArchName := '';
                inc(scanned);
                inc(FullScanned);
                Synchronize(UpdateProgress);
                (* *)
                ret := sts_matchfile(ENGINE, pchar(Dir+SR.Name), vn, ScanProgress, ScanDebug,true);
                (* *)
                if ret = sts_VIRUS then begin
                    inc(Infected);

                    setlength(ScanForm.VirusList, Infected + 1);
                    ScanForm.VirusList[Infected-1].virname := vn;
                    ScanForm.VirusList[Infected-1].path := dir+sr.Name;
                    ScanForm.VirusList[Infected-1].deleted := false;
                    (* *)
                    if MainForm.Options.UnloadInfected then
                          MainForm.KillProcess(Dir+SR.Name);
                    (* *)
                    if MainForm.Options.Remove then begin
                        if SmartDeleteFile(pChar(Dir+SR.Name)) then begin
                            ADDREP(format('Зараженный файл удален (%s): %s',[vn, Dir+SR.Name]), clGreen);
                            ScanForm.VirusList[Infected-1].deleted := true;
                        end
                        else
                            ADDREP(format('Неудалось удалить зараженный файл (%s): %s',[vn, Dir+SR.Name]), clMaroon);
                    end;
                    (* *)
                    if MainForm.Options.MoveToQuarantine then begin
                        if not DirectoryPresent(MainForm.Options.QuarantinePath) then
                            CreateDir(MainForm.Options.QuarantinePath);

                        if DirectoryExists(MainForm.Options.QuarantinePath) then begin
                            if CopyFile(pChar(Dir+SR.Name),pChar(MainForm.Options.QuarantinePath+SR.Name), true) then
                            begin
                                (* *)
                                setnormattr(MainForm.Options.QuarantinePath+SR.Name);
                                RenameFile(MainForm.Options.QuarantinePath+SR.Name, MainForm.Options.QuarantinePath+SR.Name+'.$$$('+vn+')$$$');
                                (* *)
                                SmartDeleteFile(pChar(Dir+SR.Name));
                                ADDREP(format('Зараженный файл перемещен в карантин  (%s): %s',[vn, Dir+SR.Name]), clGreen);

                                ScanForm.VirusList[Infected-1].deleted := true;
                            end else
                                ADDREP(format('Неудалось переместить зараженный файл в карантин (%s): %s',[vn, Dir+SR.Name]), clMaroon);
                        end;
                    end;
                    (* *)
                    if MainForm.Options.ReportOnly then
                        ADDREP(format('Заражен (%s): %s',[vn, Dir+SR.Name]), clMaroon);
                end;
                if (ret = sts_EREAD) or (ret = sts_ESIZE) then begin
                    inc(Skipped);
                    ADDREP(format('Пропущен: %s',[Dir+SR.Name]), clBlack);
                end
                else
                    FullSize := FullSize + sts_GetFileSize(Dir + SR.Name);
            (* *)
            except
            end;
        end;
        FindRes:=FindNext(SR);
    end;
    SysUtils.FindClose(SR);
end;

Procedure TAvScanner.SetMaximalFiles(FilesCount: integer);
begin
    Delim := Scanned;
    ScanForm.ProgressBar1.Max := FilesCount - Delim;
    SetProgress := true;
    Synchronize(UpdateProgress);
end;

Procedure TAvScanner.EndProgress;
begin
    ScanForm.ProgressBar1.Max := 100;
    ScanForm.ProgressBar1.Position := ScanForm.ProgressBar1.Max;
    ScanForm.Caption := 'Сканирование - [100%]';
end;

Procedure TAvScanner.ShowError;
begin
    ErrorForm.ErrorMemo.Text := 'Базы Сигнатур небыли загруженны, дальнейшее сканирование невозможно! Пожалуйста, запустите утилиту обновления Баз Сигнатур, или проверьте правильность пути к Базам Сигнатур в настройках программы.';
    ErrorForm.ShowModal;
end;

Procedure TAvScanner.UpdateProgress;
var
    now, max, percent : integer;
begin
    if SetProgress then begin
        ScanForm.ProgressBar1.Position := Scanned - Delim;
        (* *)
        try
            now     := ScanForm.ProgressBar1.Position;
            max     := ScanForm.ProgressBar1.Max;
            percent := round( now / (max / 100) );
        except
            percent := 0;
        end;
        ScanForm.Caption := Format('Сканирование - [%d%%]', [percent]);
        (* *)
    end;
    ScanForm.lbFilesScanned.Caption := Format('Проверено объектов: %d',[FullScanned]);
end;

Procedure TAvScanner.Stop;
begin
    Resume;
    ScanStopped := true;
end;

Procedure TAvScanner.Execute;
var
    i, ret, ts, te, mf, ma : integer;
    vn: pchar;
    Opt: sts_opts_scn;
    FCN: TFileCounter;
    ProcList: ProcessList;
    ProcID: integer;
    ProcPath: string;
    label finish;
begin
    (* get start time *)
    ts := GetTickCount;
    (* Clear results *)
    LastCount   := 0;
    Scanned     := 0;
    DirCount    := 0;
    FullSize    := 0;
    Infected    := 0;
    Skipped     := 0;
    FullScanned := 0;
    FileName    := '';
    UnArchName  := '';
    ScanStopped := false;
    SetProgress := false;
    NeedReboot  := false;
    Filter      := MainForm.Options.FilterString;
    FileProgress:= '';
    (* Set controls *)
    Synchronize(SetCtrlsStart);
    (* Init Engine *)
    ADDREP('Kernel Signature Checker Engine - ' + sts_version, clBlack, true);
    ADDREP('', clBlack);
    ADDREP('Офицальный сайт проекта:'+' 127.0.0.1', clBlack);
    ADDREP('Автор проекта:'+' Балазюк Стас (StalkerSTS)', clBlack);
    ADDREP('eMail:'+' mailto://stasbalazuk@gmail.com', clBlack);
    ADDREP('', clBlack);
    (* Set Options *)
    (* Priority *)
    case MainForm.Options.ScanPriority of
        0 : Self.Priority := tpNormal;
        1 : Self.Priority := tpLower;
    end;
    (* *)
    opt := [];
    if MainForm.Options.ScanOnlyWinPE then
        opt := opt + [sts_scan_pe]
    else begin
        opt := opt + [sts_scan_html, sts_scan_pdf, sts_scan_graphic, sts_scan_pe, sts_scan_other];
    end;
    if MainForm.Options.ScanArchives then begin
        opt := opt + [sts_unpack_rar, sts_unpack_zip];
    end;
    if MainForm.Options.UseXForceScan then begin
        opt := opt + [sts_use_force];
    end;
    mf := (1024 * 1024) * MainForm.Options.FileSizeLimit;
    ma := (1024 * 1024) * MainForm.Options.ArchiveLimit;
    (* *)
    init_engine(ENGINE, @ScanDebug);
    sts_setoptions(ENGINE, opt, mf, ma, pchar(MainForm.Options.TempLocDir));
    (* *)
    if not DirectoryExists(MainForm.Options.TempLocDir) then
        SurePath(MainForm.Options.TempLocDir);
    (* *)
    ADDREP('Загрузка Баз Сигнатур...', clBlack, true);
    ADDREP('', clBlack);
    //sts_unpack_xdb(pchar(MainForm.Options.DataBaseLocDir+'xcr000004.xpb')); //Для теста
    //sts_packing_db(pchar(MainForm.Options.DataBaseLocDir+'sts000001.sts'),PChar('19022018'),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
    sts_load_dbdir(ENGINE,pchar(MainForm.Options.DataBaseLocDir),MainForm.Options.UseUserDataBases);
    ADDREP('', clBlack);
    ADDREP(format('Загружено Сигнатур Вирусов: %d',[sts_sigcount(ENGINE)]), clBlack);
    ADDREP(format('Дата сборки Баз Сигнатур: %s',[sts_db_date(ENGINE)]), clBlack);
    if sts_sigcount(ENGINE) = 0 then begin
        ADDREP('', clBlack);
        ADDREP('ВНИМАНИЕ! Базы Сигнатур небыли загруженны, дальнейшее сканирование невозможно! Пожалуйста, запустите утилиту обновления Баз Сигнатур, или проверьте правильность пути к Базам Сигнатур в настройках программы.', clRed, true);
        (* *)
        Synchronize(ShowError);
        (* *)
        goto finish;
    end else
    if isExpired(sts_db_date(ENGINE)) then begin
        ADDREP('', clBlack);
        ADDREP('ВНИМАНИЕ! Дата сборки Баз Сигнатур устарела. Необходимо произвести обновление Баз Сигнатур и произвести полную проверку...', clRed, true);
    end;
    ADDREP('', clBlack);
    ADDREP(format('Сканирование запущено в %s', [FormatDateTime('hh:mm:ss dd.mm.yy',now)]), clBlack, true);
    ADDREP('', clBlack);
    (* Set file scan count *)
    FCN         := TFileCounter.Create(true);
    FCN.Dirs    := Dirs;
    FCN.Scanner := Pointer(Self);
    FCN.Resume;
    (* Scanning *)
    ScanForm.btPause.Enabled := true;
    (* *)
    try
    (* Print InVisible in ProcessList *)
        if Memscan then begin
            ProcList := ProcessList.Create;
            sts_getprocesslist(ProcList);
            (* *)
            for i := 0 to ProcList.Count - 1 do begin
                ProcID := PProcessRecord(ProcList[i]).ProcessId;
                ProcPath := sts_getpathbyPID(ProcID);
                if sts_IsFileHiden(sts_getpathbyPID(ProcID)) then
                    ADDREP(format('Подозрительный процесс [PID %d]: %s',[ProcID, ProcPath]), $000036C6)
                else
                if not PProcessRecord(ProcList[i]).IsVisible then
                    ADDREP(format('Возможно скрытый процесс [PID %d]: %s',[ProcID, ProcPath]), clRed);
            end;
            (* *)
            sts_freeprocesslist(ProcList);
        end;
    (* *)
        i := 0;
        while i < Dirs.Count do begin
        
            if ScanStopped then break;
            
            if FileExists(Dirs[i]) and InExtList(ExtractFileName(Dirs[i])) then
            begin
                inc(scanned);
                inc(FullScanned);
                Synchronize(UpdateProgress);
                try
                    FileName := sts_format_name(Dirs[i]);
                except
                end;
                (* *)
                ret := sts_matchfile(ENGINE, pchar(Dirs[i]), vn, ScanProgress, ScanDebug,true);
                (* *)
                if ret = sts_VIRUS then begin
                    inc(Infected);

                    setlength(ScanForm.VirusList, Infected);
                    ScanForm.VirusList[Infected-1].virname := vn;
                    ScanForm.VirusList[Infected-1].path := dirs[i];
                    ScanForm.VirusList[Infected-1].deleted := false;
                    (* *)
                    if MainForm.Options.UnloadInfected then
                          MainForm.KillProcess(Dirs[i]);
                    (* *)
                    if MainForm.Options.Remove then begin
                        if SmartDeleteFile(pChar(Dirs[i])) then begin
                            ADDREP(format('Зараженный файл удален (%s): %s',[vn, Dirs[i]]), clGreen);
                            ScanForm.VirusList[Infected-1].deleted := true;
                        end
                        else
                            ADDREP(format('Неудалось удалить зараженный файл (%s): %s',[vn, Dirs[i]]), clMaroon);
                    end;
                    (* *)
                    if MainForm.Options.MoveToQuarantine then begin
                        if not DirectoryPresent(MainForm.Options.QuarantinePath) then
                            CreateDir(MainForm.Options.QuarantinePath);

                        if DirectoryExists(MainForm.Options.QuarantinePath) then begin
                            if CopyFile(pChar(Dirs[i]),pChar(MainForm.Options.QuarantinePath+ExtractFileName(Dirs[i])), true) then
                            begin
                                SmartDeleteFile(pChar(Dirs[i]));
                                ADDREP(format('Зараженный файл перемещен в карантин  (%s): %s',[vn, Dirs[i]]), clGreen);

                                ScanForm.VirusList[Infected-1].deleted := true;
                            end else
                                ADDREP(format('Неудалось переместить зараженный файл в карантин (%s): %s',[vn, Dirs[i]]), clMaroon);
                        end;
                    end;
                    (* *)
                    if MainForm.Options.ReportOnly then
                        ADDREP(format('Заражен (%s): %s',[vn, Dirs[i]]), clMaroon);
                end;
                if (ret = sts_EREAD) or (ret = sts_ESIZE) then begin
                    inc(Skipped);
                    ADDREP(format('Пропущен: %s',[Dirs[i]]), clBlack);
                end
                else
                    FullSize := FullSize + sts_GetFileSize(Dirs[i]);
            end else
                if DirectoryExists(Dirs[i]) then
                    ScanDir(Dirs[i]);

            inc(i);
        end;
    (* *)
    except
    end;
    (* finish label *)
    finish:
    (* get end time *)
    te := GetTickCount;
    (* Set output info *)
    ADDREP('', clBlack);
    case ScanStopped of
        True  : begin
                    ADDREP('Сканирование было прервано пользователем', clRed, true);
                end;
        False : begin
                    ADDREP('Сканирование завершено', clBlack, true);
                end;
    end;
    ADDREP(format('Файлов проверено (в том числе в архивах): %d/%d',[Scanned, FullScanned]), clBlack);
    ADDREP(format('Директорий проверено: %d', [DirCount]), clBlack);
    ADDREP(format('Файлов пропущено: %d',[Skipped]), clBlack);
    ADDREP(format('Объем проверенных данных: %s', [BytesToMegaBytes(FullSize)]), clBlack);
    ADDREP(format('Времени затрачено: %s', [MsToStr(te-ts)]), clBlack);
    ADDREP('', clBlack);
    if Infected = 0 then
        ADDREP(format('Заражено файлов: %d', [Infected]), clGreen, true)
        else
        ADDREP(format('Заражено файлов: %d', [Infected]), clMaroon, true);
    ADDREP('', clBlack);
    (* Need System Reboot *)
    if NeedReboot then begin
        if MainForm.Options.Remove then
            ADDREP('Внимание! В процессе сканирования часть зараженных файлов небыла удалена. Для их удаления требуется перезагрузка Windows.', clRed, true)
        else
        if MainForm.Options.MoveToQuarantine then
            ADDREP('Внимание! Для завершения сканирования требуется перезагрузка Windows.', clRed, true)
    end;
    (* free engine *)
    Dirs.Free;
    try
        FCN.Free;
    except
    end;
    free_engine(ENGINE);
    FreeMem(ENGINE);
    (* Set controls *)
    Synchronize(EndProgress);
    Synchronize(SetCtrlsEnd);    
    (* *)
    Free;
end;
(******************************************************************************)
{$R *.dfm}

procedure TScanForm.AddLineToReport(AText: string; AColor: TColor; bold: boolean = false);
begin
    with ReportMemo do
    begin
        SelStart := Length(ReportMemo.Text);
        SelAttributes.Color := AColor;
        SelAttributes.Size := 8;
        if bold then
            SelAttributes.Style := SelAttributes.Style + [fsBold];
        Lines.Add(AText);
    end;
    (* Write Line To Report File *)
    if not DirectoryExists(ExtractFilePath(MainForm.Options.ReportLocFile)) then
        PrepareToSave(MainForm.Options.ReportLocFile);

    sts_writeline(pchar(MainForm.Options.ReportLocFile), pchar(AText));
    (* *)
end;

procedure TScanForm.btStopClick(Sender: TObject);
begin
    case btStop.Tag of
        0 : if Assigned(Scanner) then
                Scanner.Stop;
        1 : begin
                if MainForm.ScanFromParams then
                    MainForm.Close
                else
                    Close;
            end;
    end;
end;

procedure TScanForm.btSaveReportClick(Sender: TObject);
begin
    if SaveDialog1.Execute then begin
        ReportMemo.Lines.SaveToFile(SaveDialog1.FileName);
    end;
end;

procedure TScanForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    finalize(VirusList);
    MainForm.Show;
end;

procedure TScanForm.FormCreate(Sender: TObject);
var
    mask: Word;
begin
    try
        mask := SendMessage(ReportMemo.Handle, EM_GETEVENTMASK, 0, 0);
        SendMessage(ReportMemo.Handle, EM_SETEVENTMASK, 0, mask or ENM_LINK);
        SendMessage(ReportMemo.Handle, EM_AUTOURLDETECT, Integer(True), 0);

        Animate1.ResName := 'ANIM';
        //Animate1.Active := True;
    except
    end;
end;

procedure TScanForm.btPauseClick(Sender: TObject);
begin
    if Assigned(Scanner) then begin
        if not Scanner.Suspended then begin
            Scanner.Suspend;
            btPause.Caption := 'Возобновить';
        end
        else begin
            Scanner.Resume;
            btPause.Caption := 'Пауза';
        end;
    end;
end;

procedure TScanForm.CloseTimerTimer(Sender: TObject);
begin
    if CloseTick <= -1 then begin
        MainForm.Close;
    end;
    btStop.Caption := 'Закрыть ('+inttostr(CloseTick)+')';
    Dec(CloseTick);
end;

procedure TScanForm.FormShow(Sender: TObject);
begin
    lbFilesScanned.Caption := Format('Проверено объектов: %d',[0]);
    ScanForm.Caption := 'Сканирование...';
end;

end.
