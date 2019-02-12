unit uOpenDesc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, ExtCtrls, ShellAPI, ComCtrls, sts_processlist;
(******************************************************************************)
type
NT_STATUS = Cardinal;

TFileDirectoryInformation = packed record
   NextEntryOffset: ULONG;
   FileIndex: ULONG;
   CreationTime: LARGE_INTEGER;
   LastAccessTime: LARGE_INTEGER;
   LastWriteTime: LARGE_INTEGER;
   ChangeTime: LARGE_INTEGER;
   EndOfFile: LARGE_INTEGER;
   AllocationSize: LARGE_INTEGER;
   FileAttributes: ULONG;
   FileNameLength: ULONG;
   FileName: array[0..0] of WideChar;
end;
FILE_DIRECTORY_INFORMATION = TFileDirectoryInformation;
PFileDirectoryInformation = ^TFileDirectoryInformation;
PFILE_DIRECTORY_INFORMATION = PFileDirectoryInformation;

PSYSTEM_THREADS = ^SYSTEM_THREADS;
SYSTEM_THREADS  = packed record
   KernelTime: LARGE_INTEGER;
   UserTime: LARGE_INTEGER;
   CreateTime: LARGE_INTEGER;
   WaitTime: ULONG;
   StartAddress: Pointer;
   UniqueProcess: DWORD;
   UniqueThread: DWORD;
   Priority: Integer;
   BasePriority: Integer;
   ContextSwitchCount: ULONG;
   State: Longint;
   WaitReason: Longint;
end;

PSYSTEM_PROCESS_INFORMATION = ^SYSTEM_PROCESS_INFORMATION;
SYSTEM_PROCESS_INFORMATION = packed record
   NextOffset: ULONG;
   ThreadCount: ULONG;
   Reserved1: array [0..5] of ULONG;
   CreateTime: FILETIME;
   UserTime: FILETIME;
   KernelTime: FILETIME;
   ModuleNameLength: WORD;
   ModuleNameMaxLength: WORD;
   ModuleName: PWideChar;
   BasePriority: ULONG;
   ProcessID: ULONG;
   InheritedFromUniqueProcessID: ULONG;
   HandleCount: ULONG;
   Reserved2 : array[0..1] of ULONG;
   PeakVirtualSize : ULONG;
   VirtualSize : ULONG;
   PageFaultCount : ULONG;
   PeakWorkingSetSize : ULONG;
   WorkingSetSize : ULONG;
   QuotaPeakPagedPoolUsage : ULONG;
   QuotaPagedPoolUsage : ULONG;
   QuotaPeakNonPagedPoolUsage : ULONG;
   QuotaNonPagedPoolUsage : ULONG;
   PageFileUsage : ULONG;
   PeakPageFileUsage : ULONG;
   PrivatePageCount : ULONG;
   ReadOperationCount : LARGE_INTEGER;
   WriteOperationCount : LARGE_INTEGER;
   OtherOperationCount : LARGE_INTEGER;
   ReadTransferCount : LARGE_INTEGER;
   WriteTransferCount : LARGE_INTEGER;
   OtherTransferCount : LARGE_INTEGER;
   ThreadInfo: array [0..0] of SYSTEM_THREADS;
end;

PSYSTEM_HANDLE_INFORMATION = ^SYSTEM_HANDLE_INFORMATION;
SYSTEM_HANDLE_INFORMATION = packed record
   ProcessId: DWORD;
   ObjectTypeNumber: Byte;
   Flags: Byte;
   Handle: Word;
   pObject: Pointer;
   GrantedAccess: DWORD;
end;

PSYSTEM_HANDLE_INFORMATION_EX = ^SYSTEM_HANDLE_INFORMATION_EX;
SYSTEM_HANDLE_INFORMATION_EX = packed record
   NumberOfHandles: dword;
   Information: array [0..0] of SYSTEM_HANDLE_INFORMATION;
end;

PFILE_NAME_INFORMATION = ^FILE_NAME_INFORMATION;
FILE_NAME_INFORMATION = packed record
   FileNameLength: ULONG;
   FileName: array [0..MAX_PATH - 1] of WideChar;
end;

PUNICODE_STRING = ^TUNICODE_STRING;
TUNICODE_STRING = packed record
   Length : WORD;
   MaximumLength : WORD;
   Buffer : array [0..MAX_PATH - 1] of WideChar;
end;

POBJECT_NAME_INFORMATION = ^TOBJECT_NAME_INFORMATION;
TOBJECT_NAME_INFORMATION = packed record
   Name : TUNICODE_STRING;
end;

PIO_STATUS_BLOCK = ^IO_STATUS_BLOCK;
IO_STATUS_BLOCK = packed record
   Status: NT_STATUS;
   Information: DWORD;
end;

PGetFileNameThreadParam = ^TGetFileNameThreadParam;
TGetFileNameThreadParam = packed record
   hFile: THandle;
   Data: array [0..MAX_PATH - 1] of Char;
   Status: NT_STATUS;
end;

const
STATUS_SUCCESS = NT_STATUS($00000000);
STATUS_INVALID_INFO_CLASS = NT_STATUS($C0000003);
STATUS_INFO_LENGTH_MISMATCH = NT_STATUS($C0000004);
STATUS_INVALID_DEVICE_REQUEST = NT_STATUS($C0000010);
ObjectNameInformation = 1;
FileDirectoryInformation = 1;
FileNameInformation = 9;
SystemProcessesAndThreadsInformation = 5;
SystemHandleInformation = 16;

function ZwQuerySystemInformation(ASystemInformationClass: DWORD;
   ASystemInformation: Pointer; ASystemInformationLength: DWORD;
   AReturnLength: PDWORD): NT_STATUS; stdcall; external 'ntdll.dll';

function NtQueryInformationFile(FileHandle: THandle;
   IoStatusBlock: PIO_STATUS_BLOCK; FileInformation: Pointer;
   Length: DWORD; FileInformationClass: DWORD): NT_STATUS;
   stdcall; external 'ntdll.dll';

function NtQueryObject(ObjectHandle: THandle;
   ObjectInformationClass: DWORD; ObjectInformation: Pointer;
   ObjectInformationLength: ULONG;
   ReturnLength: PDWORD): NT_STATUS; stdcall; external 'ntdll.dll';

function GetLongPathNameA(lpszShortPath, lpszLongPath: PChar;
    cchBuffer: DWORD): DWORD; stdcall; external kernel32;
(******************************************************************************)
type
  TOpenDescForm = class(TForm)
    Panel2: TPanel;
    Bevel4: TBevel;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbAutoRunExplorer: TLabel;
    OpenDescExplorer: TVirtualStringTree;
    Panel1: TPanel;
    btClose: TButton;
    btRefresh: TButton;
    pnProgress: TPanel;
    pbProgress: TProgressBar;
    lbDescProgress: TLabel;
    btUnload: TButton;
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure OpenDescExplorerGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure OpenDescExplorerGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure OpenDescExplorerBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect;
      var ContentRect: TRect);
    procedure OpenDescExplorerResize(Sender: TObject);
    procedure OpenDescExplorerMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenDescExplorerDblClick(Sender: TObject);
    procedure btUnloadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
      procedure ShowLockedProcess(FileName: String; VST: TVirtualStringTree; Progress: TProgressBar);
    { Public declarations }
  end;

  TItemType = (itProcess, itUseles);

  PVSTItem = ^TVSTItem;
  TVSTItem = record
      iPID : integer;
      iCaption : string;
      iPath : string;
      iType : TItemType;
      ImageIndex : integer;
  end;

var
  OpenDescForm : TOpenDescForm;
  SysImageList : TImageList;
  pw_x, pw_y   : integer;
implementation

uses uMain, uFileInfo;
function GetSmallIconIndexEx(const AFile: string): integer;
var
    SFI: TSHFileInfo;
    icon: TIcon;
begin
    if not FileExists(AFile) then exit;
    icon := TIcon.Create;
    icon.LoadFromFile(AFile);
    SysImageList.AddIcon(icon);
    Result := SysImageList.Count - 1;
    icon.Free;
end;

function GetSmallIconIndex(const AFile: string; Attrs: DWORD): integer;
var
    SFI: TSHFileInfo;
begin
    SHGetFileInfo(PChar(AFile), Attrs, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX);
    Result := SFI.iIcon;
end; 

function GetRoot(iPID: integer; VST: TVirtualStringTree): PVirtualNode;
var
    node: PVirtualNode;
    data: PVSTItem;
begin
    Result := nil;
    node := VST.GetFirst;
    while node <> nil do begin
        data := VST.GetNodeData(node);
        if data.iPID = iPID then begin
            Result := node;
            exit;
        end;
        node := node.NextSibling;
    end;
end;

procedure AddNewItem(iPID: integer; iCaption, iPath: string; VST: TVirtualStringTree);
    function isBysy(iPath: string) : boolean;
    var
        desc: TFileStream;
    begin
        Result := false;
        try
            {desc := TFileStream.Create(iPath, fmShareDenyNone);
            if desc.Handle = INVALID_HANDLE_VALUE then begin
                result := true;
                exit;
            end
            else
            desc.Free; }
        except
            result := true;
        end;
    end;
var
    root: PVirtualNode;
    node: PVirtualNode;
    data: PVSTItem;
begin
    root := GetRoot(iPID, VST);
    if root = nil then begin
        root := VST.AddChild(VST.RootNode);
        root.CheckType := ctTriStateCheckBox;
        if not (vsInitialized in root.States) then
            VST.ReinitNode(root, False);

        data              := VST.GetNodeData(root);
        data.iCaption     := iCaption;
        data.iPath        := sts_getpathbyPID(iPID);
        data.iPID         := iPID;
        data.iType        := itProcess;
        if FileExists(iPath) then
            data.ImageIndex   := GetSmallIconIndex(data.iPath, 0)
            else
            data.ImageIndex   := -1;
    end;

    node := VST.AddChild(root);
    node.CheckType := ctNone;
    if not (vsInitialized in node.States) then
        VST.ReinitNode(node, False);

    data              := VST.GetNodeData(node);
    data.iCaption     := '';
    data.iPath        := iPath;
    data.iPID         := -1;
    data.iType        := itUseles;
    if FileExists(iPath) and (not isBysy(data.iPath)) then
        data.ImageIndex   := GetSmallIconIndex(data.iPath, 0)
        else
        data.ImageIndex   := GetSmallIconIndexEx(ExtractFilePath(paramstr(0))+'\images\desc_locked.ico');
end;
(******************************************************************************)
procedure TOpenDescForm.ShowLockedProcess(FileName: String; VST: TVirtualStringTree; Progress: TProgressBar);
    function GetInfoTable(ATableType: DWORD): Pointer;
    var
        dwSize: DWORD;
        pPtr: Pointer;
        ntStatus: NT_STATUS;
    begin
        Result := nil;
        dwSize := WORD(-1);
        GetMem(pPtr, dwSize);
        ntStatus := ZwQuerySystemInformation(ATableType, pPtr, dwSize, nil);
        while ntStatus = STATUS_INFO_LENGTH_MISMATCH do
        begin
            dwSize := dwSize * 2;
            ReallocMem(pPtr, dwSize);
            ntStatus := ZwQuerySystemInformation(ATableType, pPtr, dwSize, nil);
        end;
        if ntStatus = STATUS_SUCCESS then
            Result := pPtr
        else
            FreeMem(pPtr);
    end;

    function GetFileNameThread(lpParameters: Pointer): DWORD; stdcall;
    var
        FileNameInfo: FILE_NAME_INFORMATION;
        ObjectNameInfo: TOBJECT_NAME_INFORMATION;
        IoStatusBlock: IO_STATUS_BLOCK;
        pThreadParam: TGetFileNameThreadParam;
        dwReturn: DWORD;
    begin
        ZeroMemory(@FileNameInfo, SizeOf(FILE_NAME_INFORMATION));
        pThreadParam := PGetFileNameThreadParam(lpParameters)^;
        Result := NtQueryInformationFile(pThreadParam.hFile, @IoStatusBlock,
        @FileNameInfo, MAX_PATH * 2, FileNameInformation);
        if Result = STATUS_SUCCESS then
        begin
            Result := NtQueryObject(pThreadParam.hFile, ObjectNameInformation,
            @ObjectNameInfo, MAX_PATH * 2, @dwReturn);
            if Result = STATUS_SUCCESS then
            begin
                pThreadParam.Status := Result;
                WideCharToMultiByte(CP_ACP, 0,
                @ObjectNameInfo.Name.Buffer[ObjectNameInfo.Name.MaximumLength -
                ObjectNameInfo.Name.Length],
                ObjectNameInfo.Name.Length, @pThreadParam.Data[0],
                MAX_PATH, nil, nil);
            end
            else
            begin
                pThreadParam.Status := STATUS_SUCCESS;
                Result := STATUS_SUCCESS;
                WideCharToMultiByte(CP_ACP, 0,
                @FileNameInfo.FileName[0], IoStatusBlock.Information,
                @pThreadParam.Data[0],
                MAX_PATH, nil, nil);
            end;
        end;
        PGetFileNameThreadParam(lpParameters)^ := pThreadParam;
        ExitThread(Result);
    end;

    function GetFileNameFromHandle(hFile: THandle): String;
    var
        lpExitCode: DWORD;
        pThreadParam: TGetFileNameThreadParam;
        hThread: THandle;
    begin
        Result := '';
        ZeroMemory(@pThreadParam, SizeOf(TGetFileNameThreadParam));
        pThreadParam.hFile := hFile;
        hThread := CreateThread(nil, 0, @GetFileNameThread, @pThreadParam, 0, PDWORD(nil)^);
        if hThread <> 0 then
            try
                case WaitForSingleObject(hThread, 100) of
                    WAIT_OBJECT_0:
                    begin
                        GetExitCodeThread(hThread, lpExitCode);
                        if lpExitCode = STATUS_SUCCESS then
                            Result := pThreadParam.Data;
                    end;
                    WAIT_TIMEOUT:
                    TerminateThread(hThread, 0);
                end;
            finally
                CloseHandle(hThread);
            end;
    end;

    function SetDebugPriv: Boolean;
    var
        Token: THandle;
        tkp: TTokenPrivileges;
    begin
        Result := false;
        if OpenProcessToken(GetCurrentProcess,
            TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, Token) then
        begin
            if LookupPrivilegeValue(nil, PChar('SeDebugPrivilege'),
            tkp.Privileges[0].Luid) then
            begin
                tkp.PrivilegeCount := 1;
                tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
                Result := AdjustTokenPrivileges(Token, False,
                tkp, 0, PTokenPrivileges(nil)^, PDWord(nil)^);
            end;
        end;
    end;

    type
    DriveQueryData = record
        DiskLabel: String;
        DiskDosQuery: String;
        DosQueryLen: Integer;
    end;

var
    hFile, hProcess: THandle;
    pHandleInfo: PSYSTEM_HANDLE_INFORMATION_EX;
    I, Drive: Integer;
    ObjectTypeNumber: Byte;
    FileDirectory, FilePath, ProcessName: String;
    SystemInformation, TempSI: PSYSTEM_PROCESS_INFORMATION;
    DosDevices: array [0..25] of DriveQueryData;
    LongFileName, TmpFileName: String;
begin
    VST.Clear;
    SetLength(LongFileName, MAX_PATH);
    GetLongPathNameA(PChar(FileName), @LongFileName[1], MAX_PATH);

    for Drive := 0 to 25 do
    begin
        DosDevices[Drive].DiskLabel := Chr(Drive + Ord('a')) + ':';
        SetLength(DosDevices[Drive].DiskDosQuery, MAXCHAR);
        ZeroMemory(@DosDevices[Drive].DiskDosQuery[1], MAXCHAR);
        QueryDosDevice(PChar(DosDevices[Drive].DiskLabel),
        @DosDevices[Drive].DiskDosQuery[1], MAXCHAR);
        DosDevices[Drive].DosQueryLen := Length(PChar(DosDevices[Drive].DiskDosQuery));
        SetLength(DosDevices[Drive].DiskDosQuery, DosDevices[Drive].DosQueryLen);
    end;

    ObjectTypeNumber := 0;
    SetDebugPriv;
    hFile := CreateFile('NUL', GENERIC_READ, 0, nil, OPEN_EXISTING, 0, 0);
    if hFile = INVALID_HANDLE_VALUE then RaiseLastOSError;
    try
        pHandleInfo := GetInfoTable(SystemHandleInformation);
        if pHandleInfo = nil then RaiseLastOSError;
        try
            for I := 0 to pHandleInfo^.NumberOfHandles - 1 do
                if pHandleInfo^.Information[I].Handle = hFile then
                    if pHandleInfo^.Information[I].ProcessId = GetCurrentProcessId then
                    begin
                        ObjectTypeNumber := pHandleInfo^.Information[I].ObjectTypeNumber;
                        Break;
                    end;
        finally
            FreeMem(pHandleInfo);
        end;
    finally
        CloseHandle(hFile);
    end;

    SystemInformation := GetInfoTable(SystemProcessesAndThreadsInformation);
    if SystemInformation <> nil then
    try
        pHandleInfo := GetInfoTable(SystemHandleInformation);
        if pHandleInfo <> nil then
        try
            Progress.Position := 0;
            Progress.Max := pHandleInfo^.NumberOfHandles;
            for I := 0 to pHandleInfo^.NumberOfHandles - 1 do
            begin
                if pHandleInfo^.Information[I].ObjectTypeNumber = ObjectTypeNumber then
                begin
                    hProcess := OpenProcess(PROCESS_DUP_HANDLE, True,
                    pHandleInfo^.Information[I].ProcessId);
                    if hProcess > 0 then
                    try
                        if DuplicateHandle(hProcess, pHandleInfo^.Information[I].Handle,
                        GetCurrentProcess, @hFile, 0, False, DUPLICATE_SAME_ACCESS) then
                        try
                            if Application.Terminated then Exit;

                            FilePath := GetFileNameFromHandle(hFile);
                            if FilePath <> '' then
                            begin
                                FileDirectory := '';
                                for Drive := 0 to 25 do
                                    if DosDevices[Drive].DosQueryLen > 0 then
                                        if Copy(FilePath, 1, DosDevices[Drive].DosQueryLen) =
                                        DosDevices[Drive].DiskDosQuery then
                                        begin
                                            FileDirectory := DosDevices[Drive].DiskLabel;
                                            Delete(FilePath, 1, DosDevices[Drive].DosQueryLen);
                                            Break;
                                        end;

                                if FileDirectory = '' then Continue;
                                TempSI := SystemInformation;
                                repeat
                                    if TempSI^.ProcessID =
                                    pHandleInfo^.Information[I].ProcessId then
                                    begin
                                        ProcessName := TempSI^.ModuleName;
                                        Break;
                                    end;
                                    TempSI := Pointer(DWORD(TempSI) + TempSI^.NextOffset);
                                until TempSI^.NextOffset = 0;

                                SetLength(TmpFileName, MAX_PATH);
                                GetLongPathNameA(PChar(FileDirectory + FilePath), @TmpFileName[1], MAX_PATH);
                                if FileExists(FileDirectory + FilePath) then
                                    if FileName = '' then
                                        AddNewItem(pHandleInfo^.Information[I].ProcessId, ProcessName, FileDirectory + FilePath, VST)
                                    else
                                        if LowerCase(FileName) = LowerCase(FileDirectory + FilePath) then
                                            AddNewItem(pHandleInfo^.Information[I].ProcessId, ProcessName, FileDirectory + FilePath, VST);
                            end;
                        finally
                            CloseHandle(hFile);
                        end;
                  finally
                      CloseHandle(hProcess);
                  end;
              end;
                  Progress.Position := Progress.Position + 1;
                  Application.ProcessMessages;
              end;
        finally
            FreeMem(pHandleInfo);
        end;
    finally
        FreeMem(SystemInformation);
    end;
end;

procedure KillProcesses(Root: PVirtualNode);
    function Kill_By_Pid(pid : longint) : integer; 
    var
        hProcess : THANDLE;
        TermSucc : BOOL;
    begin
          hProcess := OpenProcess(PROCESS_ALL_ACCESS, true, pid);
          if (hProcess = 0) then 
          begin
              result := -1;
          end
          else
          begin
              TermSucc := TerminateProcess(hProcess, 0);
              if (TermSucc = false) then
              result := -1
              else
              result := 0;
          end;
    end;
var
    Node : PVirtualNode;
    pID  : integer;
begin
    Node := Root;
    if node = nil then exit;
    while Node <> nil do begin
        if Node.CheckState = csCheckedNormal then begin
            if PVSTItem(OpenDescForm.OpenDescExplorer.GetNodeData(Node)).iType = itProcess then
            begin
                pID := PVSTItem(OpenDescForm.OpenDescExplorer.GetNodeData(Node)).iPID;
                Kill_By_Pid(pID);
            end;
        end;
        Node := Node.NextSibling;
    end;
end;
(******************************************************************************)
{$R *.dfm}

procedure TOpenDescForm.btCloseClick(Sender: TObject);
begin
    close;
end;

procedure TOpenDescForm.FormCreate(Sender: TObject);
var
    SysSIL  : THandle;
    SFI     : TSHFileInfo;
begin
    OpenDescExplorer.NodeDataSize := SizeOf(TVSTItem);

    SysImageList := TImageList.Create(self);
    OpenDescExplorer.Images := SysImageList;
    with SysImageList do begin
        Width  := 16;
        Height := 16;
        SysSIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
        if SysSIL <> 0 then begin
            SysImageList.Handle := SysSIL;
            ShareImages := True;
        end;
    end;
end;

procedure TOpenDescForm.btRefreshClick(Sender: TObject);
begin
    OpenDescExplorer.Clear;
    Application.ProcessMessages;
    OpenDescExplorer.BeginUpdate;
    pnProgress.Visible := true;
    ShowLockedProcess('', OpenDescExplorer, pbProgress);
    pnProgress.Visible := false;
    OpenDescExplorer.EndUpdate;
end;

procedure TOpenDescForm.OpenDescExplorerGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
    data      : PVSTItem;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        ImageIndex := data.ImageIndex;
end;

procedure TOpenDescForm.OpenDescExplorerGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
    data: PVSTItem;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
      case data.iType of
          itProcess : CellText := data.iCaption;
          itUseles  : CellText := data.iPath;
      end;
end;

procedure TOpenDescForm.OpenDescExplorerBeforeCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect;
  var ContentRect: TRect);
var
    data: PVSTItem;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(data) then begin
        if data.iType = itUseles then begin
            TargetCanvas.Brush.Color := $009FD9FF;
            TargetCanvas.FillRect(CellRect);
        end;
    end;
end;

procedure TOpenDescForm.OpenDescExplorerResize(Sender: TObject);
begin
    OpenDescExplorer.Header.Columns.Items[0].Width := OpenDescExplorer.Width - 20;
end;

procedure TOpenDescForm.OpenDescExplorerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    pw_x := x;
    pw_y := y;
end;

procedure TOpenDescForm.OpenDescExplorerDblClick(Sender: TObject);
var
    data: PVSTItem;
begin
    if OpenDescExplorer.GetNodeAt(pw_x, pw_y) <> nil then begin
        Data := OpenDescExplorer.GetNodeData(OpenDescExplorer.GetNodeAt(pw_x, pw_y){PathView.GetFirstSelected()});
        if assigned(data) then
        if Data.iType = itUseles then
        if MainForm.DiskInDrive(Data.iPath[1])then
            if FileExists(Data.iPath) then begin
                FileInfoForm.GetInformation(data.iPath);
                FileInfoForm.ShowModal;
            end;
    end;
end;

procedure TOpenDescForm.btUnloadClick(Sender: TObject);
begin
    KillProcesses(OpenDescExplorer.GetFirst);
    btRefresh.OnClick(self);
end;

procedure TOpenDescForm.FormShow(Sender: TObject);
begin
    OpenDescExplorer.Clear;
end;

end.
