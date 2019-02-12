unit sts_verdict;

interface

uses Windows;

type
    (* Danger level *)
    TDangers = (tdHIGH, tdMEDIUM, tdLOW, tdNONE);

    (* Verdicts *)
    TVerdicts = (tvNone, tvVirusesAndWorms, tvTrojanPrograms, tvMaliciousTools, tvAdWare, tvPornWare, tvRiskWare);

    (* Names *)
    TNames = record
        Prefix   : string;
        Expanded : string;
        Verdict  : TVerdicts;
    end;

    (* Expanded Name *)
    TName = record
        Name     : WideString;
        Verdict  : TVerdicts;
        Danger   : TDangers;
    end;

const
    sts_names : array [1..72] of TNames = (

    (* Trojan Programs Viruses Names *)

    (Prefix : '#100'; Expanded : 'Backdoor';               Verdict : tvTrojanPrograms;),
    (Prefix : '#101'; Expanded : 'RootKit';                Verdict : tvTrojanPrograms;),
    (Prefix : '#102'; Expanded : 'Packed';                 Verdict : tvTrojanPrograms;),
    (Prefix : '#103'; Expanded : 'Exploit';                Verdict : tvTrojanPrograms;),
    (Prefix : '#104'; Expanded : 'Trojan';                 Verdict : tvTrojanPrograms;),
    (Prefix : '#105'; Expanded : 'Trojan.AOL';             Verdict : tvTrojanPrograms;),
    (Prefix : '#106'; Expanded : 'Trojan.ArcBomb';         Verdict : tvTrojanPrograms;),
    (Prefix : '#107'; Expanded : 'Trojan.Clicker';         Verdict : tvTrojanPrograms;),
    (Prefix : '#108'; Expanded : 'Trojan.Downloader';      Verdict : tvTrojanPrograms;),
    (Prefix : '#109'; Expanded : 'Trojan.Dropper';         Verdict : tvTrojanPrograms;),
    (Prefix : '#110'; Expanded : 'Trojan.Notifier';        Verdict : tvTrojanPrograms;),
    (Prefix : '#111'; Expanded : 'Trojan.Proxy';           Verdict : tvTrojanPrograms;),
    (Prefix : '#112'; Expanded : 'Trojan.PSW';             Verdict : tvTrojanPrograms;),
    (Prefix : '#113'; Expanded : 'Trojan.Spy';             Verdict : tvTrojanPrograms;),
    (Prefix : '#114'; Expanded : 'Trojan.DDoS';            Verdict : tvTrojanPrograms;),
    (Prefix : '#115'; Expanded : 'Trojan.IM';              Verdict : tvTrojanPrograms;),
    (Prefix : '#116'; Expanded : 'Trojan.SMS';             Verdict : tvTrojanPrograms;),
    (Prefix : '#117'; Expanded : 'Trojan.Mailfinder';      Verdict : tvTrojanPrograms;),
    (Prefix : '#118'; Expanded : 'Trojan.Ransom';          Verdict : tvTrojanPrograms;),
    (Prefix : '#119'; Expanded : 'Trojan.GameThief';       Verdict : tvTrojanPrograms;),
    (Prefix : '#120'; Expanded : 'Trojan.Banker';          Verdict : tvTrojanPrograms;),
    (Prefix : '#121'; Expanded : 'Trojan.Packed';          Verdict : tvTrojanPrograms;),
    (Prefix : '#122'; Expanded : 'Trojan.Agent';           Verdict : tvTrojanPrograms;),
    (Prefix : '#123'; Expanded : 'Trojan.OnlineGames';     Verdict : tvTrojanPrograms;),

    (Prefix : '#190'; Expanded : 'SpamTool';               Verdict : tvTrojanPrograms;),

    (* Viruses Names *)

    (Prefix : '#200'; Expanded : 'Email.Worm';             Verdict : tvVirusesAndWorms;),
    (Prefix : '#201'; Expanded : 'IM.Worm';                Verdict : tvVirusesAndWorms;),
    (Prefix : '#202'; Expanded : 'IRC.Worm';               Verdict : tvVirusesAndWorms;),
    (Prefix : '#203'; Expanded : 'Net.Worm';               Verdict : tvVirusesAndWorms;),
    (Prefix : '#204'; Expanded : 'P2P.Worm';               Verdict : tvVirusesAndWorms;),
    (Prefix : '#205'; Expanded : 'Worm';                   Verdict : tvVirusesAndWorms;),
    (Prefix : '#206'; Expanded : 'Virus';                  Verdict : tvVirusesAndWorms;),
    (Prefix : '#207'; Expanded : 'Win32';                  Verdict : tvVirusesAndWorms;),
    (Prefix : '#208'; Expanded : 'Win32.HLLW';             Verdict : tvVirusesAndWorms;),
    (Prefix : '#209'; Expanded : 'Worm.Agent';             Verdict : tvVirusesAndWorms;),

    (* Malicious Viruses Names *)

    (Prefix : '#300'; Expanded : 'Constructor';            Verdict : tvMaliciousTools;),
    (Prefix : '#301'; Expanded : 'DoS';                    Verdict : tvMaliciousTools;),
    (Prefix : '#302'; Expanded : 'Flooder';                Verdict : tvMaliciousTools;),
    (Prefix : '#303'; Expanded : 'HackTool';               Verdict : tvMaliciousTools;),
    (Prefix : '#304'; Expanded : 'Hoax';                   Verdict : tvMaliciousTools;),
    (Prefix : '#305'; Expanded : 'Spoofer';                Verdict : tvMaliciousTools;),
    (Prefix : '#306'; Expanded : 'VirTool';                Verdict : tvMaliciousTools;),
    (Prefix : '#307'; Expanded : 'Email.Flooder';          Verdict : tvMaliciousTools;),
    (Prefix : '#308'; Expanded : 'IM.Flooder';             Verdict : tvMaliciousTools;),
    (Prefix : '#309'; Expanded : 'SMS.Flooder';            Verdict : tvMaliciousTools;),
    (Prefix : '#300'; Expanded : 'Nuker';                  Verdict : tvMaliciousTools;),
    (Prefix : '#301'; Expanded : 'Sniffer';                Verdict : tvMaliciousTools;),

    (* PUA Viruses Names *)

    (Prefix : '#350'; Expanded : 'PUA.BadJoke';            Verdict : tvRiskWare;),
    (Prefix : '#351'; Expanded : 'PUA.AdTool';             Verdict : tvRiskWare;),
    (Prefix : '#352'; Expanded : 'PUA.AdWare';             Verdict : tvAdWare;),
    (Prefix : '#353'; Expanded : 'PUA.Porn.Dialer';        Verdict : tvPornWare;),
    (Prefix : '#354'; Expanded : 'PUA.Porn.Downloader';    Verdict : tvPornWare;),
    (Prefix : '#355'; Expanded : 'PUA.Porn.Tool';          Verdict : tvPornWare;),
    (Prefix : '#356'; Expanded : 'PUA.Client.IRC';         Verdict : tvRiskWare;),
    (Prefix : '#357'; Expanded : 'PUA.Dialer ';            Verdict : tvRiskWare;),
    (Prefix : '#358'; Expanded : 'PUA.Downloader';         Verdict : tvRiskWare;),
    (Prefix : '#359'; Expanded : 'PUA.Monitor';            Verdict : tvRiskWare;),
    (Prefix : '#360'; Expanded : 'PUA.PSWTool';            Verdict : tvRiskWare;),
    (Prefix : '#361'; Expanded : 'PUA.RemoteAdmin';        Verdict : tvRiskWare;),
    (Prefix : '#362'; Expanded : 'PUA.Server.FTP';         Verdict : tvRiskWare;),
    (Prefix : '#363'; Expanded : 'PUA.Server.Proxy';       Verdict : tvRiskWare;),
    (Prefix : '#364'; Expanded : 'PUA.Server.Telnet';      Verdict : tvRiskWare;),
    (Prefix : '#365'; Expanded : 'PUA.Server.Web';         Verdict : tvRiskWare;),
    (Prefix : '#366'; Expanded : 'PUA.RiskTool';           Verdict : tvRiskWare;),
    (Prefix : '#367'; Expanded : 'PUA.NetTool';            Verdict : tvRiskWare;),
    (Prefix : '#368'; Expanded : 'PUA.Client.P2P';         Verdict : tvRiskWare;),
    (Prefix : '#369'; Expanded : 'PUA.Client.SMTP';        Verdict : tvRiskWare;),
    (Prefix : '#370'; Expanded : 'PUA.WebToolbar';         Verdict : tvRiskWare;),
    (Prefix : '#371'; Expanded : 'PUA.FraudTool';          Verdict : tvRiskWare;),
    (Prefix : '#372'; Expanded : 'PUA.Hoax';               Verdict : tvRiskWare;),
    (Prefix : '#374'; Expanded : 'PUA.Tool';               Verdict : tvRiskWare;),
    (Prefix : '#374'; Expanded : 'PUA.Packed';             Verdict : tvRiskWare)
    );

function sts_VerdictName(dbName: WideString): TName;
function sts_GetDanger(Verdict: TVerdicts): TDangers;

implementation

function sts_GetDanger(Verdict: TVerdicts): TDangers;
begin
    case Verdict of
        tvVirusesAndWorms : sts_GetDanger := tdHIGH;
        tvTrojanPrograms  : sts_GetDanger := tdHIGH;
        tvMaliciousTools  : sts_GetDanger := tdMEDIUM;
        tvAdWare          : sts_GetDanger := tdMEDIUM;
        tvPornWare        : sts_GetDanger := tdMEDIUM;
        tvRiskWare        : sts_GetDanger := tdLOW;
        tvNone            : sts_GetDanger := tdNONE;
    end;
end;

function sts_VerdictName(dbName: WideString): TName stdcall; 
var
    i, ps: integer;
    pt: string;
begin
    result.Name     := dbName;
    result.Verdict  := tvNone;
    result.Danger   := tdNONE;
    pt              := '';
    (* *)
    for i := 1 to length(sts_names) - 1 do begin
        ps := pos(sts_names[i].Prefix, dbName);
        if ps <> 0 then begin
            pt := dbName;
            delete(pt, ps , length(sts_names[i].Prefix));
            insert(sts_names[i].Expanded, pt, ps);
            (* *)
            result.Name     := pt;
            result.Verdict  := sts_names[i].Verdict;
            result.Danger   := sts_GetDanger(sts_names[i].Verdict);
            (* *)
            break;
        end;
    end;
end;

end.
