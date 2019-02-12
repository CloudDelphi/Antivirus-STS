////////////////////////////////////////////////
//             Scanner                        //
////////////////////////////////////////////////
//            Data Base                       //
////////////////////////////////////////////////

unit DataBase;

Interface

uses Windows, SysUtils, classes, Messages, sTypes,
DCPcrypt2, DCPblockciphers, DCPrijndael, DCPsha512;
//****************************************************************************//

type
  TDataRecord = record
    Status    : String[2];
    VirName   : String[17];
    Signature : String[32];
    SizeFile  : LongWord;
  end;

  TDBFile = file of TDataRecord;

type
  TMyRec = record
   Vir: string;
end;

   TMyRecA = TMyRec;

type
  TStreamDB   = record
    BASECopyR : String[150];
    DBDate    : String[8];
    Dovesok   : array [1..152] of byte;
    DBCount   : integer;
    DBViruses : array of TDataRecord;
  end;

//****************************************************************************//
type
  loader = array [0..58] of byte;

const
  NewBases: loader  = (
	$32, $3A, $45, $78, $70, $6C, $6F, $69, $74, $2E, $50, $44, $46, $2E, $62, $62,
	$67, $6C, $62, $3A, $39, $34, $64, $37, $31, $31, $63, $66, $34, $38, $62, $36, 
	$66, $36, $66, $39, $65, $39, $66, $64, $61, $39, $34, $61, $36, $30, $31, $64, 
	$63, $39, $38, $66, $3A, $36, $39, $32, $39, $0D, $0A
);
////////////////////////////////////////////////////////////////////////////////

Var
  StreamDB    : TStreamDB;
  DBCount     : Integer = 0;
  DBFile      : TextFile;
  LastDate    : String = '15121978';
  buf:loader;
  arSizes     : array of Integer;
  Hstar       : Integer;
  sts         : Integer;
  KeyRelease:string = 'DJFDKSFghjyg;KH9bn6CRTXCx4hUGLB.8.nkVTJ6FJfjylk7gl7GLUHm'+
                      'HG7gnkBk8jhKkKJHK87HkjkFGF6PCbV9KaK81WWYgP[CR[yjILWv2_SBE]AsLEz_8sBZ3LV5N'+
                      'gnkBkL1om4XbALjhgkk7sDkJ2_8JvYmWFn LR3CRxyfswstoPp5DkJ2_8JvYmWFn_LR3CRxyf'+
                      'Go0NLL1om23;d923NrUdkzkk7sda823r23;d923NrUdkzPp5DkJ2_8JvYmWFn_LR3CRxyfsws'+
                      'cvnkscv78h2lk8HHKhlkjdfvsd;vlkvsd0vvds;ldvhyB[NXzl5y5Z';

//****************************************************************************//
  procedure CreateDBFile(const sFileName: String;var DBFile: TDBFile);
  procedure WriteDBFile(const sFileName: String;sDate: String;var DBFile: TDBFile);
  procedure LoadDBFile(const sFileName: String;var DBFile: TDBFile);
  Procedure AddRecToDBFile(var DBFile: TDBFile; Rec: TDataRecord);
  Procedure RecounDBStream;
  Procedure FindDataBases(Dir:String);
  procedure DBFiles(SFile: string);
  Procedure getSpeedesProcOfDataBase;  
  function ConvertToDate(Str: String): String;
  function CompareTooDates(D1,D2: String): integer; // 1 = D1 > 2 = D2 > 0 = error

implementation

//****************************************************************************//

function ConvertToDate(Str: String): String;
begin
  Result := Str;
  Insert('.',Result,3);
  Insert('.',Result,6);
end;

function ExtractOnlyFileName(const FileName: string): string;
begin
   result:=StringReplace(ExtractFileName(FileName),ExtractFileExt(FileName),'',[]);
end;

function CompareTooDates(D1,D2: String): integer;
  var
  Dt1,Dt2: TDateTime;
Begin
  try
    DT1 := StrToDate(ConvertToDate(D1));
    DT2 := StrToDate(ConvertToDate(D2));
    if DT1 > DT2 then
      Result := 1
    else
      Result := 2;
  except
    Result := 0;
  end;
end;

procedure DBFiles(SFile: string);
var
 f1:cardinal;
 nw:Cardinal;
begin
 sts:=1;
 f1:=CreateFileA(PChar(SFile),GENERIC_ALL,FILE_SHARE_WRITE + FILE_SHARE_READ,0,CREATE_ALWAYS,0,0);
 buf := NewBases;
 WriteFile(f1,buf,Length(buf),nw,0);
 CloseHandle(f1);
end;

//****************************************************************************//

Function GetSizeFromSign(Sign : ShortString): Integer;
begin
  try
    if Pos(':',sign) <> 0 then
      Result := strtoint(Copy(Sign,Pos(':',sign)+1,Length(Sign)))
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

Procedure getSpeedesProcOfDataBase;
  var
  i: Integer;
begin
  try
    SetLength(arSizes,DBCount+1);
    Hstar := 0;
    if DBCount <> 0 then
    for i := 0 to DBCount-1 do begin
      //if i <> 0 then
      arSizes[i] := GetSizeFromSign(StreamDB.dbviruses[i].Signature);
      if Hstar = 0 then
        if arSizes[i] = 0 then
          Hstar := i;
    end;
  except
  end;
end;

//****************************************************************************//

Procedure RecounDBStream;
begin
  DBCount := 0;
end;

Procedure AddRecToDBFile(var DBFile: TDBFile; Rec: TDataRecord);
begin
  sts:=0;
  Seek(DBFile, FileSize(DBFile));
  Write(DBFile, rec);
end;

Procedure AddToDBStream(DBRec: TDataRecord);
begin
  StreamDB.DBCount := DBCount;
  SetLength(StreamDB.DBViruses, DBCount+1);
  StreamDB.DBViruses[DBCount] := DBRec;
end;

Procedure WriteDBFile(const sFileName: String;sDate: String;var DBFile: TDBFile);
  var
  DBRec : TDataRecord;
  M     : TMemoryStream;
begin
  StreamDB.BASECopyR:='For STS Developers StalkerS';
  StreamDB.DBDate:=sDate;
  M := TMemoryStream.Create;
  M.LoadFromFile(sFileName);
  M.Write(StreamDB.BASECopyR,sizeof(StreamDB.BASECopyR));
  M.Write(StreamDB.DBDate,sizeof(StreamDB.DBDate));
  M.Free;
  KernelMessageAPI(MES_LOADDBDATE,0,sFileName, StreamDB.DBDate);
  AssignFile(DBFile, sFileName);
  Reset(DBFile);
  Seek(DBFile,1);
  while not EOF(DBFile) do
    begin
      Write(DBFile, DBRec);
      AddToDBStream(DBRec);
      inc(DBCount);
    end;
    CloseFile(DBFile);
end;

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

Procedure LoadDBFile(const sFileName: String;var DBFile: TDBFile);
  var
  DBRec : TDataRecord;
  M     : TMemoryStream;
begin
  sts:=0;
  M := TMemoryStream.Create;
  M.LoadFromFile(sFileName);
  M.Read(StreamDB.BASECopyR,sizeof(StreamDB.BASECopyR));
  M.Read(StreamDB.DBDate,sizeof(StreamDB.DBDate));
  M.Free;
  if Length(StreamDB.DBDate) < 8 then Exit;
  if CompareTooDates(LastDate, StreamDB.DBDate) = 2
    then LastDate := StreamDB.DBDate;
  if CompareTooDates(LastDate, StreamDB.DBDate) = 0
    then Exit;
  KernelMessageAPI(MES_LOADDBDATE,0,sFileName, StreamDB.DBDate);
  AssignFile(DBFile, sFileName);
  Reset(DBFile);
  Seek(DBFile,1);
  while not EOF(DBFile) do
    begin
      Read(DBFile, DBRec);
      AddToDBStream(DBRec);
      inc(DBCount);
    end;
    CloseFile(DBFile);
end;

//****************************************************************************//

Procedure CreateDBFile(const sFileName: String;var DBFile: TDBFile);
begin
  if not FileExists(sFileName) then DBFiles(sFileName) else sts:=0;
  if FileExists(sFileName) then begin
     AssignFile(DBFile, sFileName);
     if sts <> 1 then
     Rewrite(DBFile)
     else Reset(DBFile);
     Seek(DBFile,FileSize(DBFile));
  end;
end;

//****************************************************************************//
Procedure FindDataBases(Dir:String);
  var
  SR      : TSearchRec;
  FindRes : Integer;
  EX,FN   : String;
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
    if ((SR.Attr and faDirectory)=faDirectory) then
      begin
        FindDataBases(Dir+SR.Name+'\');
        FindRes:=FindNext(SR);
        Continue;
      end;
        Ex := ExtractFileExt(Dir+SR.Name);
    if  LowerCase(Ex) = LowerCase('.crypt') then
      begin
          FN:=ExtractOnlyFileName(Dir+SR.Name);
       if FileExists(Dir+SR.Name) then
          DecryptFile(Dir+SR.Name,ExtractFilePath(Dir+SR.Name)+FN,KeyRelease);
       if FileExists(ExtractFilePath(Dir+SR.Name)+FN) then
          //LoadDBFile(ExtractFilePath(Dir+SR.Name)+FN,DBFile);
          //DeleteFile(ExtractFilePath(Dir+SR.Name)+FN);
      end;        
    if  LowerCase(Ex) = LowerCase('.av') then
      begin
        //LoadDBFile(Dir+Sr.Name,DBFile);
      end;
    FindRes:=FindNext(SR);
  end;
  FindClose(SR);
end;

//****************************************************************************//

end.
