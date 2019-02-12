unit sts_processlist;

interface

uses Windows, SysUtils, Classes, TlHelp32, PsApi;

  type
 (* *)
  NTStatus = cardinal;
  
  PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
      Length: Word;
      MaximumLength: Word;
      Buffer: PWideChar;
  end;

  PPROCESS_BASIC_INFORMATION = ^PROCESS_BASIC_INFORMATION;
  PROCESS_BASIC_INFORMATION = packed record
      ExitStatus: BOOL;
      PebBaseAddress: pointer;
      AffinityMask: PULONG;
      BasePriority: dword;
      UniqueProcessId: ULONG;
      InheritedFromUniqueProcessId: ULONG;
  end;

  PSYSTEM_HANDLE_INFORMATION = ^SYSTEM_HANDLE_INFORMATION;
  SYSTEM_HANDLE_INFORMATION = packed record
      ProcessId: dword;
      ObjectTypeNumber: byte;
      Flags: byte;
      Handle: word;
      pObject: pointer;
      GrantedAccess: dword;
  end;

  PSYSTEM_HANDLE_INFORMATION_EX = ^SYSTEM_HANDLE_INFORMATION_EX;
  SYSTEM_HANDLE_INFORMATION_EX = packed record
      NumberOfHandles: dword;
      Information: array [0..0] of SYSTEM_HANDLE_INFORMATION;
  end;

 (* *)
  ProcessList = TList;
 (* *)
  PProcessRecord = ^ProcessRecord;
  ProcessRecord = record
      ProcessId: dword;
      ProcessName: pchar;
      IsVisible: boolean;
  end;
 (* *)
  Function ZwQuerySystemInformation(ASystemInformationClass: dword;
                                    ASystemInformation: Pointer;
                                    ASystemInformationLength: dword;
                                    AReturnLength:PCardinal): NTStatus;
                                    stdcall;external 'ntdll.dll';
  (* *)
  Function ZwQueryInformationProcess(ProcessHandle:THANDLE;
                                     ProcessInformationClass:DWORD;
                                     ProcessInformation:pointer;
                                     ProcessInformationLength:ULONG;
                                     ReturnLength: PULONG):NTStatus;stdcall;
                                     external 'ntdll.dll';
 (* *)
   function DbgUiConnectToDbg(): NTStatus;stdcall;external 'ntdll.dll';
   function DbgUiDebugActiveProcess(pHandle: dword): NTStatus;stdcall;external 'ntdll.dll';
 (* *)
   procedure sts_getprocesslist(var List: ProcessList);
   procedure sts_getmoduleslist(ProcessID: DWORD; ModulesList: TStrings);
   procedure sts_freeprocesslist(var ProcList: ProcessList);

   function sts_getpathbyPID(pid: dword): widestring;
   function sts_GetNameByPid(Pid: dword): widestring;
   function sts_GetFileSize(FileName: String):int64;
   function sts_IsFileHiden(FileName: String): boolean;
   function sts_IsPathHiden(FileName: String): boolean;
   function sts_IsFileSystem(FileName: String): boolean;
   function sts_normalizepath(path: string): string;

   function EnableDebugPrivilege():Boolean;
   function EnableDebugPrivilegeEx(Process: dword):Boolean;

   function sts_EnableDebugPrivilege(Const Value: Boolean): Boolean;
implementation
(* *)
function SysDir: string;
var
  	buf: packed array [0..4095] of Char;
begin
	  GetWindowsDirectory(buf,4096);
  	Result:=StrPas(buf);
	  Result:=buf+'\system32\';
end;

function WinDir: string;
var
  	buf: packed array [0..4095] of Char;
begin
	  GetWindowsDirectory(buf,4096);
  	Result:=StrPas(buf)+'\';
end;

function sts_normalizepath(path: string): string;
var
    _path: string;
begin
    result := path;
    if FileExists(path) then exit;
    (* *)
    _path := path;
    (* *)
    if pos('\??\', _path) <> 0 then begin
        delete(_path, pos('\??\', _path), 4);
        Result := _path;
        if FileExists(path) then exit;
    end;
    (* *)
    if pos('\SystemRoot\', _path) = 1 then begin
        delete(_path, 1, 12);
        _path := WinDir + _path;
        Result := _path;
        if FileExists(path) then exit;
    end;
end;
(* *)
function sts_GetFileSize(FileName: String):int64;
var
    Fl: TFileStream;
begin
    try
    if FileExists(FileName) then begin
       Fl := TFileStream.Create(FileName, fmShareDenyNone);
       Result := Fl.Size;
       Fl.Free;
    end;
    except
        Result := 0;
    end;
end;
(* *)
function sts_FixProcessPath(PPath: String): String;
begin
    if PPath = '?' then begin
        Result := '';
        Exit;
    end;
    if Pos('\??\',PPath) <> 0 then begin
        Result := Copy(PPath,5,length(PPath));
    end else Result := PPath;
end;
(* *)
Function sts_GetInfoTable(ATableType:dword):Pointer;
const
    STATUS_SUCCESS              = NTStatus($00000000);
    STATUS_ACCESS_DENIED        = NTStatus($C0000022);
    STATUS_INFO_LENGTH_MISMATCH = NTStatus($C0000004);
    SEVERITY_ERROR              = NTStatus($C0000000);
var
    mSize: dword;
    mPtr: pointer;
    St: NTStatus;
begin
    Result := nil;
    mSize := $4000;
    repeat
        mPtr := VirtualAlloc(nil, mSize, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
        if mPtr = nil then Exit;
        St := ZwQuerySystemInformation(ATableType, mPtr, mSize, nil);
        if St = STATUS_INFO_LENGTH_MISMATCH then
        begin
            VirtualFree(mPtr, 0, MEM_RELEASE);
            mSize := mSize * 2;
        end;
    until St <> STATUS_INFO_LENGTH_MISMATCH;
    if St = STATUS_SUCCESS then Result := mPtr
    else VirtualFree(mPtr, 0, MEM_RELEASE);
end;

function sts_GetNameByPid(Pid: dword): widestring stdcall;
const
    STATUS_SUCCESS              = NTStatus($00000000);
    STATUS_ACCESS_DENIED        = NTStatus($C0000022);
    STATUS_INFO_LENGTH_MISMATCH = NTStatus($C0000004);
    SEVERITY_ERROR              = NTStatus($C0000000);
var
    hProcess, Bytes: dword;
    Info: PROCESS_BASIC_INFORMATION;
    ProcessParametres: pointer;
    ImagePath: TUnicodeString;
    ImgPath: array[0..MAX_PATH] of WideChar;
begin
    Result := '';
    ZeroMemory(@ImgPath, MAX_PATH * SizeOf(WideChar));
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, Pid);
    if ZwQueryInformationProcess(hProcess, 0, @Info,
                                 SizeOf(PROCESS_BASIC_INFORMATION), nil) = STATUS_SUCCESS then
    begin
        if ReadProcessMemory(hProcess, pointer(dword(Info.PebBaseAddress) + $10),
                             @ProcessParametres, SizeOf(pointer), Bytes) and
        ReadProcessMemory(hProcess, pointer(dword(ProcessParametres) + $38),
                             @ImagePath, SizeOf(TUnicodeString), Bytes)  and
        ReadProcessMemory(hProcess, ImagePath.Buffer, @ImgPath, ImagePath.Length, Bytes) then
        begin
            Result := ExtractFileName(WideCharToString(ImgPath));
        end;
    end;
    CloseHandle(hProcess);
end;

procedure sts_freeprocesslist(var ProcList: ProcessList) stdcall;
var
    i: integer;
begin
    for i := 0 to ProcList.Count-1 do begin
        StrDispose(PProcessRecord(ProcList[i]).ProcessName);
        Dispose(PProcessRecord(ProcList[i]));
    end;

    ProcList.Free;
end;

function sts_ExistsInProcessList(ProcList: ProcessList; Item: PProcessRecord): boolean;
var
    i: integer;
begin
    Result := False;
    for i := 0 to ProcList.Count-1 do
        if ProcList.Items[i] = Item then begin
            result := true;
            break;
        end;
end;

function sts_PathExists(ProcList: ProcessList; PId: dword): boolean;
var
    i: integer;
    Path: String;
begin
    Result := False;
    Path   := LowerCase(sts_GetNameByPid(PId));
    for i := 0 to ProcList.Count-1 do
        if LowerCase(sts_GetNameByPid(PProcessRecord(ProcList.Items[i]).ProcessId)) = Path
        then begin
            result := true;
            break;
        end;
end;

function PIdExists(ProcList: ProcessList; PId: dword): boolean;
var
    i: integer;
begin
    Result := False;
    for i := 0 to ProcList.Count-1 do
        if PProcessRecord(ProcList.Items[i]).ProcessId = PId then begin
            result := true;
            break;
        end;
end;

procedure DeleteItem(var ProcList: ProcessList; ItemId: dword);
begin
    StrDispose(PProcessRecord(ProcList[itemid]).ProcessName);
    Dispose(PProcessRecord(ProcList[itemid]));
end;
(* *)
procedure GetStandartProcessList(var ProcList: ProcessList);
var
    Snap: dword;
    Process: TPROCESSENTRY32;
    NewItem: PProcessRecord;
begin
    Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if Snap <> INVALID_HANDLE_VALUE then
    begin
        Process.dwSize := SizeOf(TPROCESSENTRY32);
        if Process32First(Snap, Process) then
        repeat
            GetMem(NewItem, SizeOf(ProcessRecord));
            ZeroMemory(NewItem, SizeOf(ProcessRecord));
            NewItem^.IsVisible  := True;
            NewItem^.ProcessId  := Process.th32ProcessID;
            NewItem^.ProcessName := StrNew(Process.szExeFile);
            ProcList.Add(NewItem);
        until not Process32Next(Snap, Process);
        CloseHandle(Snap);
    end;
end;
(* *)
procedure GetHandleProcessList(var ProcList: ProcessList);
var
    NewItem: PProcessRecord;
    hProcess: cardinal;
    PId: dword;
    i: integer;
    path: string;
begin
    i := -32000;
    While i < 32000 do begin
        hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, i);
        if hProcess > 0 then begin
            PId := i;
            CloseHandle(hProcess);
            if not sts_PathExists(ProcList,PId) then
            begin
                path := ExtractFileName(sts_GetNameByPid(PId));
                if path <> '' then begin
                    GetMem(NewItem, SizeOf(ProcessRecord));
                    ZeroMemory(NewItem, SizeOf(ProcessRecord));
                    NewItem^.ProcessId  := PId;
                    NewItem^.ProcessName := StrNew(pchar(path));
                    ProcList.Add(NewItem);
                end;
            end;
        end else CloseHandle(hProcess);
        inc(i);
    end;
end;
(* *)
procedure sts_GetOpenWindowsPrecesses(var ProcList: ProcessList);
    procedure ListWindows(zHandle: HWND);
    var
        iSize : Integer;
        PId: dWord;
        NewItem: PProcessRecord;
        path: string;
    begin
        while zHandle <> 0 do
        begin
            GetWindowThreadProcessId(zHandle, PID);
            (* *)
            if not PIdExists(ProcList, PId) then begin
                path := ExtractFileName(sts_GetNameByPid(PId));
                if path <> '' then begin
                    GetMem(NewItem, SizeOf(ProcessRecord));
                    ZeroMemory(NewItem, SizeOf(ProcessRecord));
                    NewItem^.ProcessId  := PId;
                    NewItem^.ProcessName := StrNew(pchar(path));
                    ProcList.Add(NewItem);
                end;
            end;
            ListWindows(GetWindow(zHandle, GW_CHILD));
            (* *)
            zHandle := GetNextWindow(zHandle, GW_HWNDNEXT);
        end;
    end;
begin
    ListWindows(GetDeskTopWindow);
end;
(* *)
procedure sts_GetOpenHandlesProcessList(var ProcList: ProcessList);
var
    Info: PSYSTEM_HANDLE_INFORMATION_EX;
    NewItem: PProcessRecord;
    r: dword;
    OldPid: dword;
begin
    OldPid := 0;
    Info := sts_GetInfoTable(16);
    if Info = nil then Exit;
    for r := 0 to Info^.NumberOfHandles do
        if Info^.Information[r].ProcessId <> OldPid then
        begin
            OldPid := Info^.Information[r].ProcessId;
            GetMem(NewItem, SizeOf(ProcessRecord));
            ZeroMemory(NewItem, SizeOf(ProcessRecord));
            NewItem^.ProcessId  := OldPid;
            NewItem^.ProcessName := StrNew(pChar(ExtractFileName(sts_GetNameByPid(OldPid))));
            ProcList.Add(NewItem);
        end;
    VirtualFree(Info, 0, MEM_RELEASE);
end;
(* *)
Procedure sts_MakeVisible(Source: ProcessList; var Dest: ProcessList);
var
    i: integer;
begin
    for i := 0 to Dest.Count-1 do
        if not PIdExists(Source, PProcessRecord(Dest[i]).ProcessId) then
            PProcessRecord(Dest[i]).IsVisible := false
            else
            PProcessRecord(Dest[i]).IsVisible := true;
end;
(* *)
Procedure sts_BuildProcessList(Source: ProcessList; var Dest: ProcessList);
var
    i: integer;
    NewItem: PProcessRecord;
begin
    for i := 0 to Source.Count-1 do
        if not PIdExists(Dest, PProcessRecord(Source[i]).ProcessId) then
        begin
            GetMem(NewItem, SizeOf(ProcessRecord));
            ZeroMemory(NewItem, SizeOf(ProcessRecord));
            NewItem^.ProcessId  := PProcessRecord(Source[i]).ProcessId;
            NewItem^.ProcessName := StrNew(PProcessRecord(Source[i]).ProcessName);
            NewItem^.IsVisible  := PProcessRecord(Source[i]).IsVisible;
            Dest.Add(NewItem);
        end;
end;
(* *)
function sts_getpathbyPID(pid: dword) : widestring stdcall;
var
    cb: DWORD;
    hMod: HMODULE;
    hProcess: cardinal;
    ModuleName: array [0..300] of Char;
begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, Pid);
    if (hProcess <> 0) then
    begin
        EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
        GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
        Result := sts_FixProcessPath(ModuleName);
    end;
    CloseHandle(hProcess);
end;
(* *)
procedure sts_getmoduleslist(ProcessID: DWORD; ModulesList: TStrings) stdcall;
var
    SnapProcHandle: THandle;
    ModuleEntry: TModuleEntry32;
    Next: Boolean;
    ImageBase: DWORD;
    FProcess_Cnt, FThreads_Cnt, FModules_Cnt, FModules_Size: LongWord;
begin
    try
        FModules_Cnt := 0;
        FModules_Size := 0;
        SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, ProcessID);
        if SnapProcHandle <> THandle(-1) then
        begin
            ModuleEntry.dwSize := Sizeof(ModuleEntry);
            Next := Module32First(SnapProcHandle, ModuleEntry);
            while Next do
            begin
                with ModuleEntry do
                begin
                    ModulesList.Add(szExePath);
                    Inc(FModules_Cnt);
                    Inc(FModules_Size, modBaseSize);
                end;
                Next := Module32Next(SnapProcHandle, ModuleEntry);
            end;
            CloseHandle(SnapProcHandle);
        end;
    finally
    end;
end;
(* *)
function sts_IsPathHiden(FileName: String): boolean;
var
    Flags: cardinal;
begin
    Flags := 0;
    Flags := FileGetAttr(FileName);
    if (flags and fahidden) = faHidden then
        result := true
    else
        result := false;
end;
(* *)
function sts_IsFileSystem(FileName: String): boolean;
var
    Flags: cardinal;
begin
    if not FileExists(FileName) then begin
        Result := False;
        Exit;
    end;
    Flags := 0;
    Flags := FileGetAttr(FileName);
    if (flags and faSysFile) = faSysFile then
        result := true
    else
        result := false;
end;
(* *)
function sts_IsFileHiden(FileName: String): boolean;
var
    Flags: cardinal;
begin
    if not FileExists(FileName) then begin
        Result := False;
        Exit;
    end;
    Flags := 0;
    Flags := FileGetAttr(FileName);
    if (flags and fahidden) = faHidden then
        result := true
    else
        result := false;
end;
(* *)
procedure sts_getprocesslist(var List: ProcessList) stdcall;
var
    NormPL   : ProcessList;
    HandlePL : ProcessList;
    HandlsPL : ProcessList;
    WindowPL : ProcessList;
begin
    NormPL   := ProcessList.Create;
    HandlePL := ProcessList.Create;
    HandlsPL := ProcessList.Create;
    WindowPL := ProcessList.Create;
    (* *)
    GetStandartProcessList(NormPL);
    GetHandleProcessList(HandlePL);
    sts_GetOpenHandlesProcessList(HandlsPL);
    sts_GetOpenWindowsPrecesses(WindowPL);
    (* *)
    sts_MakeVisible(NormPL, HandlePL);
    sts_MakeVisible(NormPL, HandlsPL);
    sts_MakeVisible(NormPL, WindowPL);
    (* *)
    sts_BuildProcessList(NormPL, List);
    sts_BuildProcessList(HandlePL, List);
    sts_BuildProcessList(HandlsPL, List);
    sts_BuildProcessList(WindowPL, List);
    (* *)
    sts_freeprocesslist(HandlePL);
    sts_freeprocesslist(HandlsPL);
    sts_freeprocesslist(WindowPL);
    sts_freeprocesslist(NormPL);
end;
(* *)
function EnablePrivilegeEx(Process: dword; lpPrivilegeName: PChar):Boolean;
var
    hToken: dword;
    NameValue: Int64;
    tkp: TOKEN_PRIVILEGES;
    ReturnLength: dword;
begin
    Result:=false;
    OpenProcessToken(Process, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
    if not LookupPrivilegeValue(nil, lpPrivilegeName, NameValue) then
    begin
        CloseHandle(hToken);
        exit;
    end;
    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Luid := NameValue;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, false, tkp, SizeOf(TOKEN_PRIVILEGES), tkp, ReturnLength);
    if GetLastError() <> ERROR_SUCCESS then
    begin
        CloseHandle(hToken);
        exit;
    end;
    Result:=true;
    CloseHandle(hToken);
end;
(* *)
function EnableDebugPrivilegeEx(Process: dword):Boolean;
begin
    Result := EnablePrivilegeEx(Process, 'SeDebugPrivilege');
end;
(* *)
function EnableDebugPrivilege():Boolean;
begin
    Result := EnablePrivilegeEx(INVALID_HANDLE_VALUE, 'SeDebugPrivilege');
end;

Function sts_EnableDebugPrivilege(Const Value: Boolean): Boolean;
Const
SE_DEBUG_NAME = 'SeDebugPrivilege';
Var
hToken : THandle;
tp : TOKEN_PRIVILEGES;
d : DWORD;
Begin
Result := False;
If OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken) Then
   Begin
     tp.PrivilegeCount := 1;
     LookupPrivilegeValue(Nil, SE_DEBUG_NAME, tp.Privileges[0].Luid);
     If Value Then
       tp.Privileges[0].Attributes := $00000002
     Else
       tp.Privileges[0].Attributes := $80000000;
     AdjustTokenPrivileges(hToken, False, tp, SizeOf(TOKEN_PRIVILEGES), Nil, d);
     If GetLastError = ERROR_SUCCESS Then
       Begin
         Result := True;
       End;
     CloseHandle(hToken);
   End;
End;
(* *)
initialization
    EnableDebugPrivilege();
end.
