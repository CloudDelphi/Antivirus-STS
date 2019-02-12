unit uFileInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, sts_lib, ShellAPI;

type
  TFileInfoForm = class(TForm)
    btClose: TButton;
    PageControl: TPageControl;
    InformationTab: TTabSheet;
    PEInformationTab: TTabSheet;
    PEInfoMemo: TMemo;
    imgFileIcon: TImage;
    lbFileName: TLabel;
    lbPath: TLabel;
    lbSize: TLabel;
    lbMd5: TLabel;
    edFMD5: TEdit;
    edFSize: TEdit;
    edFPath: TEdit;
    edFName: TEdit;
    Bevel2: TBevel;
    cbHidden: TCheckBox;
    cbReadOnly: TCheckBox;
    cbSystem: TCheckBox;
    imgAttributes: TImage;
    lbFileChanged: TLabel;
    lbFileCreated: TLabel;
    edFileCreate: TEdit;
    edFileChange: TEdit;
    edFileLastAcces: TEdit;
    lbFileOpened: TLabel;
    cbArchive: TCheckBox;
    Label4: TLabel;
    edFileType: TEdit;
    Bevel3: TBevel;
    Bevel1: TBevel;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbInformation: TLabel;
    TopPanel_2: TPanel;
    imgTopBk_2: TImage;
    lbPe: TLabel;
    Bevel4: TBevel;
    btHexView: TButton;
    lbFullDelete: TLabel;
    procedure GetInformation(fName: string);
    procedure FormShow(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btHexViewClick(Sender: TObject);
    procedure lbFullDeleteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Type TFileInfo=record
      Exists:boolean;
      Name:String;
      ShortName:String;
      NameNoExt:String;
      Extension:string;
      AssociatedFile:string;
      Path:string;
      ShortPath:string;
      Drive:string;
      CreateDate:TDateTime;
      Size:Int64;
      Attributes:record
          ReadOnly:boolean;
          Hidden:boolean;
          System:boolean;
          Archive:boolean;
      end;
      ModifyDate:TDateTime;
      LastAccessDate:TDateTime;
  end;

var
  FileInfoForm : TFileInfoForm;
  SysImageList : TImageList;
implementation

{uses uHexView, uOpenDesc;}
(******************************************************************************)
function isBysy(iPath: string) : boolean;
var
    desc: TFileStream;
begin
    Result := false;
    try
        desc := TFileStream.Create(iPath, fmShareDenyNone);
        if desc.Handle = INVALID_HANDLE_VALUE then begin
            result := true;
            exit;
        end
        else
            desc.Free;
    except
        result := true;
    end;
end;
    
function GetLargeIconIndex(const AFile: string; Attrs: DWORD): integer;
var
    SFI: TSHFileInfo;
begin
    SHGetFileInfo(PChar(AFile), Attrs, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SYSICONINDEX);
    Result := SFI.iIcon;
    FileInfoForm.imgFileIcon.Picture.Icon.Handle := SFI.hIcon;
end;

function MrsGetFileType(const strFilename: string): string;
var
    FileInfo: TSHFileInfo;
begin
    FillChar(FileInfo, SizeOf(FileInfo), #0);
    SHGetFileInfo(PChar(strFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME);
    Result := FileInfo.szTypeName;
end;

Function ReadFileInfo(FileName:string):TFileInfo;
var
    ts:TSearchRec;

Function FileTime2DateTime(FT:_FileTime):TDateTime;
    var FileTime:_SystemTime;
begin
    FileTimeToLocalFileTime(FT, FT);
    FileTimeToSystemTime(FT,FileTime);
    Result:=EncodeDate(FileTime.wYear, FileTime.wMonth, FileTime.wDay)+
    EncodeTime(FileTime.wHour, FileTime.wMinute, FileTime.wSecond, FileTime.wMilliseconds);
end;

begin
    Result.Name:=ExtractFileName(FileName);
    Result.Extension:=ExtractFileExt(FileName);
    Result.NameNoExt:=Copy(Result.Name,1,length(Result.Name)-length(Result.Extension));
    Result.Path:=ExtractFilePath(FileName);
    Result.Drive:=ExtractFileDrive(FileName);
    Result.ShortPath:=ExtractShortPathName(ExtractFilePath(FileName));
    Result.AssociatedFile := MrsGetFileType(FileName);
    if FindFirst(FileName, faAnyFile, ts)=0 then
    begin
        Result.Exists:=true;
        Result.CreateDate:=FileDateToDateTime(ts.Time);
        Result.Size:=ts.FindData.nFileSizeHigh*4294967296+ts.FindData.nFileSizeLow;
        Result.Attributes.ReadOnly:=(faReadOnly and ts.Attr)>0;
        Result.Attributes.Hidden:=(faHidden and ts.Attr)>0;
        Result.Attributes.System:=(faSysFile and ts.Attr)>0;
        Result.Attributes.Archive:=(faArchive and ts.Attr)>0;
        Result.ModifyDate:=FileTime2DateTime(ts.FindData.ftLastWriteTime);
        Result.LastAccessDate:=FileTime2DateTime(ts.FindData.ftLastAccessTime);
        Result.ShortName:=ts.FindData.cAlternateFileName;
        Findclose(ts);
    end
    else
        Result.Exists:=false;
end;

procedure TFileInfoForm.GetInformation(fName: string);
var
    FileInfo: TFileInfo;
    PEInfo: sts_peinfo;
    i: integer;
begin
    FileInfo := ReadFileInfo(fName);

    edFMD5.Clear;
    edFSize.Clear;
    edFPath.Clear;
    edFName.Clear;
    edFileCreate.Clear;
    edFileChange.Clear;
    edFileLastAcces.Clear;
    edFileType.Clear;

    edFName.Text := FileInfo.Name;
    edFPath.Text := FileInfo.Path;
    edFileType.Text := FileInfo.AssociatedFile;
    edFSize.Text := format('%d BYTES',[FileInfo.Size]);
    edFileCreate.Text := FormatDateTime('dd mmmm yyyy., hh:mm:ss', FileInfo.CreateDate);
    edFileChange.Text := FormatDateTime('dd mmmm yyyy., hh:mm:ss', FileInfo.ModifyDate);
    edFileLastAcces.Text := FormatDateTime('dd mmmm yyyy., hh:mm:ss', FileInfo.LastAccessDate);

    edFMD5.Text := sts_md5file(fName);

    if not isBysy(fName) then
        GetLargeIconIndex(fName,0)
    else
        if FileExists(ExtractFilePath(paramstr(0))+'\images\nfo_locked.ico') then
            imgFileIcon.Picture.Icon.LoadFromFile(ExtractFilePath(paramstr(0))+'\images\nfo_locked.ico');


    cbHidden.Checked := FileInfo.Attributes.Hidden;
    cbReadOnly.Checked := FileInfo.Attributes.ReadOnly;
    cbSystem.Checked := FileInfo.Attributes.System;
    cbArchive.Checked := FileInfo.Attributes.Archive;

    if FileInfo.Size = 0 then btHexView.Enabled := false else btHexView.Enabled := true;

    PEInfoMemo.Clear;
    PEInformationTab.TabVisible := false;
    (* *)
     if sts_getpeinfo(fName, PEInfo) then begin
        PEInformationTab.TabVisible := true;

        PEInfoMemo.Lines.Add('Windows PE File');
        PEInfoMemo.Lines.Add('');
        PEInfoMemo.Lines.Add(format('EntryPoint: %d', [peinfo.pe_entrypoint]));
        PEInfoMemo.Lines.Add(format('EP Section: %s', [peinfo.pe_epsection]));
        PEInfoMemo.Lines.Add(format('Linker version: %s', [peinfo.pe_linker]));
        PEInfoMemo.Lines.Add(format('SubSystem: %s', [peinfo.pe_subsys]));
        PEInfoMemo.Lines.Add('');
        PEInfoMemo.Lines.Add(format('First Bytes: %s', [ IntToHex(byte(peinfo.pe_firstbytes[1]),2)+' '+IntToHex(byte(peinfo.pe_firstbytes[2]),2)+' '+IntToHex(byte(peinfo.pe_firstbytes[3]),2)+' '+IntToHex(byte(peinfo.pe_firstbytes[4]),2)]));
        PEInfoMemo.Lines.Add('');
        PEInfoMemo.Lines.Add(format('Sections Count: %d', [peinfo.pe_seccount]));
        for i := 0 to PEInfo.pe_seccount - 1 do begin
            PEInfoMemo.Lines.Add('');
            PEInfoMemo.Lines.Add(format('SECTION: %s', [peinfo.pe_sections[i].sec_name]));
            PEInfoMemo.Lines.Add(format('       R.Size: %d', [peinfo.pe_sections[i].sec_raw_size]));
            PEInfoMemo.Lines.Add(format('       R.Offset: %d', [peinfo.pe_sections[i].sec_raw_offset]));
            PEInfoMemo.Lines.Add(format('       V.Size: %d', [peinfo.pe_sections[i].sec_vir_size]));
            PEInfoMemo.Lines.Add(format('       V.Offset: %d', [peinfo.pe_sections[i].sec_vir_offset]));
            PEInfoMemo.Lines.Add(format('       MD5: %s:%d', [LowerCase(peinfo.pe_sections[i].sec_md5),peinfo.pe_sections[i].sec_raw_size]));
        end;
     end;
    (* *)
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
(******************************************************************************)
{$R *.dfm}

procedure TFileInfoForm.FormShow(Sender: TObject);
begin
    InformationTab.Show
end;

procedure TFileInfoForm.btCloseClick(Sender: TObject);
begin
    close;
end;

procedure TFileInfoForm.btHexViewClick(Sender: TObject);
begin
    {if hexviewform.BinHex.Open(edFPath.Text + edFName.text) then
        HexViewForm.ShowModal
    else}
        MessageDlg('Невозможно открыть файл для просмотра содержимого, возможно файл занят другим приложением.',mtError,[mbOK],0);
end;

procedure TFileInfoForm.lbFullDeleteClick(Sender: TObject);
begin
    if MessageDlg('Вы действительно хотите удалить этот файл?',mtWarning,[mbYes, mbNo],0) <> 6 then exit;
    
    if RenameFile(edFPath.Text + edFName.Text, BakFN(edFPath.Text + edFName.Text)) then
        BootReplaceFile('',BakFN(edFPath.Text + edFName.Text))
    else
        BootReplaceFile('',edFPath.Text + edFName.Text);

    MessageDlg('Внимание! Файл будет удален после перезагрузки Windows.',mtInformation,[mbOk], 0);
end;

end.
