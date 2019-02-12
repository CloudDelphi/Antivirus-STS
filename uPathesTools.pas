unit uPathesTools;

interface
uses Windows, SysUtils;

procedure SurePath (pathen : string);
Procedure PrepareToSave(Path: String);
function DirectoryPresent(Dir: String): boolean;

implementation

function antaltecken (orgtext,soktext : string) : integer;
var
    i,traffar,soklengd : integer;
begin
    traffar := 0;
    soklengd := length(soktext);
    for i := 1 to length(orgtext) do
        if soktext = copy(orgtext,i,soklengd) then
           traffar := traffar +1;
    result := traffar;
end;

function StringReplace (text,byt,mot : string ) :string;
var
    plats : integer;
begin
    if pos(byt,text)  >  0 then
    begin
        plats := pos(byt,text);
        delete (text,plats,length(byt));
        insert (mot,text,plats);
    end;
    result := text;
end;

procedure SurePath (pathen : string);
var
    temprad,del1 : string;
    antal : integer;
begin
    antal := antaltecken (pathen,'\');
    if antal < 3 then
        createdir(pathen)
    else
    begin
        if pathen[length(pathen)]  <>  '\' then
            pathen := pathen+'\';
        pathen := stringreplace(pathen,'\','/');
        del1 := copy(pathen,1,pos('\',pathen));
        pathen := stringreplace(pathen,del1,'');
        del1 := stringreplace(del1,'/','\');
        createdir (del1);
        while pathen  <>  '' do
        begin
            temprad := copy(pathen,1,pos('\',pathen));
            pathen := stringreplace(pathen,temprad,'');
            del1 := del1+ temprad;
            temprad := '';
            createdir(del1);
        end;
    end;
end;

function DirectoryPresent(Dir: String): boolean;
begin
    SurePath(Dir);
    Result := DirectoryExists(Dir);
end;

Procedure PrepareToSave(Path: String);
begin
    SurePath(ExtractFilePath(Path));
end;

end.
