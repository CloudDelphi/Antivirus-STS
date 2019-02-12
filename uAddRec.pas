unit uAddRec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, avHash, DCPcrypt2, DCPblockciphers,
  DCPrijndael, DCPsha512;

type
  TAddForm = class(TForm)
    Bevel: TBevel;
    TopPanel: TPanel;
    BackImage: TImage;
    NameLabel3: TLabel;
    CopyRightLabel: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Bevel1: TBevel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    lbl1: TLabel;
    cbb1: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure cbb1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddForm: TAddForm;

implementation

uses uMain;

{$R *.dfm}
Function GetSize(FileN: String): String;
var
hdc : cardinal;
Buf : integer;
begin
hdc := FileOpen(FileN,0);
buf := GetFileSize(hdc,0);
result := inttostr(buf);
FileClose(hdc);
end;

procedure TAddForm.Button1Click(Sender: TObject);
begin
with MainForm.DBListView.Items.Add  do begin
  if RadioButton2.Checked then begin
    Caption := 'HEX';
  end;
  if RadioButton1.Checked then begin
    Caption := 'MD5';
  end;
  SubItems.Add(Edit1.Text);
  SubItems.Add(Edit2.Text);
end;
 Close;
end;

procedure TAddForm.Button2Click(Sender: TObject);
begin
  Close;
end;

function ExtractOnlyFileName(const FileName: string): string;
begin
   result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

procedure TAddForm.Label4Click(Sender: TObject);
begin
if OpenDialog1.Execute then
   Edit2.Text := MD5DigestToStr(MD5F(opendialog1.FileName))+ ':' + GetSize(OpenDialog1.FileName);
end;

procedure TAddForm.cbb1Change(Sender: TObject);
begin
   Edit1.Text:='('+cbb1.Items.Strings[cbb1.ItemIndex]+')';
if Edit1.Text <> '' then   
if OpenDialog1.Execute then begin
   Edit2.Text := MD5DigestToStr(MD5F(opendialog1.FileName))+ ':' + GetSize(OpenDialog1.FileName);
   Edit1.Text := '('+ExtractOnlyFileName(ExtractFileName(opendialog1.FileName))+' - '+Edit1.Text+')';
end;
end;

procedure TAddForm.FormActivate(Sender: TObject);
begin
  Edit1.SetFocus;
end;

end.
