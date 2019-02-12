unit uProcessExplorer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, VirtualTrees, sts_processlist, ShellApi;

type
  TProcessExplorerForm = class(TForm)
    Panel2: TPanel;
    Bevel4: TBevel;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbProcessExplorer: TLabel;
    Panel1: TPanel;
    btClose: TButton;
    btRefresh: TButton;
    ProcessExplorer: TVirtualStringTree;
    btUnload: TButton;
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure ProcessExplorerGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure ProcessExplorerGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ProcessExplorerPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure ProcessExplorerResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProcessExplorerDblClick(Sender: TObject);
    procedure ProcessExplorerMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ProcessExplorerBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect;
      var ContentRect: TRect);
    procedure btUnloadClick(Sender: TObject);
    procedure ProcessExplorerFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
  private
    { Private declarations }
  public
    procedure GetProcesslist;
    { Public declarations }
  end;

  TProcessType = (ptProcess, ptModule);

  PVSTProcess = ^TVSTProcess;
  TVSTProcess = record
      ProcessPath : string;
      ProcessId   : integer;
      isVisible   : boolean;
      isHiden     : boolean;
      ProcessType : TProcessType;
      ImageIndex  : integer;
  end;

var
  ProcessExplorerForm: TProcessExplorerForm;
  SysImageList : TImageList;
  pw_x, pw_y : integer;
implementation

uses uFileInfo, uMain;
function GetSmallIconIndex(const AFile: string; Attrs: DWORD): integer;
var
    SFI: TSHFileInfo;
begin
    SHGetFileInfo(PChar(AFile), Attrs, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX);
    Result := SFI.iIcon;
end;

procedure TProcessExplorerForm.GetProcesslist;
var
    list : ProcessList;
    i,j  : integer;

    node : PVirtualNode;
    mdl  : PVirtualNode;
    data : PVSTProcess;

    modules : TStringList;
begin
    ProcessExplorer.Clear;
    list := ProcessList.Create;
    sts_getprocesslist(list);
    (* *)
    for i := 0 to list.Count-1 do begin
            node := ProcessExplorer.AddChild(ProcessExplorer.RootNode);
            node.CheckType := ctTriStateCheckBox;
            if not (vsInitialized in node.States) then
                ProcessExplorer.ReinitNode(node, False);
            (* *)
            data              := ProcessExplorer.GetNodeData(node);
            data.ProcessPath  := PProcessRecord(list[i]).ProcessName;
            data.ProcessId    := PProcessRecord(list[i]).ProcessId;
            data.isVisible    := PProcessRecord(list[i]).IsVisible;
            data.isHiden      := sts_IsFileHiden(sts_normalizepath(sts_getpathbyPID(data.ProcessId)));
            data.ProcessType  := ptProcess;
            data.ImageIndex   := -1;

            if data.ProcessId = 0 then Continue;

            modules           := TStringList.Create;
            sts_getmoduleslist(PProcessRecord(list[i]).ProcessId, modules);
            (* *)
            if modules.Count = 0 then begin
                if not FileExists(sts_getpathbyPID(PProcessRecord(list[i]).ProcessId)) then continue;
                mdl := ProcessExplorer.AddChild(node);
                if not (vsInitialized in mdl.States) then
                    ProcessExplorer.ReinitNode(mdl, False);
                (* *)
                data := ProcessExplorer.GetNodeData(mdl);

                data.ProcessPath  := sts_getpathbyPID(PProcessRecord(list[i]).ProcessId);
                data.ProcessPath  := sts_normalizepath(data.ProcessPath);
                data.isHiden      := sts_IsFileHiden(data.ProcessPath);
                data.ProcessId    := 0;
                data.isVisible    := true;
                data.ProcessType  := ptModule;
                data.ImageIndex   := -1;
            end else
            for j := 0 to modules.Count-1 do begin
                mdl := ProcessExplorer.AddChild(node);

                if not (vsInitialized in mdl.States) then
                    ProcessExplorer.ReinitNode(mdl, False);
                (* *)
                data := ProcessExplorer.GetNodeData(mdl);
                data.ProcessPath  := modules[j];
                data.ProcessPath  := sts_normalizepath(data.ProcessPath);
                data.isHiden      := sts_IsFileHiden(data.ProcessPath);
                data.ProcessId    := 0;
                data.isVisible    := true;
                data.ProcessType  := ptModule;
                data.ImageIndex   := -1;
            end;
            (* *)
            modules.Free;
    end;
    (* *)
    sts_freeprocesslist(list);
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
    Data : PVSTProcess;
    pID  : integer;
begin
    Node := Root;
    if node = nil then exit;
    while Node <> nil do begin
        if Node.CheckState = csCheckedNormal then begin
            if PVSTProcess(ProcessExplorerForm.ProcessExplorer.GetNodeData(Node)).ProcessType = ptProcess then
            begin
                pID := PVSTProcess(ProcessExplorerForm.ProcessExplorer.GetNodeData(Node)).ProcessId;
                Kill_By_Pid(pID);
            end;
        end;
        Node := Node.NextSibling;
    end;
end;
{$R *.dfm}

procedure TProcessExplorerForm.btCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TProcessExplorerForm.FormCreate(Sender: TObject);
var
    SysSIL  : THandle;
    SFI     : TSHFileInfo;
begin
    ProcessExplorer.NodeDataSize := SizeOf(TVSTProcess);

    SysImageList := TImageList.Create(self);
    ProcessExplorer.Images := SysImageList;
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

procedure TProcessExplorerForm.btRefreshClick(Sender: TObject);
begin
    GetProcesslist;
end;

procedure TProcessExplorerForm.ProcessExplorerGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
    data: PVSTProcess;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        case Column of
            0 : CellText := data.ProcessPath;
            1 : if data.ProcessType = ptProcess then CellText := inttostr(data.ProcessId) else CellText := '';
        end;  
end;

procedure TProcessExplorerForm.ProcessExplorerGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
    data      : PVSTProcess;
    FileInfo  : TSHFileInfo;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        if Column = 0 then begin
            if data.ImageIndex = -1 then begin
                case data.ProcessType of
                    ptProcess : Data.ImageIndex := GetSmallIconIndex(sts_normalizepath(sts_getpathbyPID(Data.ProcessId)), 0);
                    ptModule  : Data.ImageIndex := GetSmallIconIndex(Data.ProcessPath, 0);
                end;
                ImageIndex := data.ImageIndex;
            end else
                ImageIndex := data.ImageIndex;
        end;
end;

procedure TProcessExplorerForm.ProcessExplorerPaintText(
  Sender: TBaseVirtualTree; const TargetCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
    data: PVSTProcess;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(data) then begin
        if not data.isVisible then
            TargetCanvas.Font.Color := clRed
        else
            if data.isHiden then
            TargetCanvas.Font.Color := clGray;
    end;
end;

procedure TProcessExplorerForm.ProcessExplorerResize(Sender: TObject);
begin
    ProcessExplorer.Header.Columns.Items[0].Width := ProcessExplorer.Width - 85;
end;

procedure TProcessExplorerForm.FormShow(Sender: TObject);
begin
    GetProcesslist;
end;

procedure TProcessExplorerForm.ProcessExplorerDblClick(Sender: TObject);
var
    data: PVSTProcess;
begin
    if ProcessExplorer.GetNodeAt(pw_x, pw_y) <> nil then begin
        Data := ProcessExplorer.GetNodeData(ProcessExplorer.GetNodeAt(pw_x, pw_y){PathView.GetFirstSelected()});
        if assigned(data) then
        if MainForm.DiskInDrive(Data.ProcessPath[1]) and (Data.ProcessType = ptModule) then
            if FileExists(Data.ProcessPath) then begin
                FileInfoForm.GetInformation(data.ProcessPath);
                FileInfoForm.ShowModal;
            end;
    end;
end;

procedure TProcessExplorerForm.ProcessExplorerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    pw_x := x;
    pw_y := y;
end;

procedure TProcessExplorerForm.ProcessExplorerBeforeCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect;
  var ContentRect: TRect);
var
    data: PVSTProcess;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(data) then begin
        if data.ProcessType = ptModule then begin
            TargetCanvas.Brush.Color := $009FD9FF;
            TargetCanvas.FillRect(CellRect);
        end else
            if not data.isVisible then begin
                TargetCanvas.Brush.Color := $009FBBFD;
                TargetCanvas.FillRect(CellRect);
            end else
            if data.isHiden then begin
                TargetCanvas.Brush.Color := $00CECECE;
                TargetCanvas.FillRect(CellRect);
            end;
    end;
end;

procedure TProcessExplorerForm.btUnloadClick(Sender: TObject);
begin
    KillProcesses(ProcessExplorer.GetFirst);
    GetProcesslist;
end;

procedure TProcessExplorerForm.ProcessExplorerFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
    Data: PVSTProcess;
begin
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        Finalize(Data^);
end;

end.
