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
// $Id:  $
//

Unit ISODiscLib;

Interface

Uses
  Windows,
  ISOSCSIConsts,
  ISOSCSIStructs,
  ISOToolBox,
  ISOASPILoader;

Type
  TProgressEvent = Procedure(Const Position: LongWord; Const Size: LongWord) Of Object;

Type
  TISODiscLib = Class
  Private
    FOnProgress : TProgressEvent;
    fUseSPTI    : Boolean;
    fUseASPI    : Boolean;
    FDrives     : TDriveList;

    Function   InitSPTI: Boolean;
    Function   InitASPI: Boolean;
    Function   OpenPort(Const APort: String): THandle;
    Function   ClosePort(Const AHandle: THandle): Boolean;
  Public
    Constructor Create; Virtual;
    Destructor  Destroy; Override;

    Function    ScanDevices: Boolean;
    Function    UnitReady(Const AHandle: THandle): Boolean;
    Function    ReadDiscInformation(Const AHandle: THandle; Var DiscInformation: TDiscInformation): Boolean;
    Function    GetDiscType(Const AHandle: THandle): Integer;
    Function    GetFormatCapacity(Const AHandle:THandle; Var FormatCapacity:TFormatCapacity): Boolean;
    Function    ReadTOC(Const AHandle: THandle; Var TOCDiscInformation:TTOCDiscInformation): Boolean;
    Function    ReadTrackInformation(Const AHandle: THandle; Const ATrack: Byte; Var TrackInformation:TTrackInformation): Boolean;
    Function    OpenDrive(Const ADrive: Char): THandle;
    Function    CloseDrive(Const AHandle: THandle): Boolean;
    Function    ReadDVDLayerDescriptor(Const AHandle: THandle; Var DVDLayerDescriptor:TDVDLayerDescriptor): Boolean;
    Function    ModeSense10Capabilities(Const AHandle: THandle; Var Mode10Capabilities:TMode10Capabilities): Boolean;

    Procedure   Test(Const AHandle: THandle);

    Property    OnProgress:TProgressEvent              Read  FOnProgress
                                                       Write FOnProgress;

  End;

Implementation

Uses
  Forms,     // for Application
  Dialogs,   // for ShowMessage()
  SysUtils;  // for Trim()

Constructor TISODiscLib.Create;
Begin
  Inherited;

  fUseASPI := InitASPI;
  fUseSPTI := InitSPTI;
End;

Destructor TISODiscLib.Destroy;
Begin
  If ( fUseASPI ) Then
    UnInitializeASPI;

  Inherited;
End;

Function TISODiscLib.InitSPTI: Boolean;
Begin
  If ( GetOsVersion In [OS_WIN2K, OS_WINXP, OS_WINNT4] ) Then
    Result := IsAdministrator
  Else
    Result := False;
End;

Function TISODiscLib.InitASPI: Boolean;
Var
  SupportInfo: LongWord;
Begin
  Result := False;

  If WNASPI32_Loaded Then
  Begin
    SupportInfo := GetASPI32SupportInfo;

    Result := ( HiByte( LoWord(SupportInfo) ) =  SS_COMP        ) And
              ( HiByte( LoWord(SupportInfo) ) <> SS_NO_ADAPTERS );
  End;
End;

Function TISODiscLib.OpenPort(Const APort: String): THandle;
Begin
  Result := INVALID_HANDLE_VALUE;

  If fUseSPTI Then
  Begin
    Result := CreateFile( PChar('\\.\'+ APort +':'),
                          GENERIC_READ Or GENERIC_WRITE,
                          FILE_SHARE_READ Or FILE_SHARE_WRITE,
                          Nil,
                          OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL,
                          0);
  End;
End;

Function TISODiscLib.ClosePort(Const AHandle: THandle): Boolean;
Begin
  Result := CloseHandle(AHandle);
End;

Function TISODiscLib.OpenDrive(Const ADrive: Char): THandle;
Begin
  Result := INVALID_HANDLE_VALUE;

  If fUseSPTI Then
    If GetDriveType(PChar(String(ADrive)+':')) = DRIVE_CDROM Then
      Result := OpenPort(ADrive);
End;

Function TISODiscLib.CloseDrive(Const AHandle: THandle):Boolean;
Begin
  Result := ClosePort(AHandle);
End;

Function TISODiscLib.UnitReady(Const AHandle: THandle): Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Returned : LongWord;
  Size     : Cardinal;
Begin
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

  Result := DeviceIoControl( AHandle,
                             IOCTL_SCSI_PASS_THROUGH_DIRECT,
                             @SPTDW, Size,
                             @SPTDW, Size,
                             Returned, Nil);
End;

Function TISODiscLib.ScanDevices: Boolean;
Var
  SPTDW           : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  ScsiInquiryData : SCSI_INQUIRY_DATA_RESULT;
  ScsiAddress     : SCSI_ADDRESS;
  ScsiPort,
  Size, Num,
  Returned        : LongWord;
Begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length          := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength       := 6;
  SPTDW.Spt.SenseInfoLength := 32;
  SPTDW.Spt.DataIn          := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(ScsiInquiryData);
  SPTDW.Spt.TimeOutValue    := 120;
  SPTDW.Spt.DataBuffer      := @ScsiInquiryData;
  SPTDW.Spt.SenseInfoOffset := 48;
  SPTDW.Spt.Cdb[0]          := $12;
  SPTDW.Spt.Cdb[4]          := SizeOf(ScsiInquiryData);

  ZeroMemory(@FDrives, SizeOf(FDrives));

  Num := 0;
  Repeat
    If GetDriveType(PChar(Chr(Num+65)+':\')) = DRIVE_CDROM Then
    Begin
      ScsiPort := OpenPort(Chr(Num+65));
      If ( ScsiPort <> INVALID_HANDLE_VALUE ) Then
      Begin
        ZeroMemory(@ScsiInquiryData, SizeOf(ScsiInquiryData));

        If DeviceIoControl(ScsiPort, IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
        Begin
          ZeroMemory(@ScsiAddress, SizeOf(ScsiAddress));
          ScsiAddress.Length := SizeOf(SCSI_ADDRESS);

          If DeviceIoControl(ScsiPort, IOCTL_SCSI_GET_ADDRESS, Nil, 0, @ScsiAddress, SizeOf(SCSI_ADDRESS), Returned, Nil) Then
          Begin
            FDrives.Drives[FDrives.NoOfDrives].Letter    := Chr(Num+65);
            FDrives.Drives[FDrives.NoOfDrives].HaId      := ScsiAddress.PathId;
            FDrives.Drives[FDrives.NoOfDrives].TargetId  := ScsiAddress.TargetId;
            FDrives.Drives[FDrives.NoOfDrives].LunID     := ScsiAddress.Lun;
            FDrives.Drives[FDrives.NoOfDrives].VendorId  := PChar(Trim(StrPas(ScsiInquiryData.VendorId)));
            FDrives.Drives[FDrives.NoOfDrives].ProductId := PChar(Trim(StrPas(ScsiInquiryData.ProductId)));
            FDrives.Drives[FDrives.NoOfDrives].Reversion := PChar(Trim(StrPas(ScsiInquiryData.Reversion)));

            Inc(FDrives.NoOfDrives);
            Result := True;

            Inc(FDrives.NoOfDrives);
          End;
        End;
      End;
      ClosePort(ScsiPort);
    End;
    Inc(Num);
  Until Num = 27;
End;

Function TISODiscLib.ReadDiscInformation(Const AHandle: THandle; Var DiscInformation:TDiscInformation): Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Returned,
  Size     : LongWord;
Begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
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

  ZeroMemory(@DiscInformation, SizeOf(DiscInformation));
  If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
  Begin
    DiscInformation.DataLen := SwapWord( DiscInformation.DataLen );
    Result := True;
  End;
End;

Function TISODiscLib.GetDiscType(Const AHandle: THandle):Integer;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
  DeviceConfigHeader : TDeviceConfigHeader;
Begin
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

  If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
  Begin
    Case SwapWord(DeviceConfigHeader.CurrentProfile) Of
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
    Else
      Result := -1;
    End;
  End;
End;

Function TISODiscLib.GetFormatCapacity(Const AHandle: THandle; Var FormatCapacity:TFormatCapacity):Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size, I  : Integer;
  Returned : LongWord;
Begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(FormatCapacity);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @FormatCapacity;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $23;
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(FormatCapacity));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(FormatCapacity));

  If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
  Begin
    For I := 0 To 32 Do
    Begin
      FormatCapacity.FormattableCD[I].NumberOfBlocks :=
                      SwapDWord(FormatCapacity.FormattableCD[I].NumberOfBlocks);
      FormatCapacity.FormattableCD[I].FormatType     :=
                               FormatCapacity.FormattableCD[I].FormatType Shr 2;
    End;

    FormatCapacity.BlockLength    := SwapWord(FormatCapacity.BlockLength);
    FormatCapacity.NumberOfBlocks := SwapDWord(FormatCapacity.NumberOfBlocks);
    Result := True;
  End;
End;

Function TISODiscLib.ReadTOC(Const AHandle: THandle; Var TOCDiscInformation:TTOCDiscInformation):Boolean;
Var
  SPTDW              : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size, Returned     : LongWord;
  TOCDataSessionInfo : TTOCDataSessionInfo;
  TOCDataATIP        : TTOCDataATIP;
  TOCData            : TTOCData;
Begin
  Result := True;

  ZeroMemory(@TOCDiscInformation, SizeOf(TOCDiscInformation));
  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(TOCData);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @TOCData;
  SPTDW.Spt.SenseInfoOffset    := 48;
  SPTDW.Spt.Cdb[0]             := $43; // Read TOC command

  ZeroMemory(@TOCData, SizeOf(TOCData));
  ZeroMemory(@TOCDataATIP, SizeOf(TOCDataATIP));
  ZeroMemory(@TOCDataSessionInfo, SizeOf(TOCDataSessionInfo));

  If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
  Begin
    TOCData.DataLength := SwapWord(TOCData.DataLength);

    SPTDW.Spt.Cdb[1] := $00;
    SPTDW.Spt.Cdb[2] := $00;
    SPTDW.Spt.Cdb[6] := TOCData.LastTrackNumber;
    SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TOCData));
    SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TOCData));

    If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                        @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
    Begin
      TOCData.DataLength        := SwapWord(TOCData.DataLength);
      TOCData.TrackStartAddress := SwapDWord(TOCData.TrackStartAddress);
      TOCDiscInformation.TOCData          := TOCData;
      TOCDiscInformation.FirstTrackNumber := TOCData.FirstTrackNumber;
      TOCDiscInformation.LastTrackNumber  := TOCData.LastTrackNumber;
    End;

    SPTDW.Spt.Cdb[1] := $00;
    SPTDW.Spt.Cdb[2] := $01;
    SPTDW.Spt.Cdb[6] := $00;
    SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TOCDataSessionInfo));
    SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TOCDataSessionInfo));
    SPTDW.Spt.DataBuffer := @TOCDataSessionInfo;
    SPTDW.Spt.DataTransferLength := SizeOf(TOCDataSessionInfo);

    If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                        @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
    Begin
      TOCDiscInformation.TOCDataSessionInfo := TOCDataSessionInfo;
    End;

    SPTDW.Spt.Cdb[1] := $02;
    SPTDW.Spt.Cdb[2] := $04;
    SPTDW.Spt.Cdb[6] := $00;
    SPTDW.Spt.Cdb[7] := HiByte(SizeOf(TOCDataATIP));
    SPTDW.Spt.Cdb[8] := LoByte(SizeOf(TOCDataATIP));
    SPTDW.Spt.DataBuffer := @TOCDataATIP;
    SPTDW.Spt.DataTransferLength := SizeOf(TOCDataATIP);

    If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                        @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
    Begin
      TOCDiscInformation.TOCDataATIP := TOCDataATIP;
      TOCDiscInformation.StartLBA    := HMSFtoLBA( 0,
                                                   TOCDataATIP.StartMin,
                                                   TOCDataATIP.StartSec,
                                                   TOCDataATIP.StartFrame);
      TOCDiscInformation.EndLBA      := HMSFtoLBA( 0,
                                                   TOCDataATIP.EndMin,
                                                   TOCDataATIP.EndSec,
                                                   TOCDataATIP.EndFrame);
    End;
  End
  Else
    Result := False;
End;

Function TISODiscLib.ReadTrackInformation(Const AHandle: THandle; Const ATrack: Byte; Var TrackInformation:TTrackInformation): Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
Begin
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

  If DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                      @SPTDW, Size, @SPTDW, Size, Returned, Nil) Then
  Begin
    With TrackInformation Do
    Begin
      Datalength          := SwapWord(Datalength);
      TrackSize           := SwapDWord(TrackSize);
      FreeBlocks          := SwapDWord(FreeBlocks);
      TrackStartAddress   := SwapDWord(TrackStartAddress);
      NextWritableAddress := SwapDWord(NextWritableAddress);
      FixedpacketSize     := SwapDWord(FixedpacketSize);
      LastRecordedAddress := SwapDWord(LastRecordedAddress);
    End;
    Result:=True;
  End;
End;

Function TISODiscLib.ReadDVDLayerDescriptor(Const AHandle: THandle; Var DVDLayerDescriptor:TDVDLayerDescriptor): Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
Begin
  Result := False;
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

  Result := DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                             @SPTDW, Size, @SPTDW, Size, Returned, Nil);
End;

Function TISODiscLib.ModeSense10Capabilities(Const AHandle: THandle; Var Mode10Capabilities:TMode10Capabilities): Boolean;
Var
  SPTDW    : SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size,
  Returned : LongWord;
Begin
  Result := False;

  ZeroMemory(@SPTDW, SizeOf(SPTDW));
  ZeroMemory(@Mode10Capabilities, SizeOf(Mode10Capabilities));
  Size := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);

  SPTDW.Spt.Length             := SizeOf(SCSI_PASS_THROUGH);
  SPTDW.Spt.CdbLength          := 10;
  SPTDW.Spt.SenseInfoLength    := 32;
  SPTDW.Spt.DataIn             := SCSI_IOCTL_DATA_IN;
  SPTDW.Spt.DataTransferLength := SizeOf(Mode10Capabilities);
  SPTDW.Spt.TimeOutValue       := 120;
  SPTDW.Spt.DataBuffer         := @Mode10Capabilities;
  SPTDW.Spt.SenseInfoOffset    := 48;

  SPTDW.Spt.Cdb[0] := $5A; // Mode Sense 10
  SPTDW.Spt.Cdb[2] := $2A; // Page code
  SPTDW.Spt.Cdb[7] := HiByte(SizeOf(Mode10Capabilities));
  SPTDW.Spt.Cdb[8] := LoByte(SizeOf(Mode10Capabilities));

  Result := DeviceIoControl( AHandle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                             @SPTDW, Size, @SPTDW, Size, Returned, Nil);
End;

(*
function TISODiscLib.Read10Buffer(Handle:Cardinal;LBA:DWORD;Length:DWORD;var Buffer; const BufferSize:Cardinal):Boolean;
var
  SPTDW:SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size:Integer;
  Returned:DWORD;
begin

  // read disc here
  // not ready, still problems with discanalyzing to get the size...

end;

function TISODiscLib.Read12Buffer(Handle:Cardinal;LBA:DWORD;Length:DWORD;var Buffer; const BufferSize:Cardinal):Boolean;
var
  SPTDW:SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size:Integer;
  Returned:DWORD;
begin

  // read disc here
  // not ready, still problems with discanalyzing to get the size...

end;

function TISODiscLib.ReadCDBuffer(Handle:Cardinal;LBA:DWORD;Length:DWORD;var Buffer; const BufferSize:Cardinal):Boolean;
var
  SPTDW:SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Size:Integer;
  Returned:DWORD;
begin

  // read disc here
  // not ready, still problems with discanalyzing to get the size...

end;
*)

Procedure TISODiscLib.Test(Const AHandle: THandle);
Var
  DiscType, Track, Attempts : Integer;
  DiscInformation           : TDiscInformation;
  FormatCapacity            : TFormatCapacity;
  TOCDiscInformation        : TTOCDiscInformation;
  TrackInformation          : TTrackInformation;
  DVDLayerDescriptor        : TDVDLayerDescriptor;
  Mode10Capabilities        : TMode10Capabilities;
  Value                     : Byte;
  BookType, DiscSize,
  MaximumRate, LinearDensity,
  TrackDensity, NoLayer, LayerType : String;
Begin
  Attempts := 0;

  If ( AHandle <> INVALID_HANDLE_VALUE ) Then
  Begin
    Repeat
      Inc(Attempts);
      Sleep(100);
      Application.ProcessMessages;
    Until ( UnitReady(AHandle)) Or (Attempts = 10);

    If Attempts < 10 Then
    Begin
      DiscType := GetDiscType(AHandle);

      If ( DiscType > -1 ) Then
      Begin
        ZeroMemory(@DiscInformation, SizeOf(DiscInformation));
        ZeroMemory(@FormatCapacity, SizeOf(FormatCapacity));
        ZeroMemory(@TOCDiscInformation, SizeOf(TOCDiscInformation));
        ZeroMemory(@TrackInformation, SizeOf(TrackInformation));

        If ( DiscType <= 8 ) Or ( DiscType >= 16 ) Then
        Begin
          if ReadDiscInformation(AHandle,DiscInformation) then
          begin
            if (DiscInformation.DiscStatus and 16) = 16 then
              ShowMessage('ReadDiscInformation ok'#13'======================================='#13+
                          'FirstTrack: '+IntToStr(DiscInformation.FirstTrack)+#13+
                          'DiscStatus: Eraseable'+#13+
                          'Sessions:'+IntToStr(DiscInformation.Sessions))
            else
              ShowMessage('ReadDiscInformation ok'#13'======================================='#13+
                          'FirstTrack: '+IntToStr(DiscInformation.FirstTrack)+#13+
                          'Sessions:'+IntToStr(DiscInformation.Sessions));
          end;
          if GetFormatCapacity(AHandle,FormatCapacity) then
          begin
            ShowMessage('GetFormatCapacity ok'#13'======================================='#13+
                        'NumberOfBlocks: '+IntToStr(FormatCapacity.NumberOfBlocks)+#13+
                        'BlockLength:'+IntToStr(FormatCapacity.BlockLength));
          end;
          if ReadTOC(AHandle,TOCDiscInformation) then
          begin
            ShowMessage('ReadTOC ok'#13'======================================='#13+
                        'Start LBA: '+IntToStr(TOCDiscInformation.StartLBA)+#13+
                        'End LBA:'+IntToStr(TOCDiscInformation.EndLBA));
          end;

          if DiscType >= 9 then Track:=1 else Track:=TOCDiscInformation.LastTrackNumber;

          if ReadTrackInformation(AHandle,Track,TrackInformation) then
          begin
            ShowMessage('ReadTrackInformation ok'#13'======================================='#13+
                        'TrackSize: '+IntToStr(TrackInformation.TrackSize)+#13+
                        'LastRecordedAddress:'+IntToStr(TrackInformation.LastRecordedAddress));
          end;
        end else
        begin
          ReadDVDLayerDescriptor(AHandle,DVDLayerDescriptor);

          Value:=(DVDLayerDescriptor.BookType_PartVersion shr 4 ) and $0F;
          case Value of
            $00: BookType:='DVD-ROM';
            $01: BookType:='DVD-RAM';
            $02: BookType:='DVD-R';
            $03: BookType:='DVD-RW';
            $09: BookType:='DVD+RW';
            $0A: BookType:='DVD+R';
            else BookType:='Unknown';
          end;


          Value:=(DVDLayerDescriptor.DiscSize_MaximumRate shr 4 ) and $0F;
          case Value of
            $00: DiscSize:='120mm';
            $01: DiscSize:='80mm';
            else DiscSize:='Unknown';
          end;

          Value:=(DVDLayerDescriptor.DiscSize_MaximumRate and $0F );
          case Value of
            $00: MaximumRate:='2.52 Mbps';
            $01: MaximumRate:='5.04 Mbps';
            $02: MaximumRate:='10.08 Mbps';
            $0F: MaximumRate:='Not Specified';
            else MaximumRate:='Unknown';
          end;

          Value:=(DVDLayerDescriptor.LinearDensity_TrackDensity shr 4 ) and $0F;
          case Value of
            $00: LinearDensity:='0.267 um/bit';
            $01: LinearDensity:='0.293 um/bit';
            $02: LinearDensity:='0.409 to 0.435 um/bit';
            $04: LinearDensity:='0.280 to 0.291 um/bit';
            $08: LinearDensity:='0.353 um/bit';
            else LinearDensity:='Reserved';
          end;

          Value:=(DVDLayerDescriptor.LinearDensity_TrackDensity and $0F );
          case Value of
            $00: TrackDensity:='0.74 um/track';
            $01: TrackDensity:='0.80 um/track';
            $02: TrackDensity:='0.615 um/track';
            else TrackDensity:='Reserved';
          end;

          NoLayer:=IntToStr((DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType shr 5 ) and $03);

          Value:=(DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType and $0F );
          case Value of
            $01: LayerType:='Layer contains embossed data';
            $02: LayerType:='Layer contains recordable area';
            $04: LayerType:='Layer contains rewritable area';
            $08: LayerType:='Reserved';
            else LayerType:='Unknown';
          end;

          ShowMessage('DVD Layer Descriptor ok'#13'======================================='#13+
                        'BookType: '+BookType+#13+
                        'DiscSize: '+DiscSize+#13+
                        'MaximumRate:'+MaximumRate+#13+
                        'LinearDensity: '+LinearDensity+#13+
                        'TrackDensity:'+TrackDensity+#13+
                        'NoLayer: '+NoLayer+#13+
                        'LayerType:'+LayerType+#13+
                        'StartingPhysicalSector: 0x'+IntToHex(SwapDWord(DVDLayerDescriptor.StartingPhysicalSector),6)+#13+
                        'EndPhysicalSector:'+IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSector))+#13+
                        'EndPhysicalSectorInLayerZero:'+IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSectorInLayerZero))+#13+
                        'Sectors:'+IntToStr(SwapDWord(DVDLayerDescriptor.EndPhysicalSector)-SwapDWord(DVDLayerDescriptor.StartingPhysicalSector)));
        End;

        ModeSense10Capabilities(AHandle,Mode10Capabilities);
      End;
    End
    Else
    Begin
      ShowMessage('Unit becomes not ready state...');
    End;
  End;
End;

End.

//  Log List
//
// $Log:  $
//
//
//

