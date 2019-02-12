unit uMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMessageFrm = class(TForm)
    TopPanel: TPanel;
    Image13: TImage;
    InformationLabel: TLabel;
    Bevel: TBevel;
    Memo1: TMemo;
    Ok: TButton;
    InfoLabel: TLabel;
    Image1: TImage;
    procedure OkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MessageFrm: TMessageFrm;

implementation

{$R *.dfm}

procedure CreateFormInRightBottomCorner;
var
 r : TRect;
begin
 Application.ProcessMessages;
 SystemParametersInfo(SPI_GETWORKAREA, 0, Addr(r), 0);
 MessageFrm.Left := r.Right-MessageFrm.Width;
 MessageFrm.Top := r.Bottom-MessageFrm.Height;
end;

procedure TMessageFrm.OkClick(Sender: TObject);
begin
  Close;
end;

procedure TMessageFrm.FormCreate(Sender: TObject);
begin
CreateFormInRightBottomCorner;
end;

procedure TMessageFrm.FormActivate(Sender: TObject);
begin
CreateFormInRightBottomCorner;
Application.ProcessMessages;
end;

end.
