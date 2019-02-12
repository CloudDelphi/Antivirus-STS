////////////////////////////////////////////////
//                    Scanner                 //
////////////////////////////////////////////////
//                Types  Unit                 //
////////////////////////////////////////////////

unit sTypes;

Interface

uses windows, Classes;

const
  MES_NONE                = 0;

  DB_CRC                  = 0;
  DB_HEX                  = 1;
  DB_BYTE                 = 2;
  DB_HEX_POS				      = 3;	

  API_OTHER               = 1000;
  API_SCAN                = 1001;
  API_SCANATRUN           = 1002;
  API_SCANFILE            = 1003;
  
  MES_SCANDIR             = 1101;
  MES_SCANFILE            = 1102;
  MES_PLUGINWAIT          = 1103;
  MES_PLUGINEXIT          = 1104;
  MES_EXITFROMWAIT        = 1121;

  MES_ONPROGRESS          = 2000;
  MES_ONPROGRESSEX        = 2001;
  MES_ONVIRFOUND          = 2100;
  MES_ONREADERROR         = 2110;
  MES_ADDTOLOG            = 2130;
  MES_ONSCANEXECUTE       = 2140;
  MES_ONSCANCOMPLETE      = 2141;
  MES_SKIPBYSIZE          = 2142;

  MES_SHIELD_INFECT       = 3120;
  MES_SHIELD_RESTORE      = 3121;
  MES_SHIELD_ERR_RESTORE  = 3122;

  MES_ERRORONINIT         = 3131;
  MES_ERROR               = 3131;
  MES_CREATENEWCFG        = 3130;
  MES_ERRORLOADCFG        = 3132;
  MES_ERRORCREATECFG      = 3133;
  MES_ERRORSAVECFG        = 3140;
  MES_DBNIL               = 3160;
  MES_DB_DONTLOAD         = 3161;
  MES_SENDSCNFILE         = 3170;
  MES_SENDSHWFILE         = 3171;

  MES_INITKERNEL          = 4000;
  MES_INITEXTLIST         = 4001;
  MES_LOADMODULES         = 4002;
  MES_LOADBASES           = 4003;
  MES_LOADCONFIG          = 4004;
  MES_INITSHIELD          = 4005;
  MES_OPTIONSPARAM        = 4400;
  MES_INITAPI             = 4500;
  //
  MES_LOCKINPUT           = 7000;
  MES_UNLOCKINPUT         = 7001;
  //
  MES_SCANMAXPROGRESS     = 8000;
  MES_PREPARINGTOSCAN     = 8001;
  MES_LOADDBDATE          = 8088;
  //
type
  TKernelMessageAPI      = Procedure(MES: Integer; const Pr_0: Integer = 0; Pr_1: String = ''; Pr_2: String = '');

type
  TAvAction              = (TScanFile,TScanDir);

var
  KernelMessageAPI       : TKernelMessageAPI;

  MaxProgress            : integer = 0;

  ScannedDataSize        : Real;
  
//****************************************************************************//

  OtherParams            : TStringList;
  AiDConfig              : TStringList;

  OPT_DB_DIR             : String;
  OPT_DB_LOAD            : boolean;

  OPT_MODULE_DIR         : String;
  OPT_MODULES_LOAD       : boolean;
  OPT_MODULES_UNLOAD     : TStringList;

  OPT_SCAN_SUBDIR        : boolean;
  OPT_USE_MODULES        : boolean;
  OPT_USE_MODULE_ATRUN   : boolean;
  OPT_USE_MODULE_ATSCAN  : boolean;
  OPT_USE_HEX_MODE       : boolean;
  OPT_USE_CRC_MODE       : boolean;
  OPT_USE_BYTE_MODE      : boolean;
  OPT_USE_HEX_INPOS      : boolean;
  OPT_USE_OTHER_MODE     : boolean;
  OPT_USE_SIZE_LIMIT     : boolean;
  OPT_SIZELIMIT          : integer;


  OPT_SEND_ERR_MES       : boolean;
  OPT_SEND_ERR_SCAN      : boolean;
  OPT_SEND_ERR_READ      : boolean;
  OPT_SEND_ERR_INIT      : boolean;

  OPT_SEND_SCAN_FILE     : boolean;

  OPT_SEND_SHOW_FILE     : boolean;

  OPT_USE_SHIELD         : boolean;
  OPT_SILENT_SHIELD_MODE : boolean;

//****************************************************************************//

implementation

end.

