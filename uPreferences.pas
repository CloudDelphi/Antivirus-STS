unit uPreferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, Spin, ShlObj, FileCtrl;

const
    defupdateurl = 'http://127.0.0.1/bases/';

type
  TProferencesForm = class(TForm)
    btApply: TButton;
    btCansel: TButton;
    PreferencesPages: TPageControl;
    GeneralTab: TTabSheet;
    FilterTab: TTabSheet;
    imgScan: TImage;
    cbScanInSubDir: TCheckBox;
    cbUseXForce: TCheckBox;
    cbScanOnlyPE: TCheckBox;
    Bevel2: TBevel;
    lbInfected: TLabel;
    cbScanArch: TCheckBox;
    imgInfected: TImage;
    rbReportOnly: TRadioButton;
    rbRemove: TRadioButton;
    rbQuarantine: TRadioButton;
    edQuarantine: TEdit;
    spSelQuarantineDir: TSpeedButton;
    cbUnloadInfected: TCheckBox;
    ButtonPanel: TPanel;
    sbFilterDelete: TSpeedButton;
    sbFilterAdd: TSpeedButton;
    lbFilter: TListBox;
    cbLoadUserDB: TCheckBox;
    LocationsTab: TTabSheet;
    imgFolders: TImage;
    lbDataBase: TLabel;
    sbSelDB: TSpeedButton;
    edDataBase: TEdit;
    edTemp: TEdit;
    sbSelTemp: TSpeedButton;
    lbTemp: TLabel;
    lbReportLoc: TLabel;
    Bevel6: TBevel;
    imgReport: TImage;
    sbSelReport: TSpeedButton;
    edReport: TEdit;
    lbReport: TLabel;
    UpdateTab: TTabSheet;
    imgUpdate: TImage;
    edUpdate: TEdit;
    lbUpdateURL: TLabel;
    lbFilterInfo: TLabel;
    imgFilter: TImage;
    PriorityTab: TTabSheet;
    imgPriority: TImage;
    lbSelPriority: TLabel;
    cbPriority: TComboBox;
    SaveDialog: TSaveDialog;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbMain: TLabel;
    TopPanel_2: TPanel;
    imgTopBk_2: TImage;
    lbScanFilter: TLabel;
    LimitsTab: TTabSheet;
    lbFileLimit: TLabel;
    lbArchLimit: TLabel;
    ImgLimit: TImage;
    seFileLimit: TSpinEdit;
    seArchLimit: TSpinEdit;
    TopPanel_3: TPanel;
    imgTopBk_3: TImage;
    lbLimits: TLabel;
    TopPanel_4: TPanel;
    imgTopBk_4: TImage;
    lbPathes: TLabel;
    TopPanel_5: TPanel;
    imgTopBk_5: TImage;
    lbUpdate: TLabel;
    TopPanel_6: TPanel;
    imgTopBk_6: TImage;
    lbPriority: TLabel;
    lbDefaultURL: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btCanselClick(Sender: TObject);
    procedure btApplyClick(Sender: TObject);
    procedure sbFilterAddClick(Sender: TObject);
    procedure sbFilterDeleteClick(Sender: TObject);
    procedure spSelQuarantineDirClick(Sender: TObject);
    procedure sbSelDBClick(Sender: TObject);
    procedure sbSelTempClick(Sender: TObject);
    procedure sbSelReportClick(Sender: TObject);
    procedure lbDefaultURLClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProferencesForm: TProferencesForm;

implementation

uses uMain;

function SpecialFolder(Folder: Integer): String;
var
    SFolder : pItemIDList;
    SpecialPath : Array[0..MAX_PATH] Of Char;
    Handle:THandle;
begin
    SHGetSpecialFolderLocation(Handle, Folder, SFolder);
    SHGetPathFromIDList(SFolder, SpecialPath);
    Result := StrPas(SpecialPath);
end;


{$R *.dfm}

procedure TProferencesForm.FormShow(Sender: TObject);
begin
    GeneralTab.Show;
    ModalResult := mrNone; 
end;

procedure TProferencesForm.btCanselClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;

procedure TProferencesForm.btApplyClick(Sender: TObject);
begin
    ModalResult := mrOk;
end;

procedure TProferencesForm.sbFilterAddClick(Sender: TObject);
var
    ext: string;
begin
    ext := InputBox('Введите новое расширение','Расширение:','');
    if ext <> '' then begin
        lbFilter.Items.Add(ext);
    end;
end;

procedure TProferencesForm.sbFilterDeleteClick(Sender: TObject);
begin
    lbFilter.DeleteSelected;
end;

procedure TProferencesForm.spSelQuarantineDirClick(Sender: TObject);
var
    F: String;
begin
    if SelectDirectory('Выберите директорию:',SpecialFolder(CSIDL_DRIVES),F) then
    begin
        edQuarantine.Text := F;
    end;
end;

procedure TProferencesForm.sbSelDBClick(Sender: TObject);
var
    F: String;
begin
    if SelectDirectory('Выберите директорию:',SpecialFolder(CSIDL_DRIVES),F) then
    begin
        edDataBase.Text := F;
    end;
end;

procedure TProferencesForm.sbSelTempClick(Sender: TObject);
var
    F: String;
begin
    if SelectDirectory('Выберите директорию:',SpecialFolder(CSIDL_DRIVES),F) then
    begin
        edTemp.Text := F;
    end;
end;

procedure TProferencesForm.sbSelReportClick(Sender: TObject);
begin
    if SaveDialog.Execute then
        edReport.Text := SaveDialog.FileName;
end;

procedure TProferencesForm.lbDefaultURLClick(Sender: TObject);
begin
    edUpdate.Text := defupdateurl;
end;

end.
