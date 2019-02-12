unit uAutoRun;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, ExtCtrls, shellapi, registry, ShlObj, ActiveX, ComObj, sts_processlist;

type

  TItemType = (itHeader, itRoot, itItem, itSubItem);

  PVSTItem = ^TVSTItem;
  TVSTItem = record
      iCaption    : string;
      iPath       : string;
      iRegKey     : string;
      iRoot       : string;
      iParam      : string;
      iEnabled    : boolean;
      iType       : TItemType;
      isHiden     : boolean;
      ImageIndex  : integer;
  end;

  TAutoRunForm = class(TForm)
    Panel2: TPanel;
    Bevel4: TBevel;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbAutoRunExplorer: TLabel;
    Panel1: TPanel;
    btClose: TButton;
    btRefresh: TButton;
    AutoRunExplorer: TVirtualStringTree;
    Procedure RefreshAutoRun;
    Procedure LoadFromReg(Location: String; Root: PVirtualNode);
    Procedure LoadFromDir(Location:string; Root: PVirtualNode);
    procedure AddNewItem(iCaption, iPath, iRegKey, iRoot, iParam: string; ienabled: boolean; root: PVirtualNode);
    procedure AddNewHeaderItem(iCaption: string; iIcon: string; var node : PVirtualNode; var data: PVSTItem);
    Procedure ChangeReg(node: PVirtualNode; booDel:Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AutoRunExplorerGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure AutoRunExplorerGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure AutoRunExplorerPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure AutoRunExplorerResize(Sender: TObject);
    procedure AutoRunExplorerBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect;
      var ContentRect: TRect);
    procedure AutoRunExplorerChecking(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure AutoRunExplorerDblClick(Sender: TObject);
    procedure AutoRunExplorerMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    (* *)

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AutoRunForm: TAutoRunForm;
  iHKLM : PVirtualNode;
  dHKLM : PVSTItem;
  iHKCU : PVirtualNode;
  dHKCU : PVSTItem;

  iCU   : PVirtualNode;
  dCU   : PVSTItem;
  iAU   : PVirtualNode;
  dAU   : PVSTItem;

  SysImageList: TImageList;
  pw_x, pw_y : integer;
implementation

uses uMain, uFileInfo;

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

function GetSmallIconIndex(const AFile: string; Attrs: DWORD): integer;
var
    SFI: TSHFileInfo;
begin
    SHGetFileInfo(PChar(AFile), Attrs, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX);
    Result := SFI.iIcon;
end; 

Procedure TAutoRunForm.RefreshAutoRun;
begin
    AutoRunExplorer.Clear;
    AddNewHeaderItem('HKEY_CURRENT_USER','reg_HKCU.ico', iHKCU, dHKCU);
    AddNewHeaderItem('HKEY_LOCAL_MACHINE','reg_HKLM.ico', iHKLM, dHKLM);

    AddNewHeaderItem('Current User','reg_User.ico', iCU, dCU);
    AddNewHeaderItem('All Users','reg_AllUsers.ico', iAU, dAU);


    LoadFromReg('HKCU', iHKCU);
    LoadFromReg('HKCU_B', iHKCU);
    LoadFromReg('HKCU_S', iHKCU);
    LoadFromReg('HKCU_S_B', iHKCU);
    LoadFromReg('HKLM', iHKLM);
    LoadFromReg('HKLM_B', iHKLM);
    LoadFromReg('HKLM_S', iHKLM);
    LoadFromReg('HKLM_S_B', iHKLM);

    LoadFromDir('CU', iCU);
    LoadFromDir('LM', iAU);
end;
{$R *.dfm}
procedure TAutoRunForm.AddNewHeaderItem(iCaption: string; iIcon: string; var node : PVirtualNode; var data: PVSTItem);
var
    icon: ticon;
begin
    node := AutoRunExplorer.AddChild(AutoRunExplorer.RootNode);
    node.CheckType := ctNone;
    if not (vsInitialized in node.States) then
        AutoRunExplorer.ReinitNode(node, False);
    (* *)
    data              := AutoRunExplorer.GetNodeData(node);
    data.iCaption     := iCaption;
    data.iPath        := '';
    data.iEnabled     := false;
    data.iType        := itRoot;
    (* *)
    icon := TIcon.Create;
    Data.ImageIndex := -1;
    if FileExists(ExtractFilePath(paramstr(0))+'Images\'+iicon) then begin
        icon.LoadFromFile(ExtractFilePath(paramstr(0))+'Images\'+iicon);
        SysImageList.AddIcon(icon);
        Data.ImageIndex := SysImageList.Count - 1;
    end;
    icon.Free;
end;

procedure TAutoRunForm.AddNewItem(iCaption, iPath, iRegKey, iRoot, iParam: string; iEnabled: boolean; root: PVirtualNode);
var
    node : PVirtualNode;
    subn : PVirtualNode;
    data : PVSTItem;
    icon : ticon;
begin
    node := AutoRunExplorer.AddChild(root);
    node.CheckType := ctTriStateCheckBox;
    icon := ticon.Create;
    if iEnabled then
        node.CheckState := csCheckedNormal
        else
        node.CheckState := csUncheckedNormal;

    if not (vsInitialized in node.States) then
        AutoRunExplorer.ReinitNode(node, False);
    (* *)
    data              := AutoRunExplorer.GetNodeData(node);
    data.iCaption     := iCaption;
    data.iPath        := iPath;
    data.iRoot        := iRoot;
    data.iParam       := iParam;
    data.iEnabled     := iEnabled;

    if FileExists(iPath) then
        data.isHiden      := sts_IsFileHiden(iPath)
        else
        data.isHiden      := false;

    data.iType        := itItem;
    if FileExists(iPath) then
        data.ImageIndex   := GetSmallIconIndex(iPath, 0)
        else
        data.ImageIndex   := GetSmallIconIndex(WinDir+ iPath, 0);
    (* *)
    subn := AutoRunExplorer.AddChild(node);
    subn.CheckType := ctNone;
    if not (vsInitialized in node.States) then
        AutoRunExplorer.ReinitNode(node, False);
    (* *)
    data              := AutoRunExplorer.GetNodeData(subn);
    if FileExists(iPath) then
        data.iCaption     := iPath
        else
        data.iCaption     := WinDir + iPath;
    data.iEnabled     := ienabled;
    data.iType        := itSubItem;

    if FileExists(ExtractFilePath(paramstr(0))+'Images\reg_Path.ico') then begin
        icon.LoadFromFile(ExtractFilePath(paramstr(0))+'Images\reg_Path.ico');
        SysImageList.AddIcon(icon);
        Data.ImageIndex := SysImageList.Count - 1;
    end;
    (* *)
    if iRegKey = '' then exit;
    (* *)
    subn := AutoRunExplorer.AddChild(node);
    subn.CheckType := ctNone;
    if not (vsInitialized in node.States) then
        AutoRunExplorer.ReinitNode(node, False);
    (* *)
    data              := AutoRunExplorer.GetNodeData(subn);
    data.iCaption     := iRegKey;
    data.iEnabled     := ienabled;
    data.iType        := itSubItem;

    if FileExists(ExtractFilePath(paramstr(0))+'Images\reg_Key.ico') then begin
        icon.LoadFromFile(ExtractFilePath(paramstr(0))+'Images\reg_Key.ico');
        SysImageList.AddIcon(icon);
        Data.ImageIndex := SysImageList.Count - 1;
    end;
    (* *)
    icon.Free;
end;

Procedure TAutoRunForm.LoadFromDir(Location:string; Root: PVirtualNode);
var
    reg: Tregistry;
    regPath: String;
    stDir: string;
    sr: TSearchRec;
    MyObject: IUnknown;
    MySLink: IShellLink;
    MyPFile: IPersistFile;

    fd: _WIN32_FIND_DATA;
    fn: array[1..MAX_PATH] of Char;
    lfn: array[1..MAX_PATH] of WChar;
    i: Integer;
Begin
    Reg:=TRegistry.Create;
    try
        if Location='CU' then
        begin
            Reg.RootKey:=HKEY_CURRENT_USER;
            regPath:='Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
        end
        else
        begin
            Reg.RootKey:=HKEY_LOCAL_MACHINE;
            regPath:='Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
        end;
        if Reg.OpenKey(regPath,False) then
        Begin
            if Location='CU' then
                stDir:=Reg.ReadString('Startup')
            else
                stDir:=Reg.ReadString('Common Startup');

            if stDir<>'' then
            begin
                if FindFirst(stDir + '\*', faAnyFile	, sr) = 0 then
                begin
                repeat
                    if (sr.Name <> '.') and (sr.Name <> '..') then
                    begin
                         MyObject := CreateComObject(CLSID_ShellLink);
                         MySLink := MyObject as IShellLink;
                         MyPFile := MyObject as IPersistFile;

                         FillChar(lfn,MAX_PATH,0);
                         Strcopy(Pchar(@fn),Pchar(stDir));
                         StrCat(Pchar(@fn),'\');
                         StrCat(Pchar(@fn),Pchar(sr.Name));
                         for i:= 1 to strlen(Pchar(@fn)) do lfn[i]:=WChar(fn[i]);

                         if MyPFile.Load(PWchar(@lfn),OF_READ)=S_OK then
                         begin
                              FillChar(fn,MAX_PATH,' ');
                              MySLink.GetPath(Pchar(@fn),MAX_PATH,fd,SLGP_UNCPRIORITY	);
                         end;

                         AddNewItem(Sr.Name, stDir + '\' + Sr.Name, '', '', '', True, Root);
                    end;

                until FindNext(sr) <> 0;
                FindClose(sr);
                end;
            end;
        end
      finally
          Reg.Free;
      end;
End;

Procedure TAutoRunForm.LoadFromReg(Location: String; Root: PVirtualNode);
var
    reg: Tregistry;
    Val:TStringList;
    I:Integer;
    strName:string;
    strPath:string;
    strEXE:Pchar;
    strEXEfree:Pchar;
    curListItem : PVirtualNode;
    data : PVSTItem;
    regPath:string;
    en: boolean;
Begin
    Reg:=TRegistry.Create;
    Val:=TStringList.Create;
    try
        if pos('HKCU',Location)>0 then
            begin
                if (Location='HKCU') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\Run'
                else if (Location='HKCU_B') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\Run_Bak'
                else if (Location='HKCU_S') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\RunServices'
                else
                    regPath:='Software\Microsoft\Windows\CurrentVersion\RunServices_Bak';
                Reg.RootKey:=HKEY_CURRENT_USER
            end
            else
            begin
                if (Location='HKLM') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\Run'
                else if (Location='HKLM_B') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\Run_Bak'
                else if (Location='HKLM_S') then
                    regPath:='Software\Microsoft\Windows\CurrentVersion\RunServices'
                else
                    regPath:='Software\Microsoft\Windows\CurrentVersion\RunServices_Bak';

                Reg.RootKey:=HKEY_LOCAL_MACHINE;
            end;

            if not Reg.OpenKey(regPath,False) then
            else
            begin
                Reg.GetValueNames(Val);
                for I:=0 to Val.Count-1 do
                begin
                    strName:=Val.Strings[I];
                    strPath:=Reg.ReadString(strName);
                    GetMem(strEXEfree,strlen(Pchar(strPath))+1);
                    strcopy(strEXEfree,Pchar(strPath));
                    if strEXEfree[0]='"' then
                        strEXE:=strEXEfree+1
                    else
                        strEXE:=strEXEfree;
                    strEXE:=Pchar(trim(strlower(strEXE)));
                    if StrRScan(strEXE,'"')<>nil then
                        StrRScan(strEXE,'"')[0]:=#0
                    else
                        if pos('rundll32.exe',strEXE)=1 then
                    begin
                        strEXE:=strEXE+13;
                        if Strpos(strEXE,'.dll')<>nil then StrPos(strEXE,'.dll')[4]:=#0;
                    end
                    else if Strpos(strEXE,'.exe ')<>nil then StrPos(strEXE,'.exe ')[4]:=#0;

                    if pos('_B',Location)>0 then
                    begin
                        en:=False;
                    end
                    else
                    begin
                        en:=True;
                    end;
                    AddNewItem(strName, strEXE, regPath, Location, strPath, en, root);
                    FreeMem(strEXEfree);
                end;
                Reg.CloseKey;
            end;
    finally
        Val.Free;
        Reg.Free;
    end;
End;

Procedure TAutoRunForm.ChangeReg(node: PVirtualNode; booDel:Boolean);
var
    reg: Tregistry;
    writePath: String;
    delPath: String;
    data: PVSTItem;
begin
    data := AutoRunExplorer.GetNodeData(Node);
    if Assigned(Data) then begin
        Reg:=TRegistry.Create;
        try
            if (Data.iRoot = 'HKCU')or(Data.iRoot='HKCU_B')or(Data.iRoot='HKCU_S')or(Data.iRoot='HKCU_S_B') then
                Reg.RootKey:=HKEY_CURRENT_USER
            else
                Reg.RootKey:=HKEY_LOCAL_MACHINE;

            if node.CheckState = csUncheckedNormal then
                if pos('_S',Data.iRoot)>0 then
                begin
                    writePath:='Software\Microsoft\Windows\CurrentVersion\RunServices';
                    delPath:='Software\Microsoft\Windows\CurrentVersion\RunServices_Bak';
                end
                else
                begin
                    writePath:='Software\Microsoft\Windows\CurrentVersion\Run';
                    delPath:='Software\Microsoft\Windows\CurrentVersion\Run_Bak';
                end
                else
                    if pos('_S',Data.iRoot)>0 then
                    begin
                        writePath:='Software\Microsoft\Windows\CurrentVersion\RunServices_Bak';
                        delPath:='Software\Microsoft\Windows\CurrentVersion\RunServices';
                    end
                    else
                    begin
                        writePath:='Software\Microsoft\Windows\CurrentVersion\Run_Bak';
                        delPath:='Software\Microsoft\Windows\CurrentVersion\Run';
                    end;

            if Reg.OpenKey(writePath,true) then
            begin
                if not booDel then
                    Reg.WriteString(Data.iCaption ,Data.iParam)
                else
                    Reg.DeleteValue(Data.iCaption);
                Reg.CloseKey;

                if Reg.OpenKey(delPath,false) then
                begin
                    Reg.DeleteValue(Data.iCaption);
                    Reg.CloseKey;
                end;
            end;
        finally
            reg.Free;
        end;
    end;
end;

procedure TAutoRunForm.FormCreate(Sender: TObject);
var
    SysSIL  : THandle;
    SFI     : TSHFileInfo;
begin
    AutoRunExplorer.NodeDataSize := SizeOf(TVSTItem);

    SysImageList := TImageList.Create(self);
    AutoRunExplorer.Images := SysImageList;
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

procedure TAutoRunForm.btRefreshClick(Sender: TObject);
begin
    RefreshAutoRun;
end;

procedure TAutoRunForm.btCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TAutoRunForm.FormShow(Sender: TObject);
begin
    RefreshAutoRun;
end;

procedure TAutoRunForm.AutoRunExplorerGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
    data: PVSTItem;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
      CellText := data.iCaption;
end;

procedure TAutoRunForm.AutoRunExplorerGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
    data      : PVSTItem;
    FileInfo  : TSHFileInfo;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        ImageIndex := data.ImageIndex;
end;

procedure TAutoRunForm.AutoRunExplorerPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
    data      : PVSTItem;
    FileInfo  : TSHFileInfo;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(Data) then
        case data.iType of
            itRoot : begin
                          TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
                     end else
                          TargetCanvas.Font.Style := TargetCanvas.Font.Style - [fsBold];
        end;
end;

procedure TAutoRunForm.AutoRunExplorerResize(Sender: TObject);
begin
    AutoRunExplorer.Header.Columns.Items[0].Width := AutoRunExplorer.Width - 20;
end;

procedure TAutoRunForm.AutoRunExplorerBeforeCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect;
  var ContentRect: TRect);
var
    data: PVSTItem;
begin
    data := Sender.GetNodeData(Node);
    if Assigned(data) then begin
        if data.iType = itItem then begin
            if not data.isHiden then
                TargetCanvas.Brush.Color := $009FD9FF
                else
                TargetCanvas.Brush.Color := $00CECECE;
            TargetCanvas.FillRect(CellRect);
        end else
        if data.iType = itSubItem then begin
            TargetCanvas.Brush.Color := $00CEEAFD;
            TargetCanvas.FillRect(CellRect);
        end;
    end;
end;

procedure TAutoRunForm.AutoRunExplorerChecking(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
begin
    ChangeReg(Node, false);
end;

procedure TAutoRunForm.AutoRunExplorerDblClick(Sender: TObject);
var
    data: PVSTItem;
begin
    if AutoRunExplorer.GetNodeAt(pw_x, pw_y) <> nil then begin
        Data := AutoRunExplorer.GetNodeData(AutoRunExplorer.GetNodeAt(pw_x, pw_y){PathView.GetFirstSelected()});
        if assigned(data) then
        if Data.iType = itSubItem then
        if MainForm.DiskInDrive(Data.iCaption[1])then
            if FileExists(Data.iCaption) then begin
                FileInfoForm.GetInformation(data.iCaption);
                FileInfoForm.ShowModal;
            end;
    end;
end;

procedure TAutoRunForm.AutoRunExplorerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    pw_x := x;
    pw_y := y;
end;

end.
