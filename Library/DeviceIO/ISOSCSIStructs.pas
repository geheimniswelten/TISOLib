//
//  TISOImage - SCSI structure definitions
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ISOSCSIStructs.pas,v 1.5 2004/07/15 21:09:16 nalilord Exp $
//

unit ISOSCSIStructs;

interface

uses
  Windows,
  ISOSCSIConsts;

type
  TSendASPI32Command      = function(Cmd: Pointer): LongWord; cdecl;
  TGetASPI32SupportInfo   = function: LongWord; cdecl;
  TGetASPI32Buffer        = function(Buffer: Pointer): LongWord; cdecl;
  TFreeASPI32Buffer       = function(Buffer: Pointer): Boolean; cdecl;
  TTranslateASPI32Address = function(Path: Pointer; DevNode: Pointer): Boolean; cdecl;

  SRB_HAInquiry = packed record
    SRB_Cmd       : Byte; // ASPI command code = SC_HA_INQUIRY
    SRB_Status    : Byte; // ASPI command status byte
    SRB_HaId      : Byte; // ASPI host adapter number
    SRB_Flags     : Byte; // ASPI request flags
    SRB_Hdr_Rsvd  : DWORD; // Reserved, MUST = 0
    HA_Count      : Byte; // Number of host adapters present
    HA_SCSI_ID    : Byte; // SCSI ID of host adapter
    HA_ManagerId  : array[0..15] of Byte; // String describing the manager
    HA_Identifier : array[0..15] of Byte; // String describing the host adapter
    HA_Unique     : array[0..15] of Byte; // Host Adapter Unique parameters
    HA_Rsvd1      : Word;
  end;

  PSRB_HAInquiry = ^SRB_HAInquiry;
  TSRB_HAInquiry = SRB_HAInquiry;

  SRB_GDEVBlock = packed record
    SRB_Cmd         : Byte; // ASPI command code = SC_GET_DEV_TYPE
    SRB_Status      : Byte; // ASPI command status byte
    SRB_HaId        : Byte; // ASPI host adapter number
    SRB_Flags       : Byte; // Reserved
    SRB_Hdr_Rsvd    : DWORD; // Reserved
    SRB_Target      : Byte; // Target's SCSI ID
    SRB_Lun         : Byte; // Target's LUN number
    SRB_DeviceType  : Byte; // Target's peripheral device type
    SRB_Rsvd1       : Byte;
  end;

  TSRB_GDEVBlock = SRB_GDEVBlock;
  PSRB_GDEVBlock = ^SRB_GDEVBlock;

  SRB_ExecSCSICmd = packed record
    SRB_Cmd         : Byte; // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status      : Byte; // ASPI command status byte
    SRB_HaId        : Byte; // ASPI host adapter number
    SRB_Flags       : Byte; // ASPI request flags
    SRB_Hdr_Rsvd    : DWORD; // Reserved
    SRB_Target      : Byte; // Target's SCSI ID
    SRB_Lun         : Byte; // Target's LUN number
    SRB_Rsvd1       : Word; // Reserved for Alignment
    SRB_BufLen      : DWORD; // Data Allocation Length
    SRB_BufPointer  : Pointer; // Data Buffer Pointer
    SRB_SenseLen    : Byte; // Sense Allocation Length
    SRB_CDBLen      : Byte; // CDB Length
    SRB_HaStat      : Byte; // Host Adapter Status
    SRB_TargStat    : Byte; // Target Status
    SRB_PostProc    : Pointer; // Post routine
    SRB_Rsvd2       : Pointer; // Reserved
    SRB_Rsvd3       : array[0..15] of Byte; // Reserved for alignment
    CDBByte         : array[0..15] of Byte; // SCSI CDB
    SenseArea       : array[0..SENSE_LEN+1] of Byte; // Request Sense buffer
  end;

  TSRB_ExecSCSICmd = SRB_ExecSCSICmd;
  PSRB_ExecSCSICmd = ^SRB_ExecSCSICmd;

  SRB_Abort = packed record
    SRB_Cmd       : Byte; // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status    : Byte; // ASPI command status byte
    SRB_HaId      : Byte; // ASPI host adapter number
    SRB_Flags     : Byte; // Reserved
    SRB_Hdr_Rsvd  : DWORD; // Reserved
    SRB_ToAbort   : Pointer; // Pointer to SRB to abort
  end;

  TSRB_Abort = SRB_Abort;
  PSRB_Abort = ^SRB_Abort;

  SRB_BusDeviceReset = packed record
    SRB_Cmd       : Byte; // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status    : Byte; // ASPI command status byte
    SRB_HaId      : Byte; // ASPI host adapter number
    SRB_Flags     : Byte; // Reserved
    SRB_Hdr_Rsvd  : DWORD; // Reserved
    SRB_Target    : Byte; // Target's SCSI ID
    SRB_Lun       : Byte; // Target's LUN number
    SRB_Rsvd1     : array[0..11] of Byte; // Reserved for Alignment
    SRB_HaStat    : Byte; // Host Adapter Status
    SRB_TargStat  : Byte; // Target Status
    SRB_PostProc  : Pointer; // Post routine
    SRB_Rsvd2     : Pointer; // Reserved
    SRB_Rsvd3     : array[0..15] of Byte; // Reserved
    CDBByte       : array[0..15] of Byte; // SCSI CDB
  end;

  TSRB_BusDeviceReset = SRB_BusDeviceReset;
  PSRB_BusDeviceReset = ^SRB_BusDeviceReset;

  SRB_GetDiskInfo = packed record
    SRB_Cmd             : Byte; // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status          : Byte; // ASPI command status byte
    SRB_HaId            : Byte; // ASPI host adapter number
    SRB_Flags           : Byte; // Reserved
    SRB_Hdr_Rsvd        : DWORD; // Reserved
    SRB_Target          : Byte; // Target's SCSI ID
    SRB_Lun             : Byte; // Target's LUN number
    SRB_DriveFlags      : Byte; // Driver flags
    SRB_Int13HDriveInfo : Byte; // Host Adapter Status
    SRB_Heads           : Byte; // Preferred number of heads translation
    SRB_Sectors         : Byte; // Preferred number of sectors translation
    SRB_Rsvd1           : array[0..9] of Byte; // Reserved
  end;

  TSRB_GetDiskInfo = SRB_GetDiskInfo;
  PSRB_GetDiskInfo = ^SRB_GetDiskInfo;

  SRB_RescanPort = packed record
    SRB_Cmd       :Byte; // 00/000 ASPI command code = SC_RESCAN_SCSI_BUS
    SRB_Status    :Byte; // 01/001 ASPI command status byte
    SRB_HaId      :Byte; // 02/002 ASPI host adapter number
    SRB_Flags     :Byte; // 03/003 Reserved, MUST = 0
    SRB_Hdr_Rsvd  : DWORD; // 04/004 Reserved, MUST = 0
  end;

  TSRB_RescanPort = SRB_RescanPort;
  PSRB_RescanPort = ^SRB_RescanPort;

  SRB_GetSetTimeouts = packed record
    SRB_Cmd       : Byte; // 00/000 ASPI command code = SC_GETSET_TIMEOUTS
    SRB_Status    : Byte; // 01/001 ASPI command status byte
    SRB_HaId      : Byte; // 02/002 ASPI host adapter number
    SRB_Flags     : Byte; // 03/003 ASPI request flags
    SRB_Hdr_Rsvd  : DWORD; // 04/004 Reserved, MUST = 0
    SRB_Target    : Byte; // 08/008 Target's SCSI ID
    SRB_Lun       : Byte; // 09/009 Target's LUN number
    SRB_Timeout   : DWORD; // 0A/010 Timeout in half seconds
  end;

  TSRB_GetSetTimeouts = SRB_GetSetTimeouts;
  PSRB_GetSetTimeouts = ^SRB_GetSetTimeouts;

  ASPI32BUFF = packed record
    AB_BufPointer : Pointer; // 00/000 Pointer to the ASPI allocated buffer
    AB_BufLen     : DWORD; // 04/004 Length in bytes of the buffer
    AB_ZeroFill   : DWORD; // 08/008 Flag set to 1 if buffer should be zeroed
    AB_Reserved   : DWORD; // 0C/012 Reserved
  end;

  TASPI32BUFF = ASPI32BUFF;
  PASPI32BUFF = ^ASPI32BUFF;

  TSenseData = packed record
    ErrorCode     : Byte;                   // Error Code (70H or 71H)
    SegmentNum    : Byte;                   // Number of current segment descriptor
    SenseKey      : Byte;                   // Sense Key(See bit definitions too)
    InfoByte0     : Byte;                   // Information MSB
    InfoByte1     : Byte;                   // Information MID
    InfoByte2     : Byte;                   // Information MID
    InfoByte3     : Byte;                   // Information LSB
    AddSenLen     : Byte;                   // Additional Sense Length
    ComSpecInf0   : Byte;                   // Command Specific Information MSB
    ComSpecInf1   : Byte;                   // Command Specific Information MID
    ComSpecInf2   : Byte;                   // Command Specific Information MID
    ComSpecInf3   : Byte;                   // Command Specific Information LSB
    AddSenseCode  : Byte;                   // Additional Sense Code
    AddSenQual    : Byte;                   // Additional Sense Code Qualifier
    FieldRepUCode : Byte;                   // Field Replaceable Unit Code
    SenKeySpec15  : Byte;                   // Sense Key Specific 15th byte
    SenKeySpec16  : Byte;                   // Sense Key Specific 16th byte
    SenKeySpec17  : Byte;                   // Sense Key Specific 17th byte
    AddSenseBytes : array[18..31] of Byte;  // Additional Sense Bytes
  end;

  TASPI32Buffer = packed record
    AB_BufPointer : Pointer;
    AB_BufLen     : LongInt;
    AB_ZeroFill   : LongInt;
    AB_Reserved   : LongInt;
  end;

  TSCSIDrive = packed record
    HA            : Byte;
    Target        : Byte;
    LUN           : Byte;
    Drive         : Byte;
    Used          : Boolean;
    DeviceHandle  : THandle;
    Data          : array[0..64] of AnsiChar;
  end;

  TSCSIDrives = packed record
    NumAdapters : Byte;
    Drive       : array[0..26] of TSCSIDrive;
  end;

  SCSI_ADDRESS = packed record
    Length      : Cardinal;
    PortNumber  : Byte;
    PathId      : Byte;
    TargetId    : Byte;
    Lun         : Byte;
  end;

  TDeviceConfigHeader = packed record
    DataLength        : Cardinal;
    Reserved          : Word;
    CurrentProfile    : Word;
    FeatureCode       : Word;
    Version           : Byte;
    AdditionalLength  : Byte;
    OtherData         : array[0..101] of Byte;
  end;

  TTOCData0000 = packed record
    DataLength        : Word;
    FirstTrackNumber  : Byte;
    LastTrackNumber   : Byte;
    Reserved1         : Byte;
    ADR_CONTROL       : Byte;
    TrackNumber       : Byte;
    Reserved3         : Byte;
    TrackStartAddress : Cardinal;
  end;

  TTOCData0001 = packed record
    DataLength                            : Word;
    FirstTrackNumber                      : Byte;
    LastTrackNumber                       : Byte;
    Reserved1                             : Byte;
    ADR_CONTROL                           : Byte;
    FirstTrackNumberInLastCompleteSession : Byte;
    Reserved3                             : Byte;
    StartAddressOfFirstTrackInLastSession : Cardinal;
  end;

  TTOCData0010 = packed record
    DataLength        : Word;
    FirstTrackNumber  : Byte;
    LastTrackNumber   : Byte;
    SessionNumberHex  : Byte;
    ADR_CONTROL       : Byte;
    TNO               : Byte;
    POINT             : Byte;
    MIN               : Byte;
    SEC               : Byte;
    FRAME             : Byte;
    ZERO_HOUR_PHOUR   : Byte;
    PMIN              : Byte;
    PSEC              : Byte;
    PFRAME            : Byte;
  end;

  TTOCData0011 = packed record
    DataLength        : Word;
    FirstTrackNumber  : Byte;
    LastTrackNumber   : Byte;
    Reserved          : Byte;
    ADR_CONTROL       : Byte;
    TNO               : Byte;
    POINT             : Byte;
    MIN               : Byte;
    SEC               : Byte;
    FRAME             : Byte;
    ZERO_HOUR_PHOUR   : Byte;
    PMIN              : Byte;
    PSEC              : Byte;
    PFRAME            : Byte;
  end;

  TTOCData0100 = packed record
    DataLength                                        : Word;
    Reserved1                                         : Byte;
    Reserved2                                         : Byte;
    IndicativeTargetWritingPower_DDCD_ReferenceSpeed  : Byte;
    URU                                               : Byte;
    DiscType_DiscSubType_A1Valid_A2Valid_A3Valid      : Byte;
    Reserved3                                         : Byte;
    ATIPStartTimeOfLeadIn_Min                         : Byte;
    ATIPStartTimeOfLeadIn_Sec                         : Byte;
    ATIPStartTimeOfLeadIn_Frame                       : Byte;
    Reserved4                                         : Byte;
    ATIPStartTimeOfLeadOut_Min                        : Byte;
    ATIPStartTimeOfLeadOut_Sec                        : Byte;
    ATIPStartTimeOfLeadOut_Frame                      : Byte;
    Reserved5                                         : Byte;
    A1Values                                          : array[0..2] of Byte;
    Reserved6                                         : Byte;
    A2Values                                          : array[0..2] of Byte;
    Reserved7                                         : Byte;
    A3Values                                          : array[0..2] of Byte;
    Reserved8                                         : Byte;
    S4Values                                          : array[0..2] of Byte;
    Reserved9                                         : Byte;
  end;

  TTOCData0101 = packed record
    DataLength  : Word;
    Reserved1   : Byte;
    Reserved2   : Byte;
    Data        : array[0..17] of Byte;
  end;

  TTrackInformation = packed record
    DataLength           : Word;
    TrackNumber          : Byte;
    SessionNumber        : Byte;
    Reserved             : Byte;
    TrackMode            : Byte;
    DataMode             : Byte;
    Reserved2            : Byte;
    TrackStartAddress    : LongWord;
    NextWritableAddress  : LongWord;
    FreeBlocks           : LongWord;
    FixedPacketSize      : LongWord;
    TrackSize            : LongWord;
    LastRecordedAddress  : LongWord;
    TrackNumber2         : Byte;
    SessionNumber2       : Byte;
    Reserved3            : Byte;
    Reserved4            : Byte;
    Reserved5            : Byte;
    Reserved6            : Byte;
  end;

  TFormattableCD = packed record
    NumberOfBlocks        : Cardinal;
    FormatType            : Byte;
    TypeDependentParamter : array[0..2] of Byte;
  end;

  TCapacityListHeader = packed record
    Reserved1           : Byte;
    Reserved2           : Byte;
    Reserved3           : Byte;
    CapacityListLength  : Byte;
  end;

  TCurrentMaximumCapacityDescriptor = packed record
    NumberOfBlocks      : Cardinal;
    DescriptorType      : Byte;
    BlockLength         : array[0..2] of Byte;
  end;

  TFormatCapacity = packed record
    CapacityListHeader  : TCapacityListHeader;
    CapacityDescriptor  : TCurrentMaximumCapacityDescriptor;
    FormattableCD       : array[0..32] of TFormattableCD;
    Unused              : Byte;
  end;

  PSCSI_PASS_THROUGH = ^SCSI_PASS_THROUGH;
  SCSI_PASS_THROUGH = {packed} record
    Length              : Word;
    ScsiStatus          : Byte;
    PathId              : Byte;
    TargetId            : Byte;
    Lun                 : Byte;
    CdbLength           : Byte;
    SenseInfoLength     : Byte;
    DataIn              : Byte;
    DataTransferLength  : ULONG;
    TimeOutValue        : ULONG;
    DataBufferOffset    : ULONG;
    SenseInfoOffset     : ULONG;
    Cdb                 : array[0..15] of Byte;
  end;

  PSCSI_PASS_THROUGH_DIRECT = ^SCSI_PASS_THROUGH_DIRECT;
  SCSI_PASS_THROUGH_DIRECT = {packed} record
    Length              : Word;
    ScsiStatus          : Byte;
    PathId              : Byte;
    TargetId            : Byte;
    Lun                 : Byte;
    CdbLength           : Byte;
    SenseInfoLength     : Byte;
    DataIn              : Byte;
    DataTransferLength  : ULONG;
    TimeOutValue        : ULONG;
    DataBuffer          : Pointer;
    SenseInfoOffset     : ULONG;
    Cdb                 : array[0..15] of Byte;
  end;

  PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = ^SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = {packed} record
    Spt      : SCSI_PASS_THROUGH_DIRECT;
    Filler   : ULONG;
    SenseBuf : array[0..31] of Byte;
  end;

  SENSE_DATA_FMT = packed record
    ErrorCode     : Byte; // Error Code (70H or 71H)End;
    SegmentNum    : Byte; // Number of current segment descriptor
    SenseKey      : Byte; // Sense Key(See bit definitions too)
    InfoByte0     : Byte; // Information MSB
    InfoByte1     : Byte; // Information MID
    InfoByte2     : Byte; // Information MID
    InfoByte3     : Byte; // Information LSB
    AddSenLen     : Byte; // Additional Sense Length
    ComSpecInf0   : Byte; // Command Specific Information MSB
    ComSpecInf1   : Byte; // Command Specific Information MID
    ComSpecInf2   : Byte; // Command Specific Information MID
    ComSpecInf3   : Byte; // Command Specific Information LSB
    AddSenseCode  : Byte; // Additional Sense Code
    AddSenQual    : Byte; // Additional Sense Code Qualifier
    FieldRepUCode : Byte; // Field Replaceable Unit Code
    SenKeySpec15  : Byte; // Sense Key Specific 15th byte
    SenKeySpec16  : Byte; // Sense Key Specific 16th byte
    SenKeySpec17  : Byte; // Sense Key Specific 17th byte
    AddSenseBytes : Byte; // Additional Sense Bytes
  end;

  TSENSE_DATA_FMT = SENSE_DATA_FMT;
  PSENSE_DATA_FMT = ^SENSE_DATA_FMT;

  SCSI_INQUIRY_DATA_RESULT = packed record
    Peripheral          : Byte;
    RMB                 : Byte;
    Version             : Byte;
    InterfaceDependent1 : Byte;
    AdditionalLength    : Byte;
    InterfaceDependent2 : Byte;
    InterfaceDependent3 : Byte;
    InterfaceDependent4 : Byte;
    VendorId            : array[0..7] of AnsiChar;
    ProductId           : array[0..15] of AnsiChar;
    Reversion           : array[0..3] of AnsiChar;
    VendorSpecific1     : array[0..19] of Byte;
    Reserved1           : Byte;
    Reserved2           : Byte;
    VersionDescriptor1  : Word;
    VersionDescriptor2  : Word;
    VersionDescriptor3  : Word;
    VersionDescriptor4  : Word;
    VersionDescriptor5  : Word;
    VersionDescriptor6  : Word;
    VersionDescriptor7  : Word;
    VersionDescriptor8  : Word;
    Reserved3           : array[0..21] of Byte;
    VendorSpecific2     : array[0..157] of Byte;
  end;

  TDrive = packed record
    Letter    : AnsiChar;
    HaId      : Byte;
    TargetId  : Byte;
    LunID     : Byte;
    VendorId  : PChar;
    ProductId : PChar;
    Reversion : PChar;
  end;

  TDriveList = packed record
    NoOfDrives  : Byte;
    Drives      : array[0..26] of TDrive;
  end;

  TDiscInformation = packed record
    DiscInformationLength           : Word;
    Status                          : Byte;
    NumberOfFirstTrack              : Byte;
    NumberOfSessionsLSB             : Byte;
    FirstTrackInLastSessionLSB      : Byte;
    LastTrackInLastSessionLSB       : Byte;
    DiscInfo                        : Byte;
    DiscType                        : Byte;
    NumberOfSessionsMSB             : Byte;
    FirstTrackInLastSessionMSB      : Byte;
    LastTrackInLastSessionMSB       : Byte;
    DiscIdentification              : Cardinal;
    LastSessionLeadinStartAddress   : Cardinal;
    LastPossibleLeadoutStartAddress : Cardinal;
    DiscBarCode                     : array[0..7] of Byte;
    DiscApplicationCode             : Byte;
    NumberOfOPCTables               : Byte;
  end;

  TOPCTableEntry = packed record
    Speed     : Word;
    OPCValues : array[0..5] of Byte;
  end;

  TDiscInformationBlockWithOPC = packed record
    DiscInformation : TDiscInformation;
    OPCTableEntries : array of TOPCTableEntry; // don't know the count or max count??
  end;

  SCSI_INQUIRY_DATA = packed record
    PathId                : Byte;
    TargetId              : Byte;
    Lun                   : Byte;
    DeviceClaimed         : Boolean;
    InquiryDataLength     : ULONG;
    NextInquiryDataOffset : ULONG;
    InquiryData           : Byte;
  end;

  SCSI_BUS_DATA = packed record
    NumberOfLogicalUnits  : Byte;
    InitiatorBusId        : Byte;
    InquiryDataOffset     : ULONG;
  end;

  SCSI_ADAPTER_BUS_INFO = packed record
    NumberOfBuses : Byte;
    BusData       : SCSI_BUS_DATA;
  end;

  TDVDLayerDescriptor = packed record
    DataLength                          : Word;
    Reserved1                           : Byte;
    Reserved2                           : Byte;
    BookType_PartVersion                : Byte; // BookType Nibble
                                                //    0000    = DVD-ROM = $00
                                                //    0001    = DVD-RAM = $01
                                                //    0010    = DVD-R   = $02
                                                //    0011    = DVD-RW  = $03
                                                //    1001    = DVD+RW  = $09
                                                //    1010    = DVD+R   = $0A
                                                //    Others  = Reserved
    DiscSize_MaximumRate                : Byte; // DiscSize Nibble
                                                //    0000    = 120mm   = $00
                                                //    0001    = 80mm    = $01
                                                // MaximumRate Nibble
                                                //    0000    = 2.52 Mbps     = $00
                                                //    0001    = 5.04 Mbps     = $01
                                                //    0010    = 10.08 Mbps    = $02
                                                //    1111    = Not Specified = $0F
                                                //    Others  = Reserved
    NumberOfLayers_TrackPath_LayerType  : Byte; // LayerType Bit
                                                //    0 = Layer contains embossed data    = $01
                                                //    1 = Layer contains recordable area  = $02
                                                //    2 = Layer contains rewritable area  = $04
                                                //    3 = Reserved                        = $08
    LinearDensity_TrackDensity          : Byte; // LinearDensity Nibble
                                                //    0000    = 0.267 um/bit          = $00
                                                //    0001    = 0.293 um/bit          = $01
                                                //    0010    = 0.409 to 0.435 um/bit = $02
                                                //    0100    = 0.280 to 0.291 um/bit = $04
                                                //    1000    = 0.353 um/bit          = $08
                                                //    Others  = Reserved
                                                // TrackDensity Nibble
                                                //    0000    = 0.74 um/track   = $00
                                                //    0001    = 0.80 um/track   = $01
                                                //    0010    = 0.615 um/track  = $02
                                                //    Others  = Reserved
    StartingPhysicalSector              : DWORD;
    EndPhysicalSector                   : DWORD;
    EndPhysicalSectorInLayerZero        : DWORD;
(*
    Reserved3                           : Byte;
    StartingPhysicalSector              : array[0..2] of Byte;
                                                //    30000h DVD-ROM, DVD-R/-RW, DVD+RW
                                                //    31000h DVD-RAM
                                                //    Others Reserved
    Reserved4                           : Byte;
    EndPhysicalSector                   : array[0..2] of Byte;
    Reserved5                           : Byte;
    EndPhysicalSectorInLayerZero        : array[0..2] of Byte;
*)
    BCA                                 : Byte;
  end;

  TLogicalUnitWriteSpeedPerformanceDescriptorTable = packed record
    Reserved:Byte;
    RotationControl:Byte;
    WriteSpeedSupported:Word;
  end;

  TModeParametersHeader = packed record
    ModeDataLength        : Word;
    Reserved1             : Byte;
    Reserved2             : Byte;
    Reserved3             : Byte;
    Reserved4             : Byte;
    BlockDescriptorLength : Word;
  end;

  TMode10Capabilities = packed record
    ModeParametersHeader        : TModeParametersHeader;
    PageCode                    : Byte;
    PageLength                  : Byte;
    ReadCapabilities            : Byte;
    WriteCapabilities           : Byte;
    Capabilities1               : Byte;
    Capabilities2               : Byte;
    Capabilities3               : Byte;
    Capabilities4               : Byte;
    MaxReadSpeed                : Word;
    VolumeLevelsSupported       : Word;
    BufferSizeSupported         : Word;
    CurrentReadSpeed            : Word;
    Reserved1                   : Byte;
    Length_LSBF_RCK_BCKF        : Byte;
    MaxWriteSpeed               : Word;
    CurWriteSpeed_Res           : Word;
    CopyManagemnetRevSupported  : Word;
    Reserved2                   : array[0..2] of Byte;
    RotationControlSpeed        : Byte;
    CurrentWriteSpeed           : Word;
    NoWriteSpeedDescTables      : Word;
    WriteSpeeds                 : array[0..99] of TLogicalUnitWriteSpeedPerformanceDescriptorTable;
  end;

  TCapabilities = ( caReadCDR,
                    caReadCDRW,
                    caReadMethod2,
                    caReadDVDROM,
                    caReadDVDR,
                    caReadDVDRW,
                    caReadDVDRAM,
                    caReadDVDPLUSR,
                    caReadDVDPLUSRW,
                    caReadBarcode,
                    caWriteCDR,
                    caWriteCDRW,
                    caWriteTest,
                    caWriteDVDR,
                    caWriteDVDRW,
                    caWriteDVDRAM,
                    caWriteDVDPLUSR,
                    caWriteDVDPLUSRW,
                    caUPC,
                    caISRC,
                    caBufferUnderrunProtection);

  TDeviceCapabilities = set of TCapabilities;

  TMechanismStatusHeader = packed record
    Fault_ChangerState_CurrentSlot      : Byte; // Bit(s)
                                                //   7  = Fault
                                                //
                                                // 6-5  = Changer State
                                                //  +-- 0h  = Ready
                                                //  +-- 1h  = Load in Progress
                                                //  +-- 2h  = Unload in Progress
                                                //  +-- 3h  = Initializing
                                                //
                                                // 4-0  = Current Slot (Low order 5 bits)
    MechanismState_DoorOpen_CurrentSlot : Byte; // Bit(s)
                                                //
                                                // 7-5  = Mechanism State
                                                //  +-- 0h  = Idle
                                                //  +-- 1h  = Playing (Audio or Data)
                                                //  +-- 2h  = Scanning
                                                //  +-- 3h  = Active with Initiator, Composite or Other Ports in use (i.e. READ)
                                                //  +-- 7h  = No State Information Available
                                                //
                                                //   4  = Door open
                                                // 2-0  = Current Slot (High order 3 bits)
    CurrentLBA                          : array[0..2] of Byte;
    NumberOfSlots                       : Byte;
    LengthOfSlot                        : Word;
  end;

  TSlotTable = packed record
    DiscPresent_Change  : Byte; // Bit(s)
                                // 7  = Disc Present
                                // 0  = Change
    CWPV_CWP            : Byte; // Bit(s)
                                // 1  = CWP_V
                                // 0  = CWP
    Reserved1           : Byte;
    Reserved2           : Byte;
  end;

  TMechanismStatus = packed record
    MechanismStatusHeader : TMechanismStatusHeader;
    SlotTables            : array[0..9] of TSlotTable;
  end;

  TUnitReturned = 0..2;

implementation

end.

//  Log List
//
// $Log: ISOSCSIStructs.pas,v $
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

