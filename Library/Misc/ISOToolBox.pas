//
//  TISOLib - function toolbox
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ISOToolBox.pas,v 1.6 2004/07/15 21:09:16 nalilord Exp $
//

unit ISOToolBox;

interface

uses
  Windows,   // for TSIDIdentifierAuthority
  SysUtils,  // for IntToStr()
  AnsiStrings,
  Dialogs,
  ISOStructs;

function IntToMB(const ASize: Int64): string;
function VolumeDateTimeToStr(const VDT: TVolumeDateTime): string;
function SwapWord(AValue: Word): Word;
function SwapDWord(AValue: LongWord): LongWord;
function BuildBothEndianWord(AValue: Word): TBothEndianWord;
function BuildBothEndianDWord(AValue: LongWord): TBothEndianDWord;
function BuildVolumeDateTime(const ADateTime: TDateTime; AGMTOffset: Byte): TVolumeDateTime;
function RetrieveFileSize(const AFileName: string): LongWord;
function IsAdministrator: Boolean;
function GetOsVersion: Integer;
function Endian(const Source; var Destination; Count: Integer): Boolean;
function EndianToIntelBytes(const AValue: array of Byte; Count: Byte):Integer;
function GetLBA(Byte1, Byte2, Byte3, Byte4: Byte): LongWord;
function HMSFtoLBA(AHour, AMinute, ASecond, AFrame: Byte): LongWord;
function HiWord(Lx: LongWord): Word;
function LoWord(Lx: LongWord): Word;
function HiByte(Lx: Word): Byte;
function LoByte(Lx: Word): Byte;
function IsBitSet(Value: LongWord; Bit: Byte): Boolean;
function BitOn(Value: LongWord; Bit: Byte): LongWord;
function BitOff(Value: LongWord; Bit: Byte): LongWord;
function BitToggle(Value: LongWord; Bit: Byte): LongWord;
function ByteToBin(Value: Byte): string;

const
  OS_UNKNOWN = -1;
  OS_WIN95   =  0;
  OS_WIN98   =  1;
  OS_WINNT35 =  2;
  OS_WINNT4  =  3;
  OS_WIN2K   =  4;
  OS_WINXP   =  5;

implementation

const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = ( Value: (0, 0, 0, 0, 0, 5) );
  SECURITY_BUILTIN_DOMAIN_RID                    = $00000020;
  DOMAIN_ALIAS_RID_ADMINS                        = $00000220;

function IntToMB(const ASize: Int64): string;
begin
  Result := IntToStr( ASize div 1024 div 1024 );
end;

function VolumeDateTimeToStr(const VDT: TVolumeDateTime): string;
begin
  Result := string(VDT.Day) + '.' + string(VDT.Month) + '.'
          + string(VDT.Year) + ' ' + string(VDT.Hour) + ':'
          + string(VDT.Minute) + ':' + string(VDT.Second) + '.'
          + string(VDT.MSeconds) + ' ' + IntToStr(VDT.GMTOffset * 15) + ' min from GMT';
end;

function SwapWord(AValue : Word): Word;
begin
  Result := ( (AValue shl 8) and $FF00 ) or ( (AValue shr 8) and $00FF );
end;

function SwapDWord(AValue: LongWord): LongWord;
begin
  Result := ( (AValue shl 24) and $FF000000 )
         or ( (AValue shl  8) and $00FF0000 )
         or ( (AValue shr  8) and $0000FF00 )
         or ( (AValue shr 24) and $000000FF );
end;

function BuildBothEndianWord(AValue: Word): TBothEndianWord;
begin
  Result.LittleEndian := AValue;
  Result.BigEndian    := SwapWord(AValue);
end;

function BuildBothEndianDWord(AValue: LongWord): TBothEndianDWord;
begin
  Result.LittleEndian := AValue;
  Result.BigEndian    := SwapDWord(AValue);
end;

function BuildVolumeDateTime(const ADateTime: TDateTime; AGMTOffset: Byte): TVolumeDateTime;
var
  Hour, Min, Sec, MSec,
  Year, Month, Day : Word;
begin
  DecodeDate(ADateTime, Year, Month, Day);
  DecodeTime(ADateTime, Hour, Min, Sec, MSec);
  AnsiStrings.StrPCopy(@Result.Year,     AnsiString(Format('%.*d', [Length(Result.Year),     Year])));
  AnsiStrings.StrPCopy(@Result.Month,    AnsiString(Format('%.*d', [Length(Result.Month),    Month])));
  AnsiStrings.StrPCopy(@Result.Day,      AnsiString(Format('%.*d', [Length(Result.Day),      Day])));
  AnsiStrings.StrPCopy(@Result.Hour,     AnsiString(Format('%.*d', [Length(Result.Hour),     Hour])));
  AnsiStrings.StrPCopy(@Result.Minute,   AnsiString(Format('%.*d', [Length(Result.Minute),   Min])));
  AnsiStrings.StrPCopy(@Result.Second,   AnsiString(Format('%.*d', [Length(Result.Second),   Sec])));
  AnsiStrings.StrPCopy(@Result.MSeconds, AnsiString(Format('%.*d', [Length(Result.MSeconds), MSec])));
  Result.GMTOffset := AGMTOffset;
end;

function RetrieveFileSize(const AFileName: string): LongWord;
var
  SR : TSearchRec;
begin
  Result := 0;
  if ( FileExists(AFileName) ) and ( FindFirst(AFileName, faAnyFile, SR) = 0 ) then
    if ( (SR.Attr and faDirectory) = 0 ) and ( (SR.Attr and faVolumeID) = 0 ) then
      Result := SR.Size;
end;

// got it from: http://community.borland.com/article/0,1410,26752,00.html
function IsAdministrator: Boolean;
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  x: Integer;
  bSuccess: BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
    bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, psidAdministrators);
      {$R-}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
      {$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;

function GetOsVersion: Integer;
var
  OS: OSVERSIONINFO;
begin
  ZeroMemory(@OS, SizeOf(OS));
  OS.dwOSVersionInfoSize := SizeOf(OS);
  GetVersionEx(OS);

  if ( OS.dwPlatformId = VER_PLATFORM_WIN32_NT ) then
  begin
    if ( OS.dwMajorVersion = 3 ) and ( OS.dwMinorVersion >= 51 ) then
    begin
      Result := OS_WINNT35;
      Exit;
    end
    else if ( OS.dwMajorVersion = 4 ) then
    begin
      Result := OS_WINNT4;
      Exit;
    end
    else if ( OS.dwMajorVersion = 5 ) and ( OS.dwMinorVersion = 0 ) then
    begin
      Result := OS_WIN2K;
      Exit;
    end
    else
    begin
      Result := OS_WINXP;
      Exit;
    end;
  end
  else if ( OS.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS ) then
  begin
    if ( OS.dwMinorVersion = 0 ) then
    begin
      Result := OS_WIN95;
      Exit;
    end
    else
    begin
      Result := OS_WIN98;
      Exit;
    end;
  end;

  Result := OS_UNKNOWN;
end;

function Endian(const Source; var Destination; Count: Integer): Boolean;
var
  PSource,PDestination:PChar;
  I:Integer;
begin
  Result := False;
  PSource := @Source;
  PDestination := PChar(@Destination)+Count;
  for i := 0 to Count-1 do
  begin
    Dec(PDestination);
    pDestination^ := PSource^;
    Inc(PSource);
    Result := True;
  end;
end;

function EndianToIntelBytes(const AValue: array of Byte; Count: Byte): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count-1 do
    Result := (AValue[I] shl ((Count-(I+1))*8) or Result);
end;

function GetLBA(Byte1, Byte2, Byte3, Byte4: Byte): LongWord;
begin
  Result := ( Byte1 shl 24 ) or ( Byte2 shl 16 ) or (Byte3 shl 8 ) or Byte4;
end;

function HMSFtoLBA(AHour, AMinute, ASecond, AFrame: Byte): LongWord;
begin
  Result := (AHour * 60 * 60 * 75) + (AMinute * 60 * 75) + (ASecond * 75) + AFrame;
end;

function HiWord(Lx: LongWord): Word;
begin
  Result := (Lx shr 16) and $FFFF;
end;

function LoWord(Lx: LongWord): Word;
begin
  Result := Lx and $FFFF;
end;

function HiByte(Lx: Word): Byte;
begin
  Result := (Lx shr 8) and $FF;
end;

function LoByte(Lx: Word): Byte;
begin
  Result := Lx and $FF;
end;

function IsBitSet(Value: LongWord; Bit: Byte): Boolean;
begin
  Result := ( Value and (1 shl Bit) ) <> 0;
end;

function BitOn(Value: LongWord; Bit: Byte): LongWord;
begin
  Result := Value or (1 shl Bit);
end;

function BitOff(Value: LongWord; Bit: Byte): LongWord;
begin
  Result := Value and ((1 shl Bit) xor $FFFFFFFF);
end;

function bitToggle(Value: LongWord; Bit: Byte): LongWord;
begin
  Result := Value xor ( 1 shl Bit );
end;

function ByteToBin(Value: Byte): string;
var
  I: Integer;
begin
  Result := StringOfChar('0', 8);

  for I := 0 to 7 do
  begin
    if ( Value mod 2 ) = 1 then
      Result[8 - i] := '1';

    Value := Value div 2;
  end;
end;

end.

//  Log List
//
// $Log: ISOToolBox.pas,v $
// Revision 1.6  2004/07/15 21:09:16  nalilord
// Fixed some bugs an structures in DeviceIO
// Fixed ReadTOC
// New function GetConfigurationData
// Now can get Device Capabilities but not yet finished
// Other workarounds and fixes
//
// Revision 1.5  2004/06/24 02:07:05  nalilord
// ISOSCSIStructs
// added - record TModeParametersHeader
// changed - record TMode10Capabilities - mode header was missing
//
// ISODiscLib
// working - function ModeSense10Capabilities
//
// ISOToolBox
// crtical - bugfix function SwapWord - Miscalculation in function
// changed - function SwapDWord - Calculation in function
//
// added ToDo list
//
// Revision 1.4  2004/06/20 16:10:05  nalilord
// range check error in LoByte function fixed
//
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//

