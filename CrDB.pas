unit CrDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
  DCPblockciphers, DCPrijndael, DCPsha512, DCPcrypt2,
  Hash,
  sts_lib,
  StdCtrls;

type
  TMyRec = record
   Vir: string;
end;

   TMyRecA = TMyRec;

type
  TForm1 = class(TForm)
    DBListView: TListView;
    btn1: TButton;
    ProgressBar1: TProgressBar;
    btn2: TButton;
    StatusBar1: TStatusBar;
    btn3: TButton;
    grp1: TGroupBox;
    ReportMemo: TRichEdit;
    DelVir: TButton;
    lbl1: TLabel;
    procedure FindFile(Dir:String);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DelVirClick(Sender: TObject);
  private
  public
    Line         : String;
    Color        : TColor;
    Bold         : boolean;
    procedure ADDREP(AText: string; AColor: TColor; bold: boolean = false);
    procedure ADDTOREPORT;
  end;

type
  loader = array [0..58] of byte;

const
  NewBases: loader  = (
	$32, $3A, $45, $78, $70, $6C, $6F, $69, $74, $2E, $50, $44, $46, $2E, $62, $62,
	$67, $6C, $62, $3A, $39, $34, $64, $37, $31, $31, $63, $66, $34, $38, $62, $36, 
	$66, $36, $66, $39, $65, $39, $66, $64, $61, $39, $34, $61, $36, $30, $31, $64, 
	$63, $39, $38, $66, $3A, $36, $39, $32, $39, $0D, $0A
);

var
  Form1: TForm1;
  DBFile: TextFile;
  d: Integer = 0;
  Canceled:Boolean;
  pb: TProgressBar;
  sf: string;
  sL: TStringList;
  unarchfl: string;
  RecB,RecT,RecS,
  Fname,FBases: String;
  sts         : Integer;
  TST,TVIR: TStringList;
  KeyRelease:string = 'DJFDKSFghjyg;KH9bn6CRTXCx4hUGLB.8.nkVTJ6FJfjylk7gl7GLUHm'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'gnkBkL1om4XbALjhgkk7sDkJ2_8JvYmWFn LR3CRxyfswstoPp5DkJ2_8JvYmWFn_LR3CRxyf'+
                      'Go0NLL1om23;d923NrUdkzkk7sda823r23;d923NrUdkzPp5DkJ2_8JvYmWFn_LR3CRxyfsws'+
                      'cvnkscv78h2lk8HHKhlkjdfvsd;vlkvsd0vvds;ldvhyB[NXzl5y5Z';

implementation

{$R *.dfm}

//Зашифрование/расшифрование файла:
function EncryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.EncryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

function DecryptFile(Source, Dest, Password: string): Boolean;
var
  DCP_rijndael1: TDCP_rijndael;
  SourceStream, DestStream: TFileStream;
begin
  Result := True;
  try
    SourceStream := TFileStream.Create(Source, fmOpenRead);
    DestStream := TFileStream.Create(Dest, fmCreate);
    DCP_rijndael1 := TDCP_rijndael.Create(nil);
    DCP_rijndael1.InitStr(Password, TDCP_sha512);
    DCP_rijndael1.DecryptStream(SourceStream, DestStream, SourceStream.Size);
    DCP_rijndael1.Burn;
    DCP_rijndael1.Free;
    DestStream.Free;
    SourceStream.Free;
  except
    Result := False;
  end;
end;

procedure DBFiles(SFile: string);
var
 f1:cardinal;
 nw:Cardinal;
 buf:loader;
begin
 sts:=1;
 f1:=CreateFileA(PChar(SFile),GENERIC_ALL,FILE_SHARE_WRITE + FILE_SHARE_READ,0,CREATE_ALWAYS,0,0);
 buf := NewBases;
 WriteFile(f1,buf,Length(buf),nw,0);
 CloseHandle(f1);
end;

Procedure CreateDBFile(const sFileName: String;var DBFile: TextFile);
begin
  if not FileExists(sFileName) then DBFiles(sFileName) else sts:=0;
  if FileExists(sFileName) then begin
     AssignFile(DBFile, sFileName);
     if sts <> 1 then
     Rewrite(DBFile)
     else
     Reset(DBFile);
     CloseFile(DBFile);
  end;
end;

procedure AddRecToList(Rec: string);
begin
  Form1.StatusBar1.Panels[1].Text:=Rec;
  Application.ProcessMessages;
end;

procedure AddRecToDBFile(var DBFile: File; Rec: string);
begin
  Seek(DBFile, FileSize(DBFile));
  Writeln(Rec);
end;

function GetSize(FileN: String): String;
var
  hdc : cardinal;
  Buf : integer;
begin
  hdc := FileOpen(FileN,0);
  buf := GetFileSize(hdc,0);
  result := inttostr(buf);
  fileClose(hdc);
end;

function TextSize(FileName: string): integer;
var
  tmp: TStringList;
begin
  if FileExists(FileName) then
  begin
    tmp := TStringList.Create;
    tmp.LoadFromFile(FileName);
    Result := tmp.Count;
    tmp.Free;
  end
  else
    Result := -1;
end;

procedure TForm1.ADDTOREPORT;
begin
    Application.ProcessMessages;
    with Form1.ReportMemo do
    begin
        SelStart := Length(Text);
        SelAttributes.Color := Self.Color;
        SelAttributes.Size := 8;
        if Self.bold then
           SelAttributes.Style := SelAttributes.Style + [fsBold];
           Lines.Add(self.Line);
    end;
end;

procedure TForm1.ADDREP(AText: string; AColor: TColor; bold: boolean = false);
begin
    Self.Line := AText;
    Self.bold := Bold;
    Self.Color := AColor;
    ADDTOREPORT;
end;

procedure xc_debug (msg: dword; const args: array of const);
begin
    if msg = sts_UNARCH_FL then begin
       unarchfl := format('%s',args);
    end;
    case msg of
         sts_INIT_ERROR : begin
                            showmessage('Kernel Initialization error.');
                            ExitProcess(0);
                          end;
    end;
end;

procedure StrBreakApart(const S, Delimeter: string; Parts: TStrings);
var
  CurPos: integer;
  CurStr: string;
begin
  Parts.clear;
  Parts.BeginUpdate();
try
   CurStr := S;
   repeat
     CurPos := Pos(Delimeter, CurStr);
     if (CurPos > 0) then
     begin
       Parts.Add(Copy(CurStr, 1, Pred(CurPos)));
       CurStr := Copy(CurStr, CurPos + Length(Delimeter),
       Length(CurStr) - CurPos - Length(Delimeter) + 1);
     end
     else
       Parts.Add(CurStr);
   until CurPos = 0;
finally
   Parts.EndUpdate();
end;
end;

procedure TForm1.FindFile(Dir:String);
Var SR:TSearchRec; 
    FindRes:Integer;
begin 
FindRes:=FindFirst(Dir+'*.*',faAnyFile,SR);
While FindRes=0 do 
   begin 
      if ((SR.Attr and faDirectory)=faDirectory) and 
         ((SR.Name='.')or(SR.Name='..')) then 
         begin 
            FindRes:=FindNext(SR);
            Continue; 
         end;
      if ((SR.Attr and faDirectory)=faDirectory) then // если найден каталог, то
         begin 
            FindFile(Dir+SR.Name+'\'); // входим в процедуру поиска с параметрами текущего каталога + каталог, что мы нашли
            FindRes:=FindNext(SR); // после осмотра вложенного каталога мы продолжаем поиск в этом каталоге 
            Continue; // продолжить цикл 
         end else
      TST.Add(Dir+SR.Name);
      FindRes:=FindNext(SR);
   end; 
FindClose(SR);
end;

procedure OpenDB(const FileName: String);
var
  f: TextFile; // файл
  j,sz:integer;
  buf: string[80]; // буфер для чтения из файла
  Tmp: TStringList;
begin
  Tmp:= TStringList.Create;
  AssignFile(f, FileName);
  Reset(f); // открыть для чтения
  sz:=TextSize(FileName);
  if IOResult <> 0 then
  begin
    MessageDlg('Ошибка доступа к файлу ' + FileName, mtError, [mbOk], 0);
    exit;
  end;
  j:=0;
  // чтение из файла
  while not EOF(f) do
  begin
       inc(j);
       readln(f, buf); // прочитать строку из файла
       AddRecToList(buf);
       TVIR.Add(Trim(buf));
       Form1.StatusBar1.Panels[2].Text:='Count: '+IntToStr(j)+'/'+IntToStr(sz);
       Application.ProcessMessages;
    if canceled then break;
       StrBreakApart(Trim(buf), ':', Tmp);
    if Tmp.Count > 0 then
      with Form1.DBListView.Items.Add, Tmp do begin
           Form1.ProgressBar1.Visible:=True;
           if Tmp.Count > 0 then
           Caption:=Tmp[0];
                      if Tmp.Count > 1 then
                      SubItems.Add(Tmp[1]);
                                 if Tmp.Count > 2 then
                                 SubItems.Add(Tmp[2]);
                                           if Tmp.Count > 3 then
                                            SubItems.Add(Tmp[3]);
      end;
      // scroll a ListView vertically down             SB_LINEUP
      SendMessage(Form1.DBListView.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  end;
  Tmp.Free;
  CloseFile(f); // закрыть файл
end;


//Writeln(f,pointer(s)^); 
procedure OpenDBF(const sFileName: String;var DBFile: TextFile);
var
  s: string;
  j,sz:integer;
  Tmp: TStringList;
begin
  AssignFile(DBFile, sFileName);
  Reset(DBFile);
  sz:=TextSize(sFileName);
  j:=0;
  Form1.ProgressBar1.Max:=sz;
  Tmp := TStringList.Create;
  while not EOF(DBFile) do
    begin
      inc(j);
      ReadLn(DBFile,s);
      AddRecToList(s);
      TVIR.Add(Trim(s));
      Form1.StatusBar1.Panels[2].Text:='Count: '+IntToStr(j)+'/'+IntToStr(sz);
      Form1.ProgressBar1.position:=j;
      Application.ProcessMessages;
      if canceled then break;
      StrBreakApart(s, ':', Tmp);
      if Tmp.Count > 0 then
      with Form1.DBListView.Items.Add, Tmp do begin
           Form1.ProgressBar1.Visible:=True;
           if Tmp.Count > 0 then
           Caption:=Tmp[0];
                      if Tmp.Count > 1 then
                      SubItems.Add(Tmp[1]);
                                 if Tmp.Count > 2 then
                                 SubItems.Add(Tmp[2]);
                                           if Tmp.Count > 3 then
                                            SubItems.Add(Tmp[3]);
      end;
      // scroll a ListView vertically down             SB_LINEUP
      SendMessage(Form1.DBListView.Handle, WM_VSCROLL, SB_LINEDOWN, 0);
    end;
    CloseFile(DBFile);
end;

function ExtractOnlyFileName(const FileName: string): string;
begin
   result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  ntype,virname,
  sigvir,sizevir: string;
  i: integer;
  s,dt: string;
begin
   TST.Clear;
   TVIR.Clear;
   DBListView.Clear;
   sf:=ExtractFilePath(ParamStr(0))+'database\sts000001.sts.xpb.c';
   Fname:=ExtractOnlyFileName(sf);
if not DirectoryExists(ExtractFilePath(ParamStr(0))+'VIRUS') then
   CreateDir(ExtractFilePath(ParamStr(0))+'VIRUS');
if DirectoryExists(ExtractFilePath(ParamStr(0))+'VIRUS') then
   FindFile(ExtractFilePath(ParamStr(0))+'VIRUS\');
if FileExists(sf) or (FileExists(ExtractFilePath(sf)+Fname)) then begin
   if ExtractFileExt(sf) = '.c' then begin
   if FileExists(sf) then
      DecryptFile(sf,ExtractFilePath(sf)+Fname,KeyRelease);
   if FileExists(ExtractFilePath(sf)+Fname) then
      Form1.StatusBar1.Panels[2].Text:='Decrypt complete!';
      Fname:=ExtractFilePath(sf)+Fname;
      ProgressBar1.position:=0;
   if FileExists(Fname) then begin
      sts_unpack_xdb(pchar(Fname)); //Для теста
      Fname:=ExtractFilePath(Fname)+'sts000001.sts.xpb.xdb';
   if FileExists(Fname) then
      OpenDBF(Fname,DBFile);
   end;
   if TST.Count <= 0 then begin
      ADDREP('No new viruses to add to the database!', clBlack, false);
      Exit;
   end else
   for i:=0 to TST.Count-1 do begin
       s:=TST.Strings[i];
   if FileExists(s) then begin
      ntype:='2';
      virname:='('+ExtractOnlyFileName(ExtractFileName(s))+' - Worm)';
      sigvir:=MD5DigestToStr(MD5F(s));
      sizevir:=GetSize(s);
     if DBListView.Items.Count > 100 then
      DBListView.Items[DBListView.Items.Count - 1].Delete;
     with DBListView.Items.Add do begin
          Caption := ntype;
          SubItems.Add(virname);
          SubItems.Add(sigvir);
          SubItems.Add(sizevir);
          TVIR.Add(ntype+':'+virname+':'+sigvir+':'+sizevir);
          Application.ProcessMessages;
     end;
   end;
   end;
   s:=ExtractFilePath(ParamStr(0))+'database\'+ExtractFileName(Fname);
   Fname:=ExtractOnlyFileName(Fname);
   sf:=ExtractOnlyFileName(Fname);
   Fname:=ExtractFilePath(ParamStr(0))+'database\'+Fname+'.license';
   sf:=ExtractFilePath(ParamStr(0))+'database\'+sf+'.xpb';
   DeleteFile(s);
   DeleteFile(Fname);
   DeleteFile(sf);
   end else begin
   if FileExists(Fname) then
      OpenDBF(Fname,DBFile);
   if TST.Count <= 0 then begin
      ADDREP('No new viruses to add to the database!', clBlack, false);
      Exit;
   end else
   for i:=0 to TST.Count-1 do begin
       s:=TST.Strings[i];
   if FileExists(s) then begin
      ntype:='2';
      virname:='('+ExtractOnlyFileName(ExtractFileName(s))+' - Worm)';
      sigvir:=MD5DigestToStr(MD5F(s));
      sizevir:=GetSize(s);
     if DBListView.Items.Count > 100 then     
      DBListView.Items[DBListView.Items.Count - 1].Delete;
     with DBListView.Items.Add do begin
          Caption := ntype;
          SubItems.Add(virname);
          SubItems.Add(sigvir);
          SubItems.Add(sizevir);
          TVIR.Add(ntype+':'+virname+':'+sigvir+':'+sizevir);
          Application.ProcessMessages;
     end;
   end;
   end;
  if FileExists(s) then begin
     dt:=DateToStr(Now);
     while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
     if dt <> '' then
     sts_packing_db(pchar(s),PChar(dt),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
     Fname:=s+'.xpb';
  if FileExists(Fname) then
     EncryptFile(Fname,Fname+'.c',KeyRelease);
  if FileExists(Fname+'.c') then begin
     ADDREP('Crypt database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Crypt complete!';
     DeleteFile(Fname);
     DeleteFile(s);
     ADDREP('Save database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Save complete!';
     Application.ProcessMessages;
  end;
  end;
   end;
end else begin
   ADDREP('No database!', clBlack, false);
   sf:=ExtractFilePath(ParamStr(0))+'database\sts000001.sts';
if not FileExists(sf) then begin
   ADDREP('Create new database ...', clRed, false);
   CreateDBFile(sf,DBFile);
   ADDREP('New database complete!', clRed, false);
  if FileExists(sf) then begin
     dt:=DateToStr(Now);
     while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
     if dt <> '' then
     sts_packing_db(pchar(sf),PChar(dt),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
     Fname:=sf+'.xpb';
  if FileExists(Fname) then
     EncryptFile(Fname,Fname+'.c',KeyRelease);
  if FileExists(Fname+'.c') then begin
     ADDREP('Crypt database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Crypt complete!';
     DeleteFile(Fname);
     DeleteFile(sf);
     ADDREP('Save database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Save complete!';
     Application.ProcessMessages;
  end;
  end;
end else begin
  sf:=ExtractFilePath(ParamStr(0))+'database\sts000001.sts';
  if FileExists(sf) then begin
     dt:=DateToStr(Now);
     while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
     if dt <> '' then
     sts_packing_db(pchar(sf),PChar(dt),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
     Fname:=sf+'.xpb';
  if FileExists(Fname) then
     EncryptFile(Fname,Fname+'.c',KeyRelease);
  if FileExists(Fname+'.c') then begin
     ADDREP('Crypt database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Crypt complete!';
     DeleteFile(Fname);
     DeleteFile(sf);
     ADDREP('Save database complete!', clRed, false);
     Form1.StatusBar1.Panels[2].Text:='Save complete!';
     Application.ProcessMessages;
  end;
  end;
end;
end;
lbl1.Caption:=IntToStr(DBListView.Items.Count);
Application.ProcessMessages;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  canceled:=True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
TVIR:= TStringList.Create;
TST:= TStringList.Create;
sL := TStringList.Create;
with ProgressBar1 do begin
     Parent := StatusBar1;
     Position := 400;
     Top := 2;
     Left := 0;
     Height := StatusBar1.Height - Top;
     Width := StatusBar1.Panels[0].Width - Left;
end; 
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  canceled:=True;
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  dt: string;
begin
     dt:=DateToStr(Date);
     Fname:=ExtractFilePath(Fname)+'sts000001.sts.xpb.tmp';
     sf:=ExtractFilePath(Fname)+'sts000001.sts.xpb.xdb';
  if TVIR.Count > 0 then TVIR.SaveToFile(Fname);     
  if FileExists(Fname) then
     RenameFile(Fname,sf);
  if FileExists(sf) then begin
     dt:=DateToStr(Now);
     while pos('.',dt)<>0 do delete(dt,pos('.',dt),1);
     if dt <> '' then
     //sf:=ExtractOnlyFileName(sf);
     Fname:=ExtractFilePath(Fname)+ExtractOnlyFileName(sf);
     Fname:=ExtractFilePath(Fname)+ExtractOnlyFileName(Fname);
  if FileExists(sf) then
     RenameFile(sf,Fname);
     sts_packing_db(pchar(Fname),PChar(dt),pchar('license:This is DataBase File was Created by StalkerSTS for "Antivirus". Contacts: stasbalazuk@gmail.com')); //Для теста
     Fname:=Fname+'.xpb';
  if FileExists(Fname) then
     EncryptFile(Fname,ExtractFilePath(Fname)+ExtractFileName(Fname)+'.c',KeyRelease);
  if FileExists(ExtractFilePath(Fname)+ExtractFileName(Fname)+'.c') then begin
     Form1.StatusBar1.Panels[2].Text:='Crypt complete!';
     DeleteFile(sf);
     DeleteFile(Fname);
  end else
     Form1.StatusBar1.Panels[2].Text:='Save complete!';
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
TVIR.Free;
TST.Free;
sL.Free;
end;

procedure TForm1.DelVirClick(Sender: TObject);
var
  s: string;
  i,y: integer;
begin
  if DBListView.Items.Count <= 0 then begin
     ADDREP('No viruses to remove!', clRed, false);
     Exit;
  end;
  if DBListView.Items.Count > 0 then
  for i := 0 to DBListView.Items.Count-1 do begin
      s:=DBListView.Items.Item[i].SubItems[0];
      if DBListView.Items[I].Selected then y:=I;
  end;
  DBListView.DeleteSelected;
  lbl1.Caption:=IntToStr(DBListView.Items.Count);
  Application.ProcessMessages;
end;

end.
