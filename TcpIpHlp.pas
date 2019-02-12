unit TcpIpHlp; { TCP/IP helper }

interface

uses Windows, Winsock, SysUtils;

CONST SIO_RCVALL = $98000001;

type
  THdrIP = packed record   // IP header (RFC 791)
    ihl_ver : BYTE;        // Combined field:
                           //   ihl:4 - IP header length divided by 4
                           //   version:4 - IP version
    tos     : BYTE;        // IP type-of-service field
    tot_len : WORD;        // total length
    id      : WORD;        // unique ID
    frag_off: WORD;        // Fragment Offset + fragmentation flags (3 bits)
    ttl     : BYTE;        // time to live
    protocol: BYTE;        // protocol type
    check   : WORD;        // IP header checksum
    saddr   : DWORD;       // source IP
    daddr   : DWORD;       // destination IP
   {The options start here...}
  end;
  PHdrIP = ^THdrIP;

  (* Most of IP header is self-explanatory, but here are some
     extra details for the curious (more in RFC 791):

    -ih.ihl is header length in bytes divided by 4
     Internet Header Length is the length of the internet
     header in 32 bit words, and thus points to the beginning
     of the data.  Note that the minimum value for a correct
     header is 5.

    -ih.tos - IP type-of-service field provides an indication of the
     quality of service desired. Several networks offer service precedence,
     which somehow treats high precedence traffic as more important than
     other traffic (generally by accepting only traffic above a certain
     precedence at time of high load).

    -ih.id  - An identifying value assigned by the sender to aid in
     assembling the fragments of a datagram.

    -ih.frag_off contains 3 bit fragmentation flags and fragment offset.
     These are used to keep track of the pieces when a datagram has to
     be split up. This can happen when datagrams are forwarded through
     a network for which they are too big. See RFC815 about reassembly.
       Bit 0: reserved, must be zero
       Bit 1: (DF) 0 = May Fragment,  1 = Don't Fragment.
       Bit 2: (MF) 0 = Last Fragment, 1 = More Fragments.
       Bits?: indicates where in the datagram this fragment belongs

    -ih.protocol tells IP at the other end to send the datagram
     to TCP. Although most IP traffic uses TCP, there are other
     protocols that can use IP, so you have to tell IP which
     protocol to send the datagram to.

    -ih.check[sum] allows IP at the other end to verify that the header
     wasn't damaged in transit. Note that TCP and IP have separate
     checksums. IP only needs to be able to verify that the header
     didn't get damaged in transit, or it could send a message to
     the wrong place.
   *)

  THdrTCP = packed record     // TCP header (RFC 793)
    source : WORD;  // source port
    dest   : WORD;  // destination port
    seq    : DWORD; // sequence number
    ack_seq: DWORD; // next sequence number
    flags  : WORD;  // Combined field:
                    //   res1:4 - reserved, must be 0
                    //   doff:4 - TCP header length divided by 4
                    //   fin:1  - FIN
                    //   syn:1  - SYN
                    //   rst:1  - Reset
                    //   psh:1  - Push
                    //   ack:1  - ACK
                    //   urg:1  - Urgent
                    //   res2:2 - reserved, must be 0
    window : WORD;  // window size
    check  : WORD;  // checksum, computed later
    urg_ptr: WORD;  // used for async messaging?
  end;
  PHdrTCP = ^THdrTCP;
  (* Details of TCP header can be found in RFC 793

    -th.seq - the sequence number of the first data octet in this segment
     (except when SYN is present). If SYN is present the sequence number
     is the initial sequence number (ISN) and the first data octet is ISN+1.

    -th.doff - data offset - the number of 32 bit words in the TCP Header.
     This indicates where the data begins. The TCP header (even one
     including options) is an integral number of 32 bits long.

    -th.ack_seq is used when ACK flag is set. If ACK is set this field
     contains the value of the next sequence number the sender of the
     segment is expecting to receive. Once a connection is established
     this is always sent. This simply means that receiver got all the
     octets up to the specific sequence number.
     For example, sending a packet with an acknowledgement of 1500
     indicates that you have received all the data up to octet
     number 1500. If the sender doesn't get an acknowledgement
     within a reasonable amount of time, it sends the data again.

    -th.window is used to control how much data can be in transit
     at any one time. It is not practical to wait for each datagram
     to be acknowledged before sending the next one. That would slow
     things down too much. On the other hand, you can't just keep
     sending, or a fast computer might overrun the capacity of a slow
     one to absorb data. Thus each end indicates how much new data
     it is currently prepared to absorb by putting the number of
     octets in its "window" field. As the computer receives data,
     the amount of space left in its window decreases. When it goes
     to zero, the sender has to stop. As the receiver processes
     the data, it increases its window, indicating that it is ready
     to accept more data.
     [ See RFC813 for details and "silly-window-syndrome" ]
     Often the same datagram can be used to acknowledge receipt of
     a set of data and to give permission for additional new data
     (by an updated window).

    -th.urgent field allows one end to tell the other to skip ahead
     in its processing to a particular octet. This is often useful
     for handling asynchronous events, for example when you type
     a control character or other command that interrupts output.
   *)

  THdrUDP = packed record  // UDP header (RFC 768)
    src_port: WORD;        // source port
    dst_port: WORD;        // destination port
    length  : WORD;        // length, including this header
    checksum: WORD;        // UDP checksum
  end;
  PHdrUDP = ^THdrUDP;

CONST
 { Option to use with [gs]etsockopt at the IPPROTO_IP level }

 IP_OPTIONS                =  1; { set/get IP options }
 IP_HDRINCL                =  2; { header is included with data }
 IP_TOS                    =  3; { IP type of service and preced}
 IP_TTL                    =  4; { IP time to live }
 IP_MULTICAST_IF           =  9; { set/get IP multicast interface}
 IP_MULTICAST_TTL          = 10; { set/get IP multicast ttl }
 IP_MULTICAST_LOOP         = 11; { set/get IP multicast loopback }
 IP_ADD_MEMBERSHIP         = 12; { add an IP group membership }
 IP_DROP_MEMBERSHIP        = 13; { drop an IP group membership }
 IP_DONTFRAGMENT           = 14; { don't fragment IP datagrams }
 IP_ADD_SOURCE_MEMBERSHIP  = 15; { join IP group/source }
 IP_DROP_SOURCE_MEMBERSHIP = 16; { leave IP group/source }
 IP_BLOCK_SOURCE           = 17; { block IP group/source }
 IP_UNBLOCK_SOURCE         = 18; { unblock IP group/source }
 IP_PKTINFO                = 19; { receive packet information for ipv4}

 { network interface types }
 IFF_UP            = $00000001; { The interface is running }
 IFF_BROADCAST     = $00000002; { The broadcast feature is supported }
 IFF_LOOPBACK      = $00000004; { The loopback interface }
 IFF_POINTTOPOINT  = $00000008; { The interface is using point-to-point link}
 IFF_MULTICAST     = $00000010; { The multicast feature is supported }

type
  TTcpFlagType = (ftFIN, ftSYN, ftRST, ftPSH, ftACK, ftURG);
  TEnumInterfacesEvent = procedure (value: String; iff_type: Integer) of Object;


// get name given a number
//
function  GetIPProtoName(protocol: Byte): String;
function  GetServiceName(s_port, d_port: Integer): String;
function  GetICMPType(x: Byte): String;

// misc common routines
//
procedure CleanupWinsock; overload;
procedure CleanupWinsock(VAR socket: TSocket); overload;
function  Win2KDetected: Boolean;
procedure EnumInterfaces(cb: TEnumInterfacesEvent; iff_types: Integer);
function  InitWinsock(hi_ver, lo_ver: Byte): String;
function  ResolveHostAddress(name: String): u_long;

// these routines manipulate combined fields
// (set/get nibbles or bits)
//
procedure SetTHdoff(VAR th: THdrTCP; value: Byte);
function  GetTHdoff(th: THdrTCP): Word;
procedure SetTHflag(VAR th: THdrTCP; flag: TTcpFlagType; on: Boolean);
function  GetTHflag(th: THdrTCP; flag: TTcpFlagType): Boolean;
procedure SetIHver(VAR ih: THdrIP; value: Byte);
function  GetIHver(ih: THdrIP): Byte;
procedure SetIHlen(VAR ih: THdrIP; value: Byte);
function  GetIHlen(ih: THdrIP): Word;

// checksum function used for IP header, TCP, UDP, etc.
//
function  CalculateChecksum(addr: PWord; len: Integer): Word;

// Winsock 2 functions, for import
//
function getsockopt(s: TSocket; level, optname: Integer; optval: PChar; var optlen: Integer): Integer; stdcall;
function setsockopt(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer; stdcall;

function WSAIoctl(s: TSocket;
  dwIoControlCode: DWORD;
  lpvInBuffer: Pointer;
  cbInBuffer: DWORD;
  lpvOutBuffer: Pointer;
  cbOutBuffer: DWORD;
  lpcbBytesReturned: LPDWORD;
  lpOverlapped: Pointer;
  lpCompletionRoutine: Pointer): Integer; stdcall;

implementation

function getsockopt;   far; external 'ws2_32.dll' name 'getsockopt';
function setsockopt;   far; external 'ws2_32.dll' name 'setsockopt';
function WSAIoctl;     far; external 'ws2_32.dll' name 'WSAIoctl';

type
  TIPProto = record
    iType: word;
    iName: String;
  end;

  TWellKnownSvc = record
    port: Integer;
    svc: string[20];
  end;

CONST
  // Protocol types
  //
  IpProto: Array[1..5] Of TIPProto = (
    (iType: IPPROTO_IP;   iName: 'IP'),
    (iType: IPPROTO_ICMP; iName: 'ICMP'),
    (iType: IPPROTO_IGMP; iName: 'IGMP'),
    (iType: IPPROTO_TCP;  iName: 'TCP'),
    (iType: IPPROTO_UDP;  iName: 'UDP')
  );

  // Well known services
  //
  WellKnownSvcs: array[1..43] of TWellKnownSvc = (
    ( port:   0; svc: 'LOOPBACK'),
    ( port:   1; svc: 'TCPMUX  '),   { TCP Port Service Multiplexer  }
    ( port:   7; svc: 'ECHO    ' ),  { Echo                          }
    ( port:   9; svc: 'DISCARD ' ),  { Discard                       }
    ( port:  13; svc: 'DAYTIME ' ),  { DayTime                       }
    ( port:  17; svc: 'QOTD    ' ),  { Quote Of The Day              }
    ( port:  19; svc: 'CHARGEN ' ),  { Character Generator           }
    ( port:  20; svc: 'FTP_DATA' ),  { Ftp                           }
    ( port:  21; svc: 'FTP_CTL ' ),  { File Transfer Control Protocol}
    ( port:  22; svc: 'SSH     ' ),  { SSH Remote Login Protocol     }
    ( port:  23; svc: 'TELNET  ' ),  { TelNet                        }
    ( port:  25; svc: 'SMTP    ' ),  { Simple Mail Transfer Protocol }
    ( port:  37; svc: 'TIME    ' ),
    ( port:  42; svc: 'NAME    ' ),  { Host Name Server              }
    ( port:  43; svc: 'WHOIS   ' ),  { WHO IS service                }
    ( port:  53; svc: 'DNS     ' ),  { Domain Name Service           }
    ( port:  66; svc: 'SQL*NET ' ),  { Oracle SQL*NET                }
    ( port:  67; svc: 'BOOTPS  ' ),  { BOOTP Server                  }
    ( port:  68; svc: 'BOOTPC  ' ),  { BOOTP Client                  }
    ( port:  69; svc: 'TFTP    ' ),  { Trivial FTP                   }
    ( port:  70; svc: 'GOPHER  ' ),  { Gopher                        }
    ( port:  79; svc: 'FINGER  ' ),  { Finger                        }
    ( port:  80; svc: 'HTTP    ' ),  { HTTP                          }
    ( port:  88; svc: 'KERBEROS' ),  { Kerberos                      }
    ( port:  92; svc: 'NPP     ' ),  { Network Printing Protocol     }
    ( port:  93; svc: 'DCP     ' ),  { Device Control Protocol       }
    ( port: 109; svc: 'POP2    ' ),  { Post Office Protocol Version 2}
    ( port: 110; svc: 'POP3    ' ),  { Post Office Protocol Version 3}
    ( port: 111; svc: 'SUNRPC  ' ),  { SUN Remote Procedure Call     }
    ( port: 119; svc: 'NNTP    ' ),  { Network News Transfer Protocol}
    ( port: 123; svc: 'NTP     ' ),  { Network Time protocol         }
    ( port: 135; svc: 'LOCSVC  ' ),  { Location Service              }
    ( port: 137; svc: 'NTBNAME ' ),  { NETBIOS Name service          }
    ( port: 138; svc: 'NTBDGRAM' ),  { NETBIOS Datagram Service      }
    ( port: 139; svc: 'NTBSESSN' ),  { NETBIOS Session Service       }
    ( port: 161; svc: 'SNMP    ' ),  { Simple Netw. Mgmt Protocol    }
    ( port: 162; svc: 'SNMPTRAP' ),  { SNMP TRAP                     }
    ( port: 220; svc: 'IMAP3   ' ),  { Interactive Mail Access Protocol v3 }
    ( port: 443; svc: 'HTTPS   ' ),  { HTTPS                         }
    ( port: 445; svc: 'MS-DS   ' ),  { Microsoft-DS                  }
    ( port:1433; svc: 'MSSQL   ' ),  { MSSQL                         }
    ( port:3306; svc: 'MYSQL   ' ),  { MySQL                         }
    ( port:5900; svc: 'VNC     ' )   { VNC - similar to PC Anywhere  }
  );

function GetIPProtoName(protocol: Byte): String;
VAR i: Integer;
begin
  Result := IntToStr(protocol);
  for i := 1 To sizeof(IPPROTO) div sizeof(TIPProto) do
    if protocol = IPPROTO[i].itype then
      Result := IPPROTO[i].iName;
end;

function GetServiceName(s_port, d_port: Integer): String;
VAR i: Integer;
begin
  Result := '';
  for i := 1 to sizeof(WellKnownSvcs) div sizeof(TWellKnownSvc) do
    if (s_port = WellKnownSvcs[i].port) OR (d_port = WellKnownSvcs[i].port) then
    begin
      Result := WellKnownSvcs[i].svc;
      break;
    end;
end;

function  GetICMPType(x: Byte): String;
begin
  Result := 'UNKNOWN';
  case x of
     0: Result := 'ECHO_R'; // Echo Reply
     3: Result := 'DSTUNR'; // Destination Unreachable
     4: Result := 'SRC_Q';  // Source Quench
     5: Result := 'REDIR';  // Redirect
     8: Result := 'ECHO';   // Echo
    11: Result := 'TTLX';   // Time Exceeded
    12: Result := 'BADPAR'; // Parameter Problem
    13: Result := 'TIME';   // Timestamp
    14: Result := 'TIME_R'; // Timestamp Reply
    15: Result := 'INFO';   // Information Request
    16: Result := 'INFO_R'; // Information Reply
  end
end;

function Win2KDetected: Boolean;
VAR IsNT: Boolean;
    ver: DWORD;
begin
  ver := GetVersion();

  IsNT  := ver < $80000000;
  Result := IsNT AND ((ver AND $FF) >= 5)
end;

function InitWinsock(hi_ver, lo_ver: Byte): String;
VAR versionRequested: Word;
    errorStatus: Integer;
    wd: TWSADATA;
begin
  Result := '';

  versionRequested := MAKEWORD(lo_ver, hi_ver);

  errorStatus := WSAStartup(versionRequested, wd);
  if (errorStatus <> 0) then
  begin
    Result := 'Winsock initialization error '+ IntToStr(errorStatus);
    Exit;
  end;

  if (LOBYTE(wd.wVersion) <> LOBYTE(versionRequested)) OR
     (HIBYTE(wd.wVersion) <> HIBYTE(versionRequested)) then
  begin
    Result := Format('Winsock version mismatch (required: %d.%d, found: %d.%d)',
                     [HIBYTE(versionRequested),
                     LOBYTE(versionRequested),
                     HIBYTE(wd.wVersion),
                     LOBYTE(wd.wVersion)]);
    Exit;
  end;
end;

procedure CleanupWinsock(VAR socket: TSocket);
begin
  if (socket <> 0) AND (socket <> INVALID_SOCKET) then
    CloseSocket(socket);
  socket := INVALID_SOCKET;
  WSACleanup()
end;

procedure CleanupWinsock;
begin
  WSACleanup()
end;

procedure EnumInterfaces(cb: TEnumInterfacesEvent; iff_types: Integer);
type
  TSockAddrGen = packed record
    AddressIn: sockaddr_in;
    { This record must be big enough
      to hold struct sockaddr_in6,
      which is 24 bytes long... }
    dummy: array[0..7] of char;
  end;

  TInterface_Info = packed record { see Q181520 }
    iiFlags: u_long;         // Interface flags
    iiAddress,               // Interface address
    iiBroadcastAddress,      // Broadcast address
    iiNetmask: TSockAddrGen; // Network mask
  end;

CONST SIO_GET_INTERFACE_LIST = $4004747F;
VAR
  InterfaceList: array[0..$20] of TInterface_Info;
  NumInterfaces: Integer;
  BytesReturned: DWORD;
  AddrIn: TSockAddrIn;
  pAddr: PChar;
  flags: u_long;
  s: TSocket;
  i: Integer;
begin
  if InitWinsock(2,2) <> '' then Exit;

  s := Socket(AF_INET, SOCK_STREAM, IPPROTO_IP); { tcp socket }
  if (s <> INVALID_SOCKET) then
  begin
    try
      if WSAIoctl(s,
                  SIO_GET_INTERFACE_LIST,
                  Nil,
                  0,
                  @InterfaceList,
                  sizeof(InterfaceList),
                  @BytesReturned,
                  Nil,
                  Nil) <> SOCKET_ERROR then
      begin
        NumInterfaces := BytesReturned div SizeOf(TInterface_Info);

        for i := 0 to NumInterfaces - 1 do
        begin
          AddrIn := InterfaceList[i].iiAddress.AddressIn;
          pAddr  := inet_ntoa(AddrIn.sin_addr);

          flags := InterfaceList[i].iiFlags;

          if (flags AND iff_types) = flags then
            if Assigned(cb) then  cb(pAddr, flags)
        end;
      end;
    except
      { do nothing }
    end;
  end;

  CleanupWinsock(s);
end;

function ResolveHostAddress(name: String): u_long;
//
// This function can handle host name,
// or IP address in dotted notation
//
// The return value is in network byte order
// (bytes ordered from left to right).
//
VAR hep: PHostEnt;
    addr: u_long;
begin
  addr := inet_addr(PChar(name));

  if (addr = u_long(-1)) then
  begin
    hep := gethostbyname(PChar(name));
    if (hep <> Nil) then
    begin
      with TInAddr(addr), hep^ do
      begin
        S_un_b.s_b1 := h_addr^[0];
        S_un_b.s_b2 := h_addr^[1];
        S_un_b.s_b3 := h_addr^[2];
        S_un_b.s_b4 := h_addr^[3];
      end
    end
  end;

  Result := addr;
end;


(* IP header record contains "ihl_ver" which is used
   to store two parameters: IP header length and IP version.
   IP version is stored in the high nibble of "ihl_ver"
   (it occupies 4 bits). IP header length is stored in the
   low nibble of "ihl_ver" (also uses 4 bits).
   IP header length is expressed in 32 bit words
   (4 8-bit bytes), therefore we divide or multiply
   the low nibble by 4 depending on the function.
*)

function GetIHlen(ih: THdrIP): Word;  // IP header length
begin
  // multiply the low nibble by 4
  // and return the length in bytes
  Result := (ih.ihl_ver AND $0F) SHL 2
end;

procedure SetIHlen(VAR ih: THdrIP; value: Byte);
begin
  // divide the value by 4 and store it in low nibble
  value := value SHR 2;
  ih.ihl_ver := value OR (ih.ihl_ver AND $F0)
end;

function GetIHver(ih: THdrIP): Byte;  // IP version
begin
  // get the high nibble
  Result := ih.ihl_ver SHR 4
end;

procedure SetIHver(VAR ih: THdrIP; value: Byte);
begin
  // set the high nibble
  ih.ihl_ver := (value SHL 4) OR (ih.ihl_ver AND $0F)
end;

(* TCP header record contains "flags" which is used
   to store several parameters:
     Least Significant Bit
       res1:4 - reserved, must be 0
       doff:4 - TCP header length divided by 4
       fin:1  - FIN
       syn:1  - SYN
       rst:1  - Reset
       psh:1  - Push
       ack:1  - ACK
       urg:1  - Urgent
       res2:2 - reserved, must be 0
     MSB
*)

CONST flagMask: Array[ftFIN..ftURG] of Integer = ($100, $200, $400, $800, $1000, $2000);

function GetTHflag(th: THdrTCP; flag: TTcpFlagType): Boolean;
begin
  Result := Boolean(th.flags AND flagMask[flag])
end;

procedure SetTHflag(VAR th: THdrTCP; flag: TTcpFlagType; on: Boolean);
begin
  if on then
    th.flags := th.flags OR flagMask[flag]
  else
    th.flags := th.flags AND NOT flagMask[flag]
end;

function GetTHdoff(th: THdrTCP): Word;
begin
  // doff (data offset) stored in 32 bit words,
  // multiply the value by 4 to get byte offset
  Result := (($00F0 AND th.flags) SHR 4) SHL 2;
end;

procedure SetTHdoff(VAR th: THdrTCP; value: Byte);
VAR x: Integer;
begin
  x := value SHR 2; // divide the value by 4
  th.flags := (x SHL 4) OR (th.flags AND $FF0F)
end;

function CalculateChecksum(addr: PWord; len: Integer): Word;
// The checksum algorithm is described in the RFCs 791,793
//
VAR sum: DWORD;
begin
  Result := 0;
  sum := 0;

  while (len > 1) do
  begin
    Inc(sum, addr^);
    Inc(addr);
    Dec(len, 2);
  end;

  // If a segment contains an odd number of header and text
  // octets to be checksummed, the last octet is padded on
  // the right with zeros to form a 16 bit word for checksum
  // purposes.  The pad is not transmitted as part of the segment.
  //
  if (len = 1) then
  begin
    PByte(@Result)^ := PByte(addr)^;
    Inc(sum, Result);
  end;

  sum := (sum SHR 16) + (sum AND $FFFF);{ add hi 16 to low 16 }
  Inc(sum, sum SHR 16);                 { add carry }
  sum := NOT sum;                       { take the one's complement of sum }
  Result := Word(sum);                  { truncate to 16 bits }
end;

end.

