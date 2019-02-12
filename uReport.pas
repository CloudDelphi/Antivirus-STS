unit uReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TReportForm = class(TForm)
    Panel2: TPanel;
    ReportMemo: TRichEdit;
    Panel1: TPanel;
    btClose: TButton;
    btClear: TButton;
    TopPanel: TPanel;
    imgTopBk: TImage;
    lbReport: TLabel;
    Bevel4: TBevel;
    procedure btCloseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportForm: TReportForm;

implementation

uses uMain;

{$R *.dfm}

procedure TReportForm.btCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TReportForm.FormResize(Sender: TObject);
begin
    ReportMemo.Repaint;
end;

procedure TReportForm.btClearClick(Sender: TObject);
begin
    ReportMemo.Clear;
    DeleteFile(mainform.Options.ReportLocFile);
end;

end.
