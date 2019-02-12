unit TextFileStream;

interface

uses Classes;

type

  TTextFileStream = class(TFileStream)
  public
    function Eof: Boolean;
    function ReadLn: string;
    procedure WriteString(const s: string);
    procedure WriteLn(const s: string); overload;
    procedure WriteLn; overload;
  end;

const

  LineEnd = #13#10;

implementation

function TTextFileStream.Eof: Boolean;
begin
  result := (Position >= Size);
end;

function TTextFileStream.ReadLn: string;
const
  BlkSize = 128;
var
  c: char;
  i: Integer;
begin
  SetLength(Result, BlkSize);
  i := 0;
  while not Eof do begin
    Read(c, SizeOf(c));
    if c = #13 then begin
      Read(c, SizeOf(c));
      if c <> #10 then begin
        Seek(SizeOf(c), soFromCurrent);
      end;
      break;
    end;
    if c = #10 then begin
      break;
    end;
    Inc(i);
    if i > BlkSize then
      SetLength(Result, Length(Result) + BlkSize);
    Result[i] := c;
  end;
  SetLength(Result, i);
end;

procedure TTextFileStream.WriteString(const s: string);
var
  i: integer;
begin
  for i := 1 to Length(s) do begin
    Write(s[i], SizeOf(s[i]));
  end;
end;

procedure TTextFileStream.WriteLn;
begin
  Write(LineEnd, Length(LineEnd));
end;

procedure TTextFileStream.WriteLn(const s: string);
begin
  WriteString(s);
  WriteLn;
end;

end.