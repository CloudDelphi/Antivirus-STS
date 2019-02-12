unit uErrorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TErrorForm = class(TForm)
    btClose: TButton;
    pnMain: TPanel;
    imgError: TImage;
    lbError: TLabel;
    lbErrorHint: TLabel;
    ErrorMemo: TMemo;
    procedure btCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ErrorForm: TErrorForm;

implementation

{$R *.dfm}

procedure TErrorForm.btCloseClick(Sender: TObject);
begin
    Close;
end;

end.
