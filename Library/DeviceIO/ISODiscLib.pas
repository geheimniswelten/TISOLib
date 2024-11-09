(******************************************************************************)
(*                                                                            *)
(*  TISOLib - ISODiscLib.pas                                                  *)
(*  Version: 1.06                                                             *)
(*  Date: 5/31/2004                                                           *)
(*  Author: Daniel Mann                                                       *)
(*  Internet: http://isolib.xenome.info                                       *)
(*                                                                            *)
(******************************************************************************)

//
// $Id: ISODiscLib.pas,v 1.5 2004/07/15 21:09:16 nalilord Exp $
//

unit ISODiscLib;

interface

uses
  Windows,
  Forms,     // for Application
  Dialogs,   // for ShowMessage
  Classes,   // for TMemoryStream, needed for some tests
  SysUtils,  // for Trim
  AnsiStrings,
  ISOSCSIConsts,
  ISOSCSIStructs,
  ISOToolBox,
  ISOASPILoader;

type
  TProgressEvent = procedure(Position, Size: LongWord) of object;

type
  TISODiscLib = class
  private
    FOnProgress : TProgressEvent;
    fUseSPTI    : Boolean;
    fUseASPI    : Boolean;
    FDrives     : TDriveList;

    function InitSPTI: Boolean;
    function InitASPI: Boolean;
    function OpenPort(const APort: string): THandle;
    function ClosePort(AHandle: THandle): Boolean;
  public
    constructor Create; virtual;
    destructor  Destroy; override;

    function ScanDevices: Boolean;
    function GetStatus(AHandle: THandle; var MechanismStatus: TMechanismStatus):Boolean;
    function UnitReady(AHandle: THandle): Boolean;
    function ReadDiscInformation(AHandle: THandle; var DiscInformation: TDiscInformation): Boolean;
    function GetDiscType(AHandle: THandle): Integer;
    //TODO 5 -oNaliLord:test and finish the GetConfigurationData function
    function GetConfigurationData(AHandle: THandle; StartingFeature: Word; UnitReturned: TUnitReturned; Buffer: Pointer; BufferSize: Word):Boolean;
    function GetFormatCapacity(AHandle: THandle; var FormatCapacity: TFormatCapacity): Boolean;
    function ReadTOC(AHandle: THandle): Boolean;
    function ReadTrackInformation(AHandle: THandle; ATrack: Byte; var TrackInformation: TTrackInformation): Boolean;
    function OpenDrive(ADrive: Char): THandle;
    function CloseDrive(AHandle: THandle): Boolean;
    function ReadDVDLayerDescriptor(AHandle: THandle; var DVDLayerDescriptor: TDVDLayerDescriptor): Boolean;
    //TODO 4 -oNaliLord:finish ModeSense10Capabilities function (return set of capabilities)
    function ModeSense10Capabilities(AHandle: THandle; var Mode10Capabilities: TMode10Capabilities): Boolean;

    procedure Test(AHandle: THandle);

    property  OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

constructor TISODiscLib.Create;
begin
  inherited;
  fUseASPI := InitASPI;
  fUseSPTI := InitSPTI;
end;

destructor TISODiscLib.Destroy;
begin
  if ( fUseASPI ) then
    UnInitializeASPI;
  inherited;
end;

function TISODiscLib.InitSPTI: Boolean;
begin
  if ( GetOsVersion in [OS_WIN2K, OS_WINXP, OS_WINNT4] ) then
    Result := IsAdministrator
  else
    Result := False;
end;

function TISODiscLib.InitASPI: Boolean;
var
  SupportInfo: LongWord;
begin
  Result := False;

  if WNASPI32_Loaded then
  begin
    SupportInfo := GetASPI32SupportInfo;

    Result := ( HiByte( LoWord(SupportInfo) ) =  SS_COMP )
          and ( HiByte( LoWord(SupportInfo) ) <> SS_NO_ADAPTERS );
  end;
end;

function TISODiscLib.OpenPort(const APort: string): THandle;
begin
  Result := INVALID_HANDLE_VALUE;

  if fUseSPTI then
  begin
    Result := CreateFile( PChar('\\.\'+ APort +':'),
                          GENERIC_READ or GENERIC_WRITE,
                          FILE_SHARE_READ or FILE_SHARE_WRITE,
                          nil,
                          OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL,
                          0);
  end;
end;

function TISODiscLib.ClosePort(AHandle: THandle): Boolean;
begin
  Result := CloseHandle(AHandle);
end;

function TISODiscLib.OpenDrive(ADrive: Char): THandle;
begin
  Result := INVALID_HANDLE_VALUE;

  if fUseSPTI then
    if GetDriveType(PChar(string(ADrive) + ':')) = DRIVE_CDROM then
      Result := OpenPort(ADrive);
end;

function TISODiscLib.CloseDrive(AHandle: THandle): Boolean;
begin
  Result := ClosePort(AHandle);
end;

function TISODiscLib.GetStatus(AHandle: THandle; var MechanismStatus: TMechanismStatus): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Returned : LongWord;
  Size     : Cardinal;
begin
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 11;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(TMechanismStatus);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @MechanismStatus;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $BD;
  SPTDW.Spt.Cdb[8] := HiByte(SizeOf(TMechanismStatus));
  SPTDW.Spt.Cdb[9] := LoByte(SizeOf(TMechanismStatus));

  Result := DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil);
end;

function TISODiscLib.UnitReady(AHandle: THandle): Boolean;
var
  SPTDW           : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Returned        : LongWord;
  Size            : Cardinal;
  Sense           : TSenseData;
  MechanismStatus : TMechanismStatus;
begin
  Result := False;
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 6;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := 0;
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := nil;
  SPTDW.Spt.SenseInfoOffset    := 48;

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    CopyMemory(@Sense, @SPTDW.SenseBuf, 32);

    if Sense.ErrorCode = $00 then
      Result := True  // device is maby not ready, or medium missing?
    else
    begin
      ZeroMemory(@MechanismStatus, SizeOf(MechanismStatus));
      if GetStatus(AHandle, MechanismStatus) then
      begin
        // device status, handle advanced options: tray open, busy...
      end else
      begin
        // can't get device status, handle error here
      end;
    end;
  end;
end;

function TISODiscLib.ScanDevices: Boolean;
var
  SPTDW           : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  ScsiInquiryData : SCSI_INQUIRY_DATA_RESULT;
  ScsiAddress     : SCSI_ADDRESS;
  ScsiPort,
  Size, Num, Count,
  Returned        : LongWord;
begin
  Result  := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 6;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(ScsiInquiryData);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @ScsiInquiryData;
  SPTDW.Spt.SenseInfoOffset    := 48;
  SPTDW.Spt.Cdb[0]             := $12;
  SPTDW.Spt.Cdb[4]             := SizeOf(ScsiInquiryData);

  Num     := 0;
  Count   := 0;
  FDrives := nil;
  repeat
    if GetDriveType(PChar(Char(Num + Ord('a')) + ':\')) = DRIVE_CDROM then
    begin
      ScsiPort := OpenPort(Char(Num + Ord('a')));
      if ( ScsiPort <> INVALID_HANDLE_VALUE ) then
      begin
        ZeroMemory(@ScsiInquiryData, SizeOf(ScsiInquiryData));

        if DeviceIoControl(ScsiPort, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
        begin
          ZeroMemory(@ScsiAddress, SizeOf(ScsiAddress));
          ScsiAddress.Length := SizeOf(SCSI_ADDRESS);

          if DeviceIoControl(ScsiPort, IOCTL_SCSI_GET_ADDRESS, nil, 0, @ScsiAddress, SizeOf(SCSI_ADDRESS), Returned, nil) then
          begin
            SetLength(FDrives, Count + 1);
            FDrives[Count].Letter    := Char(Num + Ord('a'));
            FDrives[Count].HaId      := ScsiAddress.PathId;
            FDrives[Count].TargetId  := ScsiAddress.TargetId;
            FDrives[Count].LunID     := ScsiAddress.Lun;
            FDrives[Count].VendorId  := AnsiStrings.Trim(ScsiInquiryData.VendorId);
            FDrives[Count].ProductId := AnsiStrings.Trim(ScsiInquiryData.ProductId);
            FDrives[Count].Reversion := AnsiStrings.Trim(ScsiInquiryData.Reversion);

            Inc(Count);
            Result := True;
          end;
        end;
      end;
      ClosePort(ScsiPort);
    end;
    Inc(Num);
  until Num = 27;
end;

function TISODiscLib.ReadDiscInformation(AHandle: THandle; var DiscInformation: TDiscInformation): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Returned,
  Size     : LongWord;
begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  ZeroMemory(@DiscInformation, SizeOf(TDiscInformation));

  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(DiscInformation);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @DiscInformation;
  SPTDW.Spt.SenseInfoOffset    := 48;
  SPTDW.Spt.Cdb[0]             := $51;
  SPTDW.Spt.Cdb[7]             := HiByte(SizeOf(DiscInformation));
  SPTDW.Spt.Cdb[8]             := LoByte(SizeOf(DiscInformation));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    DiscInformation.DiscInformationLength := SwapWord(DiscInformation.DiscInformationLength);
    Result := True;
  end;
end;

function TISODiscLib.GetDiscType(AHandle: THandle): Integer;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
  DeviceConfigHeader : TDeviceConfigHeader;
begin
  Result := -1;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(DeviceConfigHeader);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @DeviceConfigHeader;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $46;
  SPTDW.Spt.Cdb[1] := $02;
  SPTDW.Spt.Cdb[3] := $00;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(DeviceConfigHeader));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(DeviceConfigHeader));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    case SwapWord(DeviceConfigHeader.CurrentProfile) of
      $0000 : Result :=  0;
      $0001 : Result :=  1;
      $0002 : Result :=  2;
      $0003 : Result :=  3;
      $0004 : Result :=  4;
      $0005 : Result :=  5;
      $0008 : Result :=  6;
      $0009 : Result :=  7;
      $000A : Result :=  8;
      $0010 : Result :=  9;
      $0011 : Result := 10;
      $0012 : Result := 11;
      $0013 : Result := 12;
      $0014 : Result := 13;
      $001A : Result := 14;
      $001B : Result := 15;
      $0020 : Result := 16;
      $0021 : Result := 17;
      $0022 : Result := 18;
      $FFFF : Result := 19;
      else    Result := -1;
    end;
  end;
end;

function TISODiscLib.GetConfigurationData(AHandle: THandle; StartingFeature: Word; UnitReturned: TUnitReturned; Buffer: Pointer; BufferSize: Word): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size     : Integer;
  Returned : LongWord;
begin
  ZeroMemory(Buffer, BufferSize);
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(BufferSize);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := Buffer;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $46;
  SPTDW.Spt.Cdb[1] := Byte(UnitReturned);
  SPTDW.Spt.Cdb[2] := HiByte(StartingFeature);
  SPTDW.Spt.Cdb[3] := LoByte(StartingFeature);
  SPTDW.Spt.Cdb[7] := HiByte(BufferSize);
  SPTDW.Spt.Cdb[8] := LoByte(BufferSize);

  Result := DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil);
end;

function TISODiscLib.GetFormatCapacity(AHandle: THandle; var FormatCapacity: TFormatCapacity): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size, I  : Integer;
  Returned : LongWord;
begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(TFormatCapacity);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @FormatCapacity;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $23;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TFormatCapacity));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TFormatCapacity));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    for I := 0 to 32 do
    begin
      FormatCapacity.FormattableCD[I].NumberOfBlocks := SwapDWord(FormatCapacity.FormattableCD[I].NumberOfBlocks);
      FormatCapacity.FormattableCD[I].FormatType     := FormatCapacity.FormattableCD[I].FormatType shr 2;
    end;
    FormatCapacity.CapacityDescriptor.NumberOfBlocks := SwapDWord(FormatCapacity.CapacityDescriptor.NumberOfBlocks);

    Result := True;
  end;
end;

function TISODiscLib.ReadTOC(AHandle: THandle): Boolean;
var
  SPTDW          : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size, Returned : LongWord;
  TocData0000    : TTOCData0000;
  TocData0001    : TTOCData0001;
  TocData0100    : TTOCData0100;
begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  ZeroMemory(@TocData0000, SizeOf(TTOCData0000));
  ZeroMemory(@TocData0001, SizeOf(TTOCData0001));
  ZeroMemory(@TocData0100, SizeOf(TTOCData0100));

  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.SenseInfoOffset    := 48;
  SPTDW.Spt.Cdb[0]             := $43; // Read TOC command

  // == TocData 0000 ===========================================================

  SPTDW.Spt.DataTransferLength := SizeOf(TocData0000);
  SPTDW.Spt.DataBuffer         := @TocData0000;

  SPTDW.Spt.Cdb[1] := $00;
  SPTDW.Spt.Cdb[2] := $00;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TocData0000));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TocData0000));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    ShowMessage('Sturcture DataLength: '+IntToStr(TocData0000.DataLength) + #10
              + 'TOC 0000b' + #10
              + '===========================================================' + #10
              + 'FirstTrackNumber: ' + IntToStr(TocData0000.FirstTrackNumber) + #10
              + 'LastTrackNumber: ' + IntToStr(TocData0000.LastTrackNumber) + #10
              + 'ADR_CONTROL: ' + IntToStr(TocData0000.ADR_CONTROL) + #10
              + 'TrackNumber: ' + IntToStr(TocData0000.TrackNumber) + #10
              + 'TrackStartAddress: ' + IntToStr(TocData0000.TrackStartAddress));
  end;

  // == TocData 0001 ===========================================================

  SPTDW.Spt.DataTransferLength := SizeOf(TocData0001);
  SPTDW.Spt.DataBuffer         := @TocData0001;

  SPTDW.Spt.Cdb[1] := $00;
  SPTDW.Spt.Cdb[2] := $01;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TocData0001));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TocData0001));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    ShowMessage('Sturcture DataLength: '+IntToStr(TocData0001.DataLength) + #10
              + 'TOC 0001b' + #10
              + '===========================================================' + #10
              + 'FirstTrackNumber: ' + IntToStr(TocData0001.FirstTrackNumber) + #10
              + 'LastTrackNumber: ' + IntToStr(TocData0001.LastTrackNumber) + #10
              + 'ADR_CONTROL: ' + IntToStr(TocData0001.ADR_CONTROL) + #10
              + 'FirstTrackNumberInLastCompleteSession: ' + IntToStr(TocData0001.FirstTrackNumberInLastCompleteSession) + #10
              + 'StartAddressOfFirstTrackInLastSession: ' + IntToStr(TocData0001.StartAddressOfFirstTrackInLastSession));
  end;

  // == TocData 0100 ===========================================================

  SPTDW.Spt.DataTransferLength := SizeOf(TocData0100);
  SPTDW.Spt.DataBuffer         := @TocData0100;

  SPTDW.Spt.Cdb[1] := $02;
  SPTDW.Spt.Cdb[2] := $04;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TocData0100));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TocData0100));

  if DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, nil) Then
  begin
    ShowMessage('Sturcture DataLength: ' + IntToStr(TocData0100.DataLength) + #10
              + 'TOC 0100b' + #10
              + '===========================================================' + #10
              + 'ATIPStartTimeOfLeadIn_Min: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadIn_Min) + #10
              + 'ATIPStartTimeOfLeadIn_Sec: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadIn_Sec) + #10
              + 'ATIPStartTimeOfLeadIn_Frame: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadIn_Frame) + #10
              + 'ATIPStartTimeOfLeadOut_Min: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadOut_Min) + #10
              + 'ATIPStartTimeOfLeadOut_Sec: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadOut_Sec) + #10
              + 'ATIPStartTimeOfLeadOut_Frame: ' + IntToStr(TocData0100.ATIPStartTimeOfLeadOut_Frame));
  end;
end;

function TISODiscLib.ReadTrackInformation(AHandle: THandle; ATrack: Byte; var TrackInformation: TTrackInformation): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
begin
  Result := False;
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(TTrackInformation);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @TrackInformation;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $52;
  SPTDW.Spt.Cdb[1] := $01;
  SPTDW.Spt.Cdb[2] := HiByte(HiWord(ATrack));
  SPTDW.Spt.Cdb[3] := LoByte(HiWord(ATrack));
  SPTDW.Spt.Cdb[4] := HiByte(LoWord(ATrack));
  SPTDW.Spt.Cdb[5] := LoByte(LoWord(ATrack));
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TTrackInformation));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TTrackInformation));

  if DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil) then
  begin
    with TrackInformation do
    begin
      Datalength          := SwapWord(DataLength);
      TrackSize           := SwapDWord(TrackSize);
      FreeBlocks          := SwapDWord(FreeBlocks);
      TrackStartAddress   := SwapDWord(TrackStartAddress);
      NextWritableAddress := SwapDWord(NextWritableAddress);
      FixedpacketSize     := SwapDWord(FixedpacketSize);
      LastRecordedAddress := SwapDWord(LastRecordedAddress);
    end;
    Result := True;
  end;
end;

function TISODiscLib.ReadDVDLayerDescriptor(AHandle: THandle; var DVDLayerDescriptor: TDVDLayerDescriptor): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
begin
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  ZeroMemory(@DVDLayerDescriptor, SizeOf(DVDLayerDescriptor));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(DVDLayerDescriptor);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @DVDLayerDescriptor;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $AD;
  SPTDW.Spt.Cdb[8] := HiByte(SizeOf(DVDLayerDescriptor));
  SPTDW.Spt.Cdb[9] := LoByte(SizeOf(DVDLayerDescriptor));
  DVDLayerDescriptor.DataLength := SizeOf(DVDLayerDescriptor);

  Result := DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil);
end;

function TISODiscLib.ModeSense10Capabilities(AHandle: THandle; var Mode10Capabilities: TMode10Capabilities): Boolean;
var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
begin
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  ZeroMemory(@Mode10Capabilities, SizeOf(Mode10Capabilities));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := SENSE_LEN;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(Mode10Capabilities);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @Mode10Capabilities;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $5A; // Mode Sense 10
  SPTDW.Spt.Cdb[2] := $2A or $80; // Page code, Default Values
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(Mode10Capabilities));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(Mode10Capabilities));

  Result := DeviceIoControl(AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, nil);
end;

//TODO 3 -oNaliLord:create ReadBuffer functions

(*
function TISODiscLib.Read10Buffer(Handle: Cardinal; LBA, Length: DWORD; var Buffer; const BufferSize: Cardinal): Boolean;
var
  SPTDW: SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size: Integer;
  Returned: DWORD;
begin
  // read disc here
  // not ready, still problems with discanalyzing to get the size...
end;

function TISODiscLib.Read12Buffer(Handle: Cardinal; LBA, Length: DWORD; var Buffer; const BufferSize: Cardinal): Boolean;
var
  SPTDW: SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size: Integer;
  Returned: DWORD;
begin
  // read disc here
  // not ready, still problems with discanalyzing to get the size...
end;

function TISODiscLib.ReadCDBuffer(Handle: Cardinal; LBA, Length: DWORD; var Buffer; const BufferSize: Cardinal): Boolean;
var
  SPTDW: SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size: Integer;
  Returned: DWORD;
begin
  // read disc here
  // not ready, still problems with discanalyzing to get the size...
end;
*)

//TODO 2 -oNaliLord:remove Test function and build single functions

procedure TISODiscLib.Test(AHandle: THandle);
var
  DiscType, Attempts        : Integer;
  DiscInformation           : TDiscInformation;
  FormatCapacity            : TFormatCapacity;
  TrackInformation          : TTrackInformation;
  DVDLayerDescriptor        : TDVDLayerDescriptor;
  Mode10Capabilities        : TMode10Capabilities;
  Value                     : Byte;
  BookType, DiscSize, MaximumRate, LinearDensity,
  TrackDensity, NoLayer, LayerType, Caps : string;
begin
  Attempts := 0;

  if ( AHandle <> INVALID_HANDLE_VALUE ) then
  begin
    repeat
      Inc(Attempts);
      Sleep(100);
      Application.ProcessMessages;
    until ( UnitReady(AHandle)) or (Attempts = 10);

    if Attempts < 10 then
    begin
      DiscType := GetDiscType(AHandle);
      if ( DiscType > -1 ) then
      begin
        ZeroMemory(@DiscInformation, SizeOf(DiscInformation));
        ZeroMemory(@FormatCapacity, SizeOf(FormatCapacity));
        ZeroMemory(@TrackInformation, SizeOf(TrackInformation));

        if ( DiscType <= 8 ) or ( DiscType >= 16 ) then
        begin
          if ReadDiscInformation(AHandle, DiscInformation) then
          begin
            if (DiscInformation.Status and 16) = 16 then
              ShowMessage('ReadDiscInformation ok'#10'======================================='#10
                        + 'FirstTrack: ' + IntToStr(DiscInformation.NumberOfFirstTrack) + #10
                        + 'DiscStatus: Eraseable' + #10
                        + 'Sessions: ' + IntToStr(DiscInformation.NumberOfSessionsLSB))
            else
              ShowMessage('ReadDiscInformation ok'#10'======================================='#10
                        + 'FirstTrack: '+IntToStr(DiscInformation.NumberOfFirstTrack) + #10
                        + 'Sessions: '+IntToStr(DiscInformation.NumberOfSessionsLSB));
          end;
          if GetFormatCapacity(AHandle,FormatCapacity) then
          begin
            ShowMessage('GetFormatCapacity ok'#10'======================================='#10
                      + 'NumberOfBlocks: ' + IntToStr(FormatCapacity.CapacityDescriptor.NumberOfBlocks) + #10
                      + 'BlockLength: ' + IntToStr(EndianToIntelBytes(FormatCapacity.CapacityDescriptor.BlockLength, 3)));
          end;

          ReadTOC(AHandle);

        (*
          if ReadTOC(AHandle, TOCDiscInformation) then
          begin
            ShowMessage('ReadTOC ok'#10'======================================='#10
                      + 'Start LBA: ' + IntToStr(TOCDiscInformation.StartLBA) + #10
                      + 'End LBA: ' + IntToStr(TOCDiscInformation.EndLBA));
          end;
          if DiscType >= 9 then
            Track := 1
          else
            Track := TOCDiscInformation.LastTrackNumber;

          if ReadTrackInformation(AHandle, Track, TrackInformation) then
          begin
            ShowMessage('ReadTrackInformation ok'#10'======================================='#10
                      + 'TrackSize: ' + IntToStr(TrackInformation.TrackSize) + #10
                      + 'LastRecordedAddress: ' + IntToStr(TrackInformation.LastRecordedAddress));
          end;
*)
        end else
        begin
          ReadDVDLayerDescriptor(AHandle, DVDLayerDescriptor);

          Value := (DVDLayerDescriptor.BookType_PartVersion shr 4) and $0F;
          case Value of
            $00: BookType := 'DVD-ROM';
            $01: BookType := 'DVD-RAM';
            $02: BookType := 'DVD-R';
            $03: BookType := 'DVD-RW';
            $09: BookType := 'DVD+RW';
            $0A: BookType := 'DVD+R';
            else BookType := 'Unknown';
          end;

          Value := (DVDLayerDescriptor.DiscSize_MaximumRate shr 4) and $0F;
          case Value of
            $00: DiscSize := '120mm';
            $01: DiscSize := '80mm';
            else DiscSize := 'Unknown';
          end;

          Value := (DVDLayerDescriptor.DiscSize_MaximumRate and $0F);
          case Value of
            $00: MaximumRate := '2.52 Mbps';
            $01: MaximumRate := '5.04 Mbps';
            $02: MaximumRate := '10.08 Mbps';
            $0F: MaximumRate := 'Not Specified';
            else MaximumRate := 'Unknown';
          end;

          Value := (DVDLayerDescriptor.LinearDensity_TrackDensity shr 4) and $0F;
          case Value of
            $00: LinearDensity := '0.267 um/bit';
            $01: LinearDensity := '0.293 um/bit';
            $02: LinearDensity := '0.409 to 0.435 um/bit';
            $04: LinearDensity := '0.280 to 0.291 um/bit';
            $08: LinearDensity := '0.353 um/bit';
            else LinearDensity := 'Reserved';
          end;

          Value := (DVDLayerDescriptor.LinearDensity_TrackDensity and $0F);
          case Value of
            $00: TrackDensity := '0.74 um/track';
            $01: TrackDensity := '0.80 um/track';
            $02: TrackDensity := '0.615 um/track';
            else TrackDensity := 'Reserved';
          end;

          NoLayer := IntToStr((DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType shr 5) and $03);

          Value := (DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType and $0F);
          case Value of
            $01: LayerType := 'Layer contains embossed data';
            $02: LayerType := 'Layer contains recordable area';
            $04: LayerType := 'Layer contains rewritable area';
            $08: LayerType := 'Reserved';
            else LayerType := 'Unknown';
          end;

          ShowMessage('DVD Layer Descriptor ok'#10'======================================='#10
                    + 'BookType: ' + BookType + #10
                    + 'DiscSize: ' + DiscSize + #10
                    + 'MaximumRate:' + MaximumRate + #10
                    + 'LinearDensity: ' + LinearDensity + #10
                    + 'TrackDensity: ' + TrackDensity + #10
                    + 'NoLayer: ' + NoLayer + #10
                    + 'LayerType: ' + LayerType + #10
                    + 'StartingPhysicalSector: 0x' + IntToHex(SwapDWord(DVDLayerDescriptor.StartingPhysicalSector), 6) + #10
                    + 'EndPhysicalSector: ' + IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSector))+#10
                    + 'EndPhysicalSectorInLayerZero: ' + IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSectorInLayerZero)) + #10
                    + 'Sectors: ' + IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSector) - SwapDWord(DVDLayerDescriptor.StartingPhysicalSector)));
        end;

        if ModeSense10Capabilities(AHandle, Mode10Capabilities) then
        begin
          Caps := '';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 0)  then Caps := 'Device can Read CD-R';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 1)  then Caps := Caps + #10'Device can Read CD-RW';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 2)  then Caps := Caps + #10'Device can Read Method 2';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 3)  then Caps := Caps + #10'Device can Read DVD-ROM';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 4)  then Caps := Caps + #10'Device can Read DVD-R / DVD-RW';
          if IsBitSet(Mode10Capabilities.ReadCapabilities, 5)  then Caps := Caps + #10'Device can Read DVD-RAM';
          if IsBitSet(Mode10Capabilities.WriteCapabilities, 0) then Caps := Caps + #10'Device can Write CD-R';
          if IsBitSet(Mode10Capabilities.WriteCapabilities, 1) then Caps := Caps + #10'Device can Write CD-RW';
          if IsBitSet(Mode10Capabilities.WriteCapabilities, 2) then Caps := Caps + #10'Device can Write Test';
          if IsBitSet(Mode10Capabilities.WriteCapabilities, 4) then Caps := Caps + #10'Device can Write DVD-R / DVD-RW';
          if IsBitSet(Mode10Capabilities.WriteCapabilities, 5) then Caps := Caps + #10'Device can Write DVD-RAM';
          Caps := Caps + #10'Device Buffer: ' + IntToStr(SwapWord(Mode10Capabilities.BufferSizeSupported)) + 'k';
          Caps := Caps + #10'Max Read Speed: ' + IntToStr(Round(SwapWord(Mode10Capabilities.MaxReadSpeed)  / 176.46)) + 'x';
          Caps := Caps + #10'Max Write Speed: ' + IntToStr(Round(SwapWord(Mode10Capabilities.MaxWriteSpeed)  / 176.46)) + 'x';
          Caps := Caps + #10'Current Read Speed: ' + IntToStr(Round(SwapWord(Mode10Capabilities.CurrentReadSpeed)  / 176.46)) + 'x';
          Caps := Caps + #10'Current Write Speed: ' + IntToStr(Round(SwapWord(Mode10Capabilities.CurrentWriteSpeed)  / 176.46)) + 'x';
          ShowMessage('Device Capabilities'#10
                    + '==========================================================='#10
                    + Caps);
        end;
      end;
    end
    else
    begin // Unit not ready! Execute no disc function, but handle drive capabilities request!
      ShowMessage('Error, unit not ready!'#13'Tray open or no disc in drive?');
    end;
  end;
end;

end.

//  Log List
//
// $Log: ISODiscLib.pas,v $
// Revision 1.5  2004/07/15 21:09:16  nalilord
// Fixed some bugs an structures in DeviceIO
// Fixed ReadTOC
// New function GetConfigurationData
// Now can get Device Capabilities but not yet finished
// Other workarounds and fixes
//
// Revision 1.4  2004/06/24 02:07:05  nalilord
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
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//

