//
//  TISOLib - ISO structure definitions
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ISOStructs.pas,v 1.3 2004/06/07 02:24:41 nalilord Exp $
//

unit ISOStructs;

interface

type
  TBothEndianWord = packed record
    LittleEndian,
    BigEndian     : Word;
  end;

  TBothEndianDWord = packed record
    LittleEndian,
    BigEndian     : LongWord;
  end;

  TVolumeDateTime = packed record
    Year      : array[0..3] of Char;
    Month     : array[0..1] of Char;
    Day       : array[0..1] of Char;
    Hour      : array[0..1] of Char;
    Minute    : array[0..1] of Char;
    Second    : array[0..1] of Char;
    MSeconds  : array[0..1] of Char;
    GMTOffset : Byte;
  end;

  TDirectoryDateTime = packed record
    Year      : Byte; // since 1900
    Month     : Byte;
    Day       : Byte;
    Hour      : Byte;
    Minute    : Byte;
    Second    : Byte;
    GMTOffset : Byte; // in 15 minutes steps
  end;

  TRootDirectoryRecord = packed record
    {0000h} LengthOfDirectoryRecord          : Byte;
    {0001h} ExtendedAttributeRecordLength    : Byte;
    {0002h} LocationOfExtent                 : TBothEndianDWord;
    {000Ah} DataLength                       : TBothEndianDWord;
    {0012h} RecordingDateAndTime             : TDirectoryDateTime;
    {0019h} FileFlags                        : Byte;
              //  bit     value
              //  ------  ------------------------------------------
              //  0 (LS)  0 for a norma1 file, 1 for a hidden file
              //  1       0 for a file, 1 for a directory
              //  2       0 [1 for an associated file]
              //  3       0 [1 for record format specified]
              //  4       0 [1 for permissions specified]
              //  5       0
              //  6       0
              //  7 (MS)  0 [1 if not the final record for the file]

    {001Ah} FileUnitSize                     : Byte;
    {001Bh} InterleaveGapSize                : Byte;
    {001Ch} VolumeSequenceNumber             : TBothEndianWord;
    {0020h} LengthOfFileIdentifier           : Byte; // = 1
    {0021h} FileIdentifier                   : Byte; // = 0
  end;

  PDirectoryRecord = ^TDirectoryRecord;
  TDirectoryRecord = packed record
    LengthOfDirectoryRecord          : Byte;
    ExtendedAttributeRecordLength    : Byte;
    LocationOfExtent                 : TBothEndianDWord;
    DataLength                       : TBothEndianDWord;
    RecordingDateAndTime             : TDirectoryDateTime;
    FileFlags                        : Byte;
      //  bit     value
      //  ------  ------------------------------------------
      //  0 (LS)  0 for a norma1 file, 1 for a hidden file
      //  1       0 for a file, 1 for a directory
      //  2       0 [1 for an associated file]
      //  3       0 [1 for record format specified]
      //  4       0 [1 for permissions specified]
      //  5       0
      //  6       0
      //  7 (MS)  0 [1 if not the final record for the file]

    FileUnitSize                     : Byte;
    InterleaveGapSize                : Byte;
    VolumeSequenceNumber             : TBothEndianWord;
    LengthOfFileIdentifier           : Byte;
    // followed by FileIdentifier and padding bytes
  end;

  PPathTableRecord = ^TPathTableRecord;
  TPathTableRecord = packed record
    LengthOfDirectoryIdentifier      : Byte;
    ExtendedAttributeRecordLength    : Byte;
    LocationOfExtent                 : Cardinal;
    ParentDirectoryNumber            : Word;
    // followed by DirectoryIdentifier with [LengthOfDirectoryIdentifier] bytes
    // followed by padding byte, if [LengthOfDirectoryIdentifier] is odd
  end;

  // Primary Volume Descriptor
  PPrimaryVolumeDescriptor = ^TPrimaryVolumeDescriptor;
  TPrimaryVolumeDescriptor = packed record
    {0001h} StandardIdentifier               : array[0..4]  of Char;
    {0006h} VolumeDescriptorVersion          : Byte;
    {0007h} unused                           : Byte;
    {0007h} SystemIdentifier                 : array[0..31] of Char;
    {0027h} VolumeIdentifier                 : array[0..31] of Char;
    {0047h} Unused2                          : array[0..7]  of Byte;
    {0001h} VolumeSpaceSize                  : TBothEndianDWord;
    {0001h} Unused3                          : array[0..31] of Byte;
    {0001h} VolumeSetSize                    : TBothEndianWord;
    {0001h} VolumeSequenceNumber             : TBothEndianWord;
    {0001h} LogicalBlockSize                 : TBothEndianWord;
    {0001h} PathTableSize                    : TBothEndianDWord;
    {0001h} LocationOfTypeLPathTable         : LongWord;
    {0001h} LocationOfOptionalTypeLPathTable : LongWord;
    {0001h} LocationOfTypeMPathTable         : LongWord;
    {0001h} LocationOfOptionalTypeMPathTable : LongWord;
    {0001h} RootDirectory                    : TRootDirectoryRecord;
    {0001h} VolumeSetIdentifier              : array[0..127] of Char;
    {0001h} PublisherIdentifier              : array[0..127] of Char;
    {0001h} DataPreparerIdentifier           : array[0..127] of Char;
    {0001h} ApplicationIdentifier            : array[0..127] of Char;
    {0001h} CopyrightFileIdentifier          : array[0..36]  of Char;
    {0001h} AbstractFileIdentifier           : array[0..36]  of Char;
    {0001h} BibliographicFileIdentifier      : array[0..36]  of Char;
    {0001h} VolumeCreationDateAndTime        : TVolumeDateTime;
    {0001h} VolumeModificationDateAndTime    : TVolumeDateTime;
    {0001h} VolumeExpirationDateAndTime      : TVolumeDateTime;
    {0001h} VolumeEffectiveDateAndTime       : TVolumeDateTime;
    {0001h} FileStructureVersion             : Byte;
    {0001h} ReservedForFutureStandardization : Byte;
    {0001h} ApplicationUse                   : array[0..511] of Byte;
    {0001h} ReservedForFutureStandardization2: array[0..652] of Byte;
  end;

  // Supplementary Volume Descriptor
  PSupplementaryVolumeDescriptor = ^TSupplementaryVolumeDescriptor;
  TSupplementaryVolumeDescriptor = packed record
    {0001h} StandardIdentifier               : array[0..4]  of Char;
    {0006h} VolumeDescriptorVersion          : Byte;
    {0007h} VolumeFlags                      : Byte;
    {0007h} SystemIdentifier                 : array[0..31] of Char;
    {0027h} VolumeIdentifier                 : array[0..31] of Char;
    {0047h} Unused2                          : array[0..7]  of Byte;
    {0001h} VolumeSpaceSize                  : TBothEndianDWord;
    {0001h} EscapeSequences                  : array[0..31] of Byte;
    {0001h} VolumeSetSize                    : TBothEndianWord;
    {0001h} VolumeSequenceNumber             : TBothEndianWord;
    {0001h} LogicalBlockSize                 : TBothEndianWord;
    {0001h} PathTableSize                    : TBothEndianDWord;
    {0001h} LocationOfTypeLPathTable         : LongWord;
    {0001h} LocationOfOptionalTypeLPathTable : LongWord;
    {0001h} LocationOfTypeMPathTable         : LongWord;
    {0001h} LocationOfOptionalTypeMPathTable : LongWord;
    {0001h} RootDirectory                    : TRootDirectoryRecord;
    {0001h} VolumeSetIdentifier              : array[0..127] of Char;
    {0001h} PublisherIdentifier              : array[0..127] of Char;
    {0001h} DataPreparerIdentifier           : array[0..127] of Char;
    {0001h} ApplicationIdentifier            : array[0..127] of Char;
    {0001h} CopyrightFileIdentifier          : array[0..36]  of Char;
    {0001h} AbstractFileIdentifier           : array[0..36]  of Char;
    {0001h} BibliographicFileIdentifier      : array[0..36]  of Char;
    {0001h} VolumeCreationDateAndTime        : TVolumeDateTime;
    {0001h} VolumeModificationDateAndTime    : TVolumeDateTime;
    {0001h} VolumeExpirationDateAndTime      : TVolumeDateTime;
    {0001h} VolumeEffectiveDateAndTime       : TVolumeDateTime;
    {0001h} FileStructureVersion             : Byte;
    {0001h} ReservedForFutureStandardization : Byte;
    {0001h} ApplicationUse                   : array[0..511] of Byte;
    {0001h} ReservedForFutureStandardization2: array[0..652] of Byte;
  end;

  // Boot Record Volume Descriptor
  PBootRecordVolumeDescriptor = ^TBootRecordVolumeDescriptor;
  TBootRecordVolumeDescriptor = packed record
    StandardIdentifier               : array[0..4] of Char;
    VersionOfDescriptor              : Byte;
    BootSystemIdentifier             : array[0..31] of Char;
    BootIdentifier                   : array[0..31] of Char;
    BootCatalogPointer               : LongWord;
    Unused                           : array[0..1972] of Byte;
  end;

const
  // Volume Descriptor Types
  vdtBR   = $00; // Boot Record
  vdtPVD  = $01; // Primary Volume Descriptor
  vdtSVD  = $02; // Supplementary Volume Descriptor
  vdtVDST = $ff; // Volume Descriptor Set Terminator

type
  TVolumeDescriptor = packed record
  case DescriptorType : Byte of
    vdtBR   : (BootRecord    : TBootRecordVolumeDescriptor);
    vdtPVD  : (Primary       : TPrimaryVolumeDescriptor);
    vdtSVD  : (Supplementary : TSupplementaryVolumeDescriptor);
  end;

implementation

end.

//  Log List
//
// $Log: ISOStructs.pas,v $
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//

