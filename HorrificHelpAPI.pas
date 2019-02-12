unit HorrificHelpAPI;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Winsock;

type
  // структуры для старых функций
  PMIB_TCPROW = ^MIB_TCPROW;
  MIB_TCPROW = record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
  end;

  PMIB_TCPTABLE = ^MIB_TCPTABLE;
  MIB_TCPTABLE = record
    dwNumEntries: DWORD;
    table: array [0..0] of MIB_TCPROW;
  end;

  // Connection data
  PMIB_UDPROW = ^MIB_UDPROW;
  MIB_UDPROW = record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
  end;

  PMIB_UDPTABLE = ^MIB_UDPTABLE;
  MIB_UDPTABLE = record
    dwNumEntries: DWORD;
    table: array [0..0] of MIB_UDPROW;
  end;


  // структуры для расширенных функций

  // TCP ROW
  PMIB_TCPEXROW = ^TMIB_TCPEXROW;
  TMIB_TCPEXROW = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwProcessID: DWORD;
  end;

  // TCP Table
  PMIB_TCPEXTABLE = ^TMIB_TCPEXTABLE;
  TMIB_TCPEXTABLE = packed record
    dwNumEntries: DWORD;
    Table: array[0..0] of TMIB_TCPEXROW;
  end;

  // UDP ROW
  PMIB_UDPEXROW = ^TMIB_UDPEXROW;
  TMIB_UDPEXROW = packed record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwProcessID: DWORD;
  end;

  // UDP Table
  PMIB_UDPEXTABLE = ^TMIB_UDPEXTABLE;
  TMIB_UDPEXTABLE = packed record
    dwNumEntries: DWORD;
    Table: array[0..0] of TMIB_UDPEXROW;
  end;

  TProcessEntry32 = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;
    cntThreads: DWORD;
    th32ParentProcessID: DWORD;
    pcPriClassBase: Longint;
    dwFlags: DWORD;
    szExeFile: array [0..MAX_PATH - 1] of Char;
  end;

var
 // старые функции
 GetTcpTable: function (pTcpTable: PMIB_TCPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
 {$EXTERNALSYM GetTcpTable}

 GetUdpTable: function (pUdpTable: PMIB_UDPTABLE; var pdwSize: DWORD; bOrder: BOOL): DWORD; stdcall;
 {$EXTERNALSYM GetUdpTable}

 // новые функции
 AllocateAndGetTcpExTableFromStack: function (pTCPTable: PMIB_TCPEXTABLE;
    bOrder: BOOL; heap: THandle; zero: DWORD; flags: DWORD): DWORD; stdcall;
 {$EXTERNALSYM AllocateAndGetTcpExTableFromStack}

 AllocateAndGetUdpExTableFromStack: function (pUDPTable: PMIB_UDPEXTABLE;
    bOrder: BOOL; heap: THandle; zero: DWORD; flags: DWORD): DWORD; stdcall;
 {$EXTERNALSYM AllocateAndGetTcpExTableFromStack}

 CreateToolhelp32Snapshot: function (dwFlags, th32ProcessID: DWORD): THandle; stdcall;
 {$EXTERNALSYM CreateToolhelp32Snapshot}

 Process32First: function (hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;
 {$EXTERNALSYM Process32First}

 Process32Next: function (hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;
 {$EXTERNALSYM Process32Next}
 
implementation

var
 HIpHlpApi: THandle = 0;

function LoadAPIHelpAPI: Boolean;
begin
 Result := False;
 if HIphlpapi = 0 then
  HIpHlpApi := LoadLibrary('iphlpapi.dll');

 if HIpHlpApi > HINSTANCE_ERROR then
  begin
   @GetTcpTable := GetProcAddress(HIpHlpApi, 'GetTcpTable');
   @GetUdpTable := GetProcAddress(HIpHlpApi, 'GetUdpTable');

   @AllocateAndGetTcpExTableFromStack := GetProcAddress(HIpHlpApi, 'AllocateAndGetTcpExTableFromStack');
   @AllocateAndGetUdpExTableFromStack := GetProcAddress(HIpHlpApi, 'AllocateAndGetUdpExTableFromStack');

   @CreateToolhelp32Snapshot := GetProcAddress(GetModuleHandle('kernel32.dll'), 'CreateToolhelp32Snapshot');
   @Process32First := GetProcAddress(GetModuleHandle('kernel32.dll'), 'Process32First');
   @Process32Next := GetProcAddress(GetModuleHandle('kernel32.dll'), 'Process32Next');
   Result:=true;
  end;
end;

procedure FreeAPIHelpAPI;
begin
 if HIpHlpApi <> 0 then FreeLibrary(HIpHlpApi);
 HIpHlpApi := 0;
end;


initialization
 LoadAPIHelpAPI;

finalization
 FreeAPIHelpAPI;

end.
