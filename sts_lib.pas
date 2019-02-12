unit sts_lib;
interface
  uses windows, classes;

    const
    sts_DLL = 'KernelLib.dll';

    { TODO : ��������� ���������� ������� sts_filescan(); }
    sts_CLEAR    = 0;
    sts_VIRUS    = 1;
    sts_ESIZE    = 2;
    sts_EREAD    = 3;
    sts_EMPTY    = 4;

    { TODO : ��������� ������ ��� ������������� � �������� ��� (����������) }
    sts_INIT        = 0;
    sts_INIT_ERROR  = 1;

    sts_LOAD_DB     = 2;
    sts_EREAD_DB    = 3;
    sts_EOPEN_DB    = 4;

    sts_LOAD_PDB    = 5;
    sts_EREAD_PDB   = 6;
    sts_EOPEN_PDB   = 7;
    sts_BUILD_PDB   = 8;

    sts_PARSE_EVN   = 9;
    sts_PARSE_ERR   = 10;
    sts_PARCE_UST   = 11;

    sts_UNARCH_FL   = 31;
    type
    { TODO : ��������� ������ (��� ������������� ��������� ��������������� �����������) }
    sts_opt_scn  = (sts_scan_html, sts_scan_pdf, sts_scan_graphic, sts_scan_pe,
                   sts_scan_other, sts_unpack_rar, sts_unpack_zip, sts_use_force);

    sts_opts_scn = set of sts_opt_scn;

    { TODO : ������� ��� ������ }
    psts_engine       = pointer;

    { TODO : ����� ��� ������������ }
    sts_buffer        = array of char;

    { TODO : ��������� ��������� ������������ ����� (0-100%) (-1 ��� ���������� �������)}
    psts_scan_progres = ^sts_scan_progres;
    sts_scan_progres  = procedure(progres: integer);

    { TODO : ����� ���������� ��������� }
    psts_dbg_message  = ^sts_dbg_message;
    sts_dbg_message   = procedure(msg: dword; const args: array of const);

    { TODO : ���������� � PE ����� }
    sts_section = record
        sec_raw_size, sec_raw_offset: integer;
        sec_vir_size, sec_vir_offset: integer;
        sec_flag: integer;
        sec_name, sec_md5: WideString;
    end;

    sts_peinfo = record
        pe_entrypoint,
        pe_seccount: integer;
        pe_size: integer;
        pe_linker, pe_epsection, pe_subsys: WideString;
        pe_firstbytes: array [1..4] of char;
        pe_sections: array [0..32] of sts_section;
    end;
type
    (* Danger level *)
    TDangers = (tdHIGH, tdMEDIUM, tdLOW, tdNONE);
    (* Verdict *)
    TVerdicts = (tvNone, tvVirusesAndWorms, tvTrojanPrograms, tvMaliciousTools, tvAdWare, tvPornWare, tvRiskWare);

    TNames = record
        Prefix   : string;
        Expanded : string;
        Verdict  : TVerdicts;
    end;

    TName = record
        Name     : WideString;
        Verdict  : TVerdicts;
        Danger   : TDangers;
    end;
    (* ������������� ������ *)
    procedure init_engine(var engine: psts_engine; debug: sts_dbg_message); external sts_DLL;
    (* ��������������� ������ *)
    procedure free_engine(var engine: psts_engine); external sts_DLL;
    (* ��������� �������� ������������ ������ (��� ������������� ��������� ��������������� �����������) *)
    procedure sts_setoptions(engine: psts_engine; scanners: sts_opts_scn; maxfsize, maxasize: int64; tempdir: pchar); external sts_DLL;
    (* ���������� ��������� � ����������������� ������ *)
    procedure sts_readsign(root: psts_engine; const sign: pchar); external sts_DLL;
    (* �������� ������������ ������������ �� *)
    procedure sts_packing_db(dbfile: pchar; dbdate: pchar; license: pchar); external sts_DLL;
    (* �������� ����������� �� *)
    procedure sts_load_xdb(root: psts_engine; filename: pchar); external sts_DLL;
    (* �������� ���������� �� *)
    procedure sts_load_xpb(root: psts_engine; filename: pchar); external sts_DLL;
    (* �������� ���� �� �� �������� ���������� *)
    procedure sts_load_dbdir(engine: psts_engine; dir: pchar; loadxdb: boolean); external sts_DLL;
    (* ������������ ����� �� ������� ��������� (��������� ������: sts_CLEAR, sts_VIRUS, sts_EREAD, sts_ESIZE) *)
    function sts_matchfile(engine: psts_engine; filename: pchar; var virname: pchar; progresscall: sts_scan_progres; debugcall: sts_dbg_message; progress: boolean = false): integer; external sts_DLL;
    (* ������������ ������ (return sts_CLEAR, sts_VIRUS, sts_EREAD, sts_ESIZE) (������������ ��� �������� md5)*)
    function sts_scanbuffer(engine: psts_engine; buffer: sts_buffer; ftype: dword; var virname: pchar): boolean; external sts_DLL;
    (* ���-�� ���������� �������� *)
    function sts_sigcount(engine: psts_engine): integer; external sts_DLL;
    (* ������������ ���� ���� ���������� �� *)
    function sts_db_date(engine: psts_engine): pchar; external sts_DLL;
    (* ������������ ������ *)
    function sts_name: pchar; external sts_DLL;
    (* ������ ������ *)
    function sts_version: pchar; external sts_DLL;
    (* ������� ������ � 16��-������ ������� *)
    function sts_str2hex(const str: widestring): widestring; external sts_DLL;
    (* md5 ����� *)
    function sts_md5file(const filename: widestring): widestring; external sts_DLL;
    (* md5 ������ *)
    function sts_md5string(const str: widestring): widestring; external sts_DLL;
    (* ���������� � �� ����� *)
    function sts_getpeinfo(filename: WideString; var peinfo: sts_peinfo): boolean; external sts_DLL;
    (* �������� ���� �� ���� � ����� ���� *)
    function sts_inwhitelist(engine: psts_engine; mdhash: pchar; size: integer; var whitename: pchar): boolean; external sts_DLL;
    (* �������� ����� *)
    function sts_deletefile(FileName: pchar) : boolean; external sts_DLL;
    (* ������������ HTML ������ *)
    function sts_html_exctract(filename: pchar; path: pchar): boolean; external sts_DLL;
    (* ��������� ��� ���� �� ������� spos �������� � count ���� *)
    function sts_getfilehex(filename: widestring; spos, count: integer): widestring; external sts_DLL;
    (* *)
    function sts_VerdictName(dbName: WideString): TName; external sts_DLL;
    (* ���������� ����������� �� *)
    procedure sts_unpack_xdb(filename: pchar); external sts_DLL;
    (* *)
    Procedure sts_writeline(fname, line: pchar); external sts_DLL;


implementation

end.
