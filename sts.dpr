{$R Manifest.RES}
program sts;

uses
  Forms,
  Windows,
  ActiveX,
  Controls,
  Variants,
  ComObj,
  Classes,
  SysUtils,
  TcpIpHlp,
  uMessage in 'uMessage.pas' {MessageFrm},
  uMain in 'uMain.pas' {MainForm};

{$R *.res}
{$R BlackList.RES}

CONST valid_types = IFF_UP
                 OR IFF_BROADCAST
                {OR IFF_LOOPBACK - we don't want this one}
                 OR IFF_POINTTOPOINT
                 OR IFF_MULTICAST;

var
 ///////////////////
 ms : TMemoryStream;
 rs : TResourceStream;
 m_DllDataSize : integer;
 mp_DllData : Pointer;
 //////////////////

begin
  //Поиск вредоносных сайтов (Майнинг)
 if not FileExists(pchar(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt')) then
  begin
  if 0 <> FindResource(hInstance, 'BlackList', 'crypt') then
   begin
    rs := TResourceStream.Create(hInstance, 'BlackList', 'crypt');
    ms := TMemoryStream.Create;
    try
      ms.LoadFromStream(rs);
      ms.Position := 0;
      m_DllDataSize := ms.Size;
      mp_DllData := GetMemory(m_DllDataSize);
      ms.Read(mp_DllData^, m_DllDataSize);
      ms.SaveToFile(pchar(ExtractFilePath(ParamStr(0))+'BlackList.txt.crypt'));
    finally
      ms.Free;
      rs.Free;
    end;
   end;
  end;
  Application.Initialize;
  Application.Title := 'Antivirus Stels';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMessageFrm, MessageFrm);
  EnumInterfaces(MainForm.AddInterface, valid_types);
  if MainForm.InterfaceComboBox.Items.Count > 0 then
     MainForm.InterfaceComboBox.ItemIndex := 0;
     MainForm.FAsyncRead := MainForm.HandleData;
  ///////////////////////////////////
  Application.ShowMainForm:=False;
  Application.Run;
end.
