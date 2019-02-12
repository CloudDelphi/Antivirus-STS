////////////////////////////////////////////////
//                    Scanner                 //
////////////////////////////////////////////////
//               File Sign Unit               //
////////////////////////////////////////////////

unit Hex;

Interface

uses Windows, SysUtils, Classes, DataBase, Hash, CRC32, sTypes;

//****************************************************************************//

  type
    SBMTable = array[0..255] of byte;

  type
    Buffer = array of byte;

{$IFDEF VER130}            // This is a bit awkward
    // 8-byte integer
    TInteger8 = Int64;     // Delphi 5
{$ELSE}
  {$IFDEF VER120}
    TInteger8 = Int64;     // Delphi 4
  {$ELSE}
    TInteger8 = LongWord;  //COMP;      // Delphi  2 or 3
  {$ENDIF}
{$ENDIF}

//****************************************************************************//

 type
  TSection = packed record
   Name						      : array[0..7] of Char;
   VirtualSize			  	: DWORD;
   VirtualAddress			  : DWORD;
   PhysicalSize			    : DWORD;
   PhysicalOffset			  : DWORD;
   PointerToRelocations	: DWORD;
   PointerToLinenumbers	: DWORD;
   NumberOfRelocations	: WORD;
   NumberOfLinenumbers	: WORD;
   Characteristics		  : DWORD;
 end;

//****************************************************************************//

  var
    FS						   : Integer;
    FStreamEx	  	   : TMemoryStream;
    FStream				   : TMemoryStream;

//****************************************************************************//

   f							    : file;
	 FHandle					  : THandle;
 	 OFS						    : OFSTRUCT;
 	 BytesRead				  : DWORD;
 	 PEHeaderOffset		  : DWORD;
	 EntryPointRVA			: DWORD;
 	 NumOfSections			: WORD;
   Section					  : TSection;
   EntryPointOffset		: DWORD;
   BUF, BUFEX         : Buffer;
   snf,snf1,snf2      : string;

//****************************************************************************//

   CRC32    :  LongWORD;
   CRC32File:  LongWord;
   CRC32Text:  LongWord;

//****************************************************************************//

  Function GetSize(FileN: String): integer;
  Function FindByteSign(Sign: String): boolean;
  Function FindHexSign(Hex: ShortString): Boolean;
  Function FindHEXInPosition(Sign: String; EP: integer): Boolean;

  function StrToHex(a:array of char):string;
  function HexToInt(Value: String): LongWord;
  Function OpenFileForScan(FileName: String): Boolean;
  Function OpenFileForScanEx(FileName: String): Boolean;

  Function FindHexSignEX(Hex: ShortString): Boolean;
  Function FindByteSignEX(Sign: String): boolean;
  Function FindHEXInPositionEX(Sign: String; EP: integer): Boolean;
  Function GetSizeEX(FileN: String): integer;

  function GetEPoffset(filname: string): String;

  Procedure CloseFileAfterScan;
  Procedure CloseFileAfterScanEx;
implementation

//****************************************************************************//

function OpenPEFIle(FName: string): boolean;
begin
  result:=false;
  AssignFile(f, Fname);
  if not FileExists(FName) then exit;
  FHandle:= OpenFile(PChar(FName), OFS, OF_READWRITE);
  SetFilePointer(FHandle, $3C, nil, 0);
  ReadFile(FHandle, PEHeaderOffset, SizeOf(PEHeaderOffset), BytesRead, nil);
  result:=true;
end;

function GetEPoffset(filname: string): String;
  var
  I: DWORD;
begin
  if snf2 <> filname then begin
     snf2 := filname;
  if not OpenPEFIle(filname) then exit;
  LockFile(FHandle,1,2,3,4);
  SetFilePointer(FHandle, PEHeaderOffset + $28, nil, 0);
  ReadFile(FHandle, EntryPointRVA, SizeOf(EntryPointRVA), BytesRead, nil);
  SetFilePointer(FHandle, PEHeaderOffset + $F8, nil, 0);
  for I:= 1 to NumOfSections do
  begin
    ReadFile(FHandle, Section, SizeOf(Section), BytesRead, nil);
    if (EntryPointRVA >= Section.VirtualAddress)
      and (EntryPointRVA < Section.VirtualAddress + Section.VirtualSize) then Break;
  end;
  EntryPointOffset:= EntryPointRVA - Section.VirtualAddress + Section.PhysicalOffset;
  UnLockFile(FHandle,1,2,3,4);
  CloseHandle(FHandle);
  result:=IntToHex(EntryPointOffset,8);
  end;
end;

//****************************************************************************//
function ExtractFormat(const PathorFileName: string): string;
var
    i: Integer;
begin
    i := LastDelimiter('.', PathorFileName);
   Result := Copy(PathorFileName, i + 1, Length(PathorFileName) - (i));
end;

Function OpenFileForScanEx(FileName: String): Boolean;
var
  s: string;
  y: integer;
begin
  try
    s:=ExtractFormat(FileName);
    y:=Length(s);
  if y > 3 then begin
     s:='ERROR';
     Exit;
  end else if FileExists(FileName) then begin
  try
  if snf1 <> FileName then begin
     FStreamEx := TMemoryStream.Create;
     FStreamEx.LoadFromFile(FileName);
     snf1 := FileName;
     SetLength(BUFEX,FStreamEx.size);
     FStreamEx.Read(BUFEX[0],FStreamEx.SIZE);
     Result := true;
  end;
  except
    Result := true;
  end;
  end;
  except
    FStreamEx.Free;
    Result := False;
    Finalize(BUFEX);
  end;
end;


Procedure CloseFileAfterScanEx;
begin
  try
    FStreamEx.Free;
    Finalize(BUFEX);
  except
  end;
end;

//****************************************************************************//

Function OpenFileForScan(FileName: String): Boolean;
begin
  try
  if snf <> FileName then begin
    snf := FileName;
    if FileExists(FileName) then begin
    FStream := TMemoryStream.Create;
    FStream.LoadFromFile(FileName);
    ScannedDataSize := ScannedDataSize + FStream.Size;
    SetLength(BUF,FStream.size);
    FStream.Read(BUF[0],FStream.SIZE);
    Result := true;
    end;
  end;
  except
    FStream.Free;
    Result := False;
    Finalize(BUF);
  end;
end;


Procedure CloseFileAfterScan;
begin
  try
    Finalize(BUF);
    FStream.Free;
  except
  end;
end;

//****************************************************************************//
function StringToHex(HexStr: String): String;
  var
  I      : WORD;
  HexSet : Set of '0'..'f' ;
begin
  HexSet := ['0'..'9','a'..'f','A'..'F'];
  if HexStr = '' then Exit;
  for I:=1 to Length(HexStr) do
    if HexStr[I] in  HexSet   then Result := Result + HexStr[I];
end;

function StrToHex(a:array of char):string;
  var
  i,j : byte;
  s   : string;
begin
  j:=length(a)-1;
  for i:=0 to j do
  begin
    s:=s+inttohex(ord(a[i]),2);
  end;
  StrToHex:=s;
end;

function HexToInt(Value: String): LongWord;
  const
  HexStr: String = '0123456789abcdef';
  var
  i: Word;
begin
  Result := 0;
  if Value = '' then Exit;
  for i := 1 to Length(Value) do
    Inc(Result, (Pos(Value[i], HexStr) - 1) shl ((Length(Value) - i) shl 2));
end;

//****************************************************************************//

Function GetSizeEX(FileN: String): integer;
var
  //F: TMemoryStream;
  Error32  :  WORD;
  FileBytes:  TInteger8;
begin
  try
    CRC32File := 0;
    CRC32Text := 0;
    CRC32     := CRC32Text;
    CalcFileCRC32 (FileN, CRC32File, FileBytes, Error32);
    if Error32 <> 0       // Ignore errors
    then begin
       CRC32File := 0;
    end;
    result := FileBytes;
    {F := TMemoryStream.Create;
    F.LoadFromFile(FileN);
    result := F.Size;
    F.Free;}
  except
    result := 0;
  end;
end;

Function GetSize(FileN: String): integer;
var
  //F: TFileStream;
  Error32  :  WORD;
  FileBytes:  TInteger8;
begin
  try
    CRC32File := 0;
    CRC32Text := 0;
    CRC32     := CRC32Text;
    CalcFileCRC32 (FileN, CRC32File, FileBytes, Error32);
    if Error32 <> 0       // Ignore errors
    then begin
       CRC32File := 0;
    end;    
    result := FileBytes;
    {F := TFileStream.Create(FileN,OF_READ);
    result := F.Size;
    F.Free;}
  except
    result := 0;
  end;
end;

function  FindHexInFile(FileN: ShortString; Hex: ShortString): boolean;
const
  BufSize = 8192;
type
  SBMTable = array[0..255] of byte;
  Buffer   = array of byte;
var
  I,J        : DWORD;
  H          : Integer;
  Size       : DWORD;
  Pos        : DWORD;
  sPos       : DWORD;
  ReadS      : DWORD;
  BMT        : SBMTable;
  LEN        : BYTE;
  InputArray : Buffer;
  Buf  : array [0..BufSize] of byte;
begin
  H := FileOpen(FileN,0);
  Size := GetFileSize(H,0);
  ReadS := BufSize;
  sPos  := 0;
  {}
  LEN := (Length(Hex) div 2)-1;
  SetLength(InputArray,LEN+1);
  for j := 0 to LEN  do
    InputArray[j]:=StrToInt('$'+Copy(Hex, (j+1) * 2 - 1, 2));
  for i := 0 to 255 do BMT[i] := LEN;
    for i := LEN downto 0 do
      if BMT[(InputArray[i])] =  LEN then
         BMT[(InputArray[i])] := LEN - i;
  {}
  if Size < ReadS then ReadS := Size;
  while sPos <= Size-1 do begin
    FileSeek(h,sPos,0);
    FileRead(H,Buf,ReadS-1);
    sPos := sPos + ReadS;
    if sPos+ReadS > Size then
      ReadS := (sPos+ReadS)-Size;
    {}
    Pos := 0;
    while Pos < ReadS do
      if InputArray[LEN] <> Buf[Pos] then
        Pos := Pos + BMT[Buf[Pos]]
        else for i := 1 to LEN - 1 do
          if InputArray[i] <> Buf[Pos - LEN + i] then
            begin
              Inc(Pos);
              Break;
            end
            else if i = LEN-1 then
            begin
              Result := true;
              Finalize(InputArray);
              FileClose(H);
              Exit;
            end;
    {}
  end;
      Finalize(InputArray);
      FileClose(H);
      Result := false;
end;

//****************************************************************************//

Function FindHexInPOS(Typ: Byte ;Ps, EP: dWord; HEX: ShortString; buff: buffer): boolean;
  var
  i               : DWORD;
  InputArray      : Array[1..1000] of Byte;
  InputArrayLength: WORD;
  err             : WORD;
begin
  err := 0;
  InputArrayLength := Length(Hex) div 2;
  for I := 1 to  InputArrayLength  do
    InputArray[I]:=StrToInt('$'+Copy(Hex, I * 2 - 1, 2));
  if typ = 1 then begin
    for i := 1 to InputArrayLength do begin
      if buff[PS+i-1] <> InputArray[i] then inc(err);
    end;
  end;

  if typ = 2 then begin
    for i := 1 to InputArrayLength do begin
      if buff[(Length(Buf)-PS-1)-(InputArrayLength-i)] <> InputArray[i] then inc(err);
    end;
  end;

  if typ = 3 then begin
    for i := 1 to InputArrayLength do begin
      if buff[EP+PS+i-1] <> InputArray[i] then inc(err);
    end;
  end;

  if err = 0 then
    Result := true
  else
    Result := false;
end;

Function FindHEXInPosition(Sign: String; EP: integer): Boolean;
  var
  tmp: ShortString;
  Typ: WORD;
  PS : dWord;
  HEX: ShortString;
begin
  tmp := Sign;
  Delete(tmp,pos(':',tmp),length(tmp));
  Typ := strtoint(tmp);
  tmp := Sign;
  Delete(tmp,1,pos(':',tmp));
  Delete(tmp,pos(':',tmp),length(tmp));
  Ps := strtoint(Tmp);
  tmp := Sign;
  Delete(tmp,1,pos(':',tmp)+1);
  Delete(tmp,1,pos(':',tmp));
  HEX := TMP;
  Result := FindHexInPOS(Typ,PS,Ep,LowerCase(HEX),Buf);
end;

Function FindHEXInPositionEX(Sign: String; EP: integer): Boolean;
  var
  tmp: ShortString;
  Typ: WORD;
  PS : dWord;
  HEX: ShortString;
begin
  tmp := Sign;
  Delete(tmp,pos(':',tmp),length(tmp));
  Typ := strtoint(tmp);
  tmp := Sign;
  Delete(tmp,1,pos(':',tmp));
  Delete(tmp,pos(':',tmp),length(tmp));
  Ps := strtoint(Tmp);
  tmp := Sign;
  Delete(tmp,1,pos(':',tmp)+1);
  Delete(tmp,1,pos(':',tmp));
  HEX := TMP;
  Result := FindHexInPOS(Typ,PS,Ep,LowerCase(HEX),BUFEX);
end;

//****************************************************************************//

Function FindBytes(BYTESIGN : ShortString; BYTEPOS : Word; Frompos: integer ;Buff: Buffer):Boolean;
  var
  itmp 	: ShortString;
begin
  try
    if FromPos = 1 then begin
  	  itmp := inttostr(Buff[BYTEPOS]) +':'+ inttostr(Buff[BYTEPOS+1])+':'+inttostr(Buff[BYTEPOS+2]) +':'+ inttostr(Buff[BYTEPOS+3]);
    end;
    if FromPos = 2 then begin
 	    itmp := inttostr(Buff[Length(Buff)-1-BYTEPOS-3]) +':'+ inttostr(Buff[Length(Buff)-1-BYTEPOS-2])+':'+inttostr(Buff[Length(Buff)-1-BYTEPOS-1]) +':'+ inttostr(Buff[Length(Buff)-1-BYTEPOS]);
    end;
  except
  end;
	if BYTESIGN = itmp then Result := TRUE else
 	Result := FALSE;
end;

//****************************************************************************//

Function FindByteSign(Sign: String): boolean;
var
  error,i,j,BytesCount,Part   : DWORD;
  SignPos,FromPos,SignTmp,Tmp : ShortString;
begin
  i := 0;
  error := 0;
  BytesCount := 0;
  Tmp := Sign;
  while i = 0 do begin
    if pos('*',Tmp) <> 0 then begin
      BytesCount := BytesCount + 1;
      Delete(Tmp,pos('*',Tmp),1);
    end
    else
      i := 1;
  end;
  Tmp := Sign;
  For i := 1 to BytesCount do
  begin
    SignTmp := '';
    SignPos := '';
    FromPos := '';
    Part := 0;
    For j := 1 to Length(Tmp)-1 do
    begin
      if Part < 3 then
      begin
        if Tmp[j] = '#' then Part := 1;
        if Tmp[j] = '>' then Part := 2;
      end;
      if Tmp[j] = '*' then Part := 3;
      if Part = 0 then
        SignTmp := SignTmp + Tmp[j];
      if Part = 1 then
        SignPos := SignPos + Tmp[j];
      if Part = 2 then
        FromPos := FromPos + Tmp[j];
    end;
    Delete(SignPos,1,1);
    Delete(FromPos,1,1);
    Delete(Tmp,1,pos('*',Tmp));
    if Not FindBytes(SignTmp,StrToInt(SignPos),strtoint(FromPos),BUF) then begin
      Result := False;
      Exit;
    end;
  end;
  if error = 0 then Result := true else Result := false;
end;

//****************************************************************************//

Function FindByteSignEX(Sign: String): boolean;
var
  error,i,j,BytesCount,Part   : DWORD;
  SignPos,FromPos,SignTmp,Tmp : ShortString;
begin
  i := 0;
  error := 0;
  BytesCount := 0;
  Tmp := Sign;
  while i = 0 do begin
    if pos('*',Tmp) <> 0 then begin
      BytesCount := BytesCount + 1;
      Delete(Tmp,pos('*',Tmp),1);
    end else i := 1;
  end;
  Tmp := Sign;
  For i := 1 to BytesCount do
  begin
    SignTmp := '';
    SignPos := '';
    FromPos := '';
    Part := 0;
    For j := 1 to Length(Tmp)-1 do
    begin
      if Part < 3 then
      begin
        if Tmp[j] = '#' then Part := 1;
        if Tmp[j] = '>' then Part := 2;
      end;
      if Tmp[j] = '*' then Part := 3;
      if Part = 0 then
        SignTmp := SignTmp + Tmp[j];
      if Part = 1 then
        SignPos := SignPos + Tmp[j];
      if Part = 2 then
        FromPos := FromPos + Tmp[j];
    end;
    Delete(SignPos,1,1);
    Delete(FromPos,1,1);
    Delete(Tmp,1,pos('*',Tmp));
    if Not FindBytes(SignTmp,StrToInt(SignPos),strtoint(FromPos),BUFEX) then
    begin
      Result := False;
      Exit;
    end;
  end;
  if error = 0 then Result := true else Result := false;
end;

//****************************************************************************//

function BMSearchInBUF( StartPos : BYTE; const S: Buffer; HEX: ShortString) : Integer;
  var
  Pos        : DWORd;
  I          : DWORd;
  BMT        : SBMTable;
  LEN        : DWORd;
  InputArray : Buffer;
begin
  LEN := (Length(Hex) div 2)-1;
  SetLength(InputArray,LEN+1);
  for I := 0 to LEN  do
    InputArray[I]:=StrToInt('$'+Copy(Hex, (I+1) * 2 - 1, 2));
  for i := 0 to 255 do BMT[i] := LEN;
    for i := LEN downto 0 do
      if BMT[(InputArray[i])] =  LEN then
         BMT[(InputArray[i])] := LEN - i;
  Pos := StartPos + LEN -1;
  while Pos < Length(S)-LEN do
    if InputArray[LEN] <> S[Pos] then
      Pos := Pos + BMT[S[Pos]]
      else for i := LEN - 1 downto 1 do
            if InputArray[i] <> S[Pos - LEN + i] then
            begin
              Inc(Pos);
              Break;
            end
            else if i = 1 then
            begin
              Result := Pos - LEN + 1;
              Finalize(InputArray);
              Exit;
            end;
      Result := -1;
      Finalize(InputArray);
end;

function  FindHexSign(Hex: ShortString): boolean;
  var
  B : INTEGER;
begin
  if (POS('{',HEX) <> 0) or (POS('?',HEX) <> 0) or (POS('*',HEX) <> 0)
  or (POS('|',HEX) <> 0) then
  begin
    Result := False;
    exit;
  end;
  B := BMSearchInBUF(0,BUF,Hex);
  if B > -1 then
    Result := True
  else
    Result := False;
end;

function  FindHexSignEX(Hex: ShortString): boolean;
  var
  B : INTEGER;
begin
  if (POS('{',HEX) <> 0) or (POS('?',HEX) <> 0) or (POS('*',HEX) <> 0)
  or (POS('|',HEX) <> 0) then
  begin
    Result := False;
    exit;
  end;
  B := BMSearchInBUF(0,BUFEX,Hex);
  if B > -1 then Result := True
  else Result := False;
end;

//****************************************************************************//

end.

