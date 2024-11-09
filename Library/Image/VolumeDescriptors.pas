//
//  TISOLib - Volume Descriptors
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: VolumeDescriptors.pas,v 1.3 2004/06/07 02:24:41 nalilord Exp $
//

unit VolumeDescriptors;

interface

uses
  SysUtils,
  Classes,
  ISOStructs,
  {}GlobalDefs,
  {}ISOToolBox;

type
  EVolumeDescriptorException = class(Exception);
  EVDWrongDescriptorType = class(EVolumeDescriptorException);

  TPrimaryVolumeDescriptor = class
  private
    function  GetString(AIndex : Integer): string;
    procedure SetString(AIndex : Integer; const Value: string);

  protected
    fDescriptor : TVolumeDescriptor;

  public
    constructor Create; overload; virtual;
    constructor Create(const APrimaryVolumeDescriptor: TVolumeDescriptor); overload; virtual;
    destructor  Destroy; override;

    procedure Dump(AOutput: TStrings);

  published
    property Descriptor : TVolumeDescriptor  read fDescriptor;

    property SystemIdentifier              : string  index 0  read GetString write SetString;
    property VolumeIdentifier              : string  index 1  read GetString write SetString;
    property VolumeSetIdentifier           : string  index 2  read GetString write SetString;
    property PublisherIdentifier           : string  index 3  read GetString write SetString;
    property DataPreparerIdentifier        : string  index 4  read GetString write SetString;
    property ApplicationIdentifier         : string  index 5  read GetString write SetString;
    property CopyrightFileIdentifier       : string  index 6  read GetString write SetString;
    property AbstractFileIdentifier        : string  index 7  read GetString write SetString;
    property BibliographicFileIdentifier   : string  index 8  read GetString write SetString;
    property VolumeCreationDateAndTime     : TVolumeDateTime  read fDescriptor.Primary.VolumeCreationDateAndTime        write fDescriptor.Primary.VolumeCreationDateAndTime;
    property VolumeModificationDateAndTime : TVolumeDateTime  read fDescriptor.Primary.VolumeModificationDateAndTime    write fDescriptor.Primary.VolumeModificationDateAndTime;
    property VolumeExpirationDateAndTime   : TVolumeDateTime  read fDescriptor.Primary.VolumeExpirationDateAndTime      write fDescriptor.Primary.VolumeExpirationDateAndTime;
    property VolumeEffectiveDateAndTime    : TVolumeDateTime  read fDescriptor.Primary.VolumeEffectiveDateAndTime       write fDescriptor.Primary.VolumeEffectiveDateAndTime;
    property VolumeSetSize                 : TBothEndianWord  read fDescriptor.Primary.VolumeSetSize                    write fDescriptor.Primary.VolumeSetSize;
    property VolumeSequenceNumber          : TBothEndianWord  read fDescriptor.Primary.VolumeSequenceNumber             write fDescriptor.Primary.VolumeSequenceNumber;
    property LogicalBlockSize              : TBothEndianWord  read fDescriptor.Primary.LogicalBlockSize                 write fDescriptor.Primary.LogicalBlockSize;
    property PathTableSize                 : TBothEndianDWord read fDescriptor.Primary.PathTableSize                    write fDescriptor.Primary.PathTableSize;
    property VolumeSpaceSize               : TBothEndianDWord read fDescriptor.Primary.VolumeSpaceSize                  write fDescriptor.Primary.VolumeSpaceSize;
    property RootDirectory             : TRootDirectoryRecord read fDescriptor.Primary.RootDirectory                    write fDescriptor.Primary.RootDirectory;
    property LocationOfTypeLPathTable         : LongWord      read fDescriptor.Primary.LocationOfTypeLPathTable         write fDescriptor.Primary.LocationOfTypeLPathTable;
    property LocationOfOptionalTypeLPathTable : LongWord      read fDescriptor.Primary.LocationOfOptionalTypeLPathTable write fDescriptor.Primary.LocationOfOptionalTypeLPathTable;
    property LocationOfTypeMPathTable         : LongWord      read fDescriptor.Primary.LocationOfTypeMPathTable         write fDescriptor.Primary.LocationOfTypeMPathTable;
    property LocationOfOptionalTypeMPathTable : LongWord      read fDescriptor.Primary.LocationOfOptionalTypeMPathTable write fDescriptor.Primary.LocationOfOptionalTypeMPathTable;
  end;

  TSupplementaryVolumeDescriptor = class
  private
    function  GetString(AIndex: Integer): string;
    procedure SetString(AIndex: Integer; const Value: string);

  protected
    fDescriptor : TVolumeDescriptor;

  public
    constructor Create; overload; virtual;
    constructor Create(const ASupplementaryVolumeDescriptor : TVolumeDescriptor); overload; virtual;
    destructor  Destroy; override;

    procedure Dump(AOutput: TStrings);

  published
    property Descriptor : TVolumeDescriptor read fDescriptor;

    property SystemIdentifier              : string  index 0  read GetString write SetString;
    property VolumeIdentifier              : string  index 1  read GetString write SetString;
    property VolumeSetIdentifier           : string  index 2  read GetString write SetString;
    property PublisherIdentifier           : string  index 3  read GetString write SetString;
    property DataPreparerIdentifier        : string  index 4  read GetString write SetString;
    property ApplicationIdentifier         : string  index 5  read GetString write SetString;
    property CopyrightFileIdentifier       : string  index 6  read GetString write SetString;
    property AbstractFileIdentifier        : string  index 7  read GetString write SetString;
    property BibliographicFileIdentifier   : string  index 8  read GetString write SetString;
    property VolumeCreationDateAndTime     : TVolumeDateTime  read fDescriptor.Supplementary.VolumeCreationDateAndTime        write fDescriptor.Supplementary.VolumeCreationDateAndTime;
    property VolumeModificationDateAndTime : TVolumeDateTime  read fDescriptor.Supplementary.VolumeModificationDateAndTime    write fDescriptor.Supplementary.VolumeModificationDateAndTime;
    property VolumeExpirationDateAndTime   : TVolumeDateTime  read fDescriptor.Supplementary.VolumeExpirationDateAndTime      write fDescriptor.Supplementary.VolumeExpirationDateAndTime;
    property VolumeEffectiveDateAndTime    : TVolumeDateTime  read fDescriptor.Supplementary.VolumeEffectiveDateAndTime       write fDescriptor.Supplementary.VolumeEffectiveDateAndTime;
    property VolumeSetSize                 : TBothEndianWord  read fDescriptor.Supplementary.VolumeSetSize                    write fDescriptor.Supplementary.VolumeSetSize;
    property VolumeSequenceNumber          : TBothEndianWord  read fDescriptor.Supplementary.VolumeSequenceNumber             write fDescriptor.Supplementary.VolumeSequenceNumber;
    property LogicalBlockSize              : TBothEndianWord  read fDescriptor.Supplementary.LogicalBlockSize                 write fDescriptor.Supplementary.LogicalBlockSize;
    property PathTableSize                 : TBothEndianDWord read fDescriptor.Supplementary.PathTableSize                    write fDescriptor.Supplementary.PathTableSize;
    property VolumeSpaceSize               : TBothEndianDWord read fDescriptor.Supplementary.VolumeSpaceSize                  write fDescriptor.Supplementary.VolumeSpaceSize;
    property RootDirectory             : TRootDirectoryRecord read fDescriptor.Supplementary.RootDirectory                    write fDescriptor.Supplementary.RootDirectory;
    property LocationOfTypeLPathTable         : LongWord      read fDescriptor.Supplementary.LocationOfTypeLPathTable         write fDescriptor.Supplementary.LocationOfTypeLPathTable;
    property LocationOfOptionalTypeLPathTable : LongWord      read fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable write fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable;
    property LocationOfTypeMPathTable         : LongWord      read fDescriptor.Supplementary.LocationOfTypeMPathTable         write fDescriptor.Supplementary.LocationOfTypeMPathTable;
    property LocationOfOptionalTypeMPathTable : LongWord      read fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable write fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable;
    property VolumeFlags                      : Byte          read fDescriptor.Supplementary.VolumeFlags                      write fDescriptor.Supplementary.VolumeFlags;
  end;

  TBootRecordVolumeDescriptor = class
  private
    function  GetString(AIndex : Integer): string;
    procedure SetString(AIndex : Integer; const Value: string);

  protected
    fDescriptor : TVolumeDescriptor;

  public
    constructor Create; overload; virtual;
    constructor Create(const ABootRecordVolumeDescriptor: TVolumeDescriptor); overload; virtual;
    destructor  Destroy; override;

    procedure Dump(AOutput: TStrings);

  published
    property Descriptor : TVolumeDescriptor read fDescriptor;

    property BootSystemIdentifier : string  index 0  read GetString write SetString;
    property BootIdentifier       : string  index 1  read GetString write SetString;
    property BootCatalogPointer   : LongWord         read fDescriptor.BootRecord.BootCatalogPointer write fDescriptor.BootRecord.BootCatalogPointer;
  end;

implementation

{ TPrimaryVolumeDescriptor }

constructor TPrimaryVolumeDescriptor.Create;
begin
  inherited;

  FillChar(fDescriptor, SizeOf(fDescriptor), 0);

  fDescriptor.DescriptorType := vdtPVD;

  with fDescriptor.Primary do
  begin
    StandardIdentifier      := 'CD001';
    VolumeDescriptorVersion := $01;
    VolumeSetSize           := BuildBothEndianWord(1);
    ApplicationIdentifier   := 'ISOLibrary ' + coISOLibVersion;
    FileStructureVersion    := $01;
  end;
end;

constructor TPrimaryVolumeDescriptor.Create(const APrimaryVolumeDescriptor: TVolumeDescriptor);
begin
  inherited Create;

  if ( APrimaryVolumeDescriptor.DescriptorType <> vdtPVD ) then
    raise EVDWrongDescriptorType.Create('Descriptor type mismatch');

  fDescriptor := APrimaryVolumeDescriptor;
end;

destructor TPrimaryVolumeDescriptor.Destroy;
begin
  inherited;
end;

procedure TPrimaryVolumeDescriptor.Dump(AOutput: TStrings);
begin
  if Assigned(AOutput) then
  begin
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.StandardIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'StandardIdentifier = '                  + string(fDescriptor.Primary.StandardIdentifier));
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.VolumeDescriptorVersion) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeDescriptorVersion = '          + IntToHex( fDescriptor.Primary.VolumeDescriptorVersion,
                                                           SizeOf(fDescriptor.Primary.VolumeDescriptorVersion)*2) + 'h');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.SystemIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'SystemIdentifier = '                    + string(fDescriptor.Primary.SystemIdentifier));
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.VolumeIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeIdentifier = '                    + string(fDescriptor.Primary.VolumeIdentifier));
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.VolumeSpaceSize) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSpaceSize = '
              + 'Intel: '                             + IntToHex( fDescriptor.Primary.VolumeSpaceSize.LittleEndian,
                                                           SizeOf(fDescriptor.Primary.VolumeSpaceSize.LittleEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.VolumeSpaceSize.LittleEndian) + 'd '
              + 'Motorola: '                          + IntToHex( fDescriptor.Primary.VolumeSpaceSize.BigEndian,
                                                           SizeOf(fDescriptor.Primary.VolumeSpaceSize.BigEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.VolumeSpaceSize.BigEndian) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.VolumeSetSize) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSetSize = '
              + 'Intel: '                             + IntToHex( fDescriptor.Primary.VolumeSetSize.LittleEndian,
                                                           SizeOf(fDescriptor.Primary.VolumeSetSize.LittleEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.VolumeSetSize.LittleEndian) + 'd '
              + 'Motorola: '                          + IntToHex( fDescriptor.Primary.VolumeSetSize.BigEndian,
                                                           SizeOf(fDescriptor.Primary.VolumeSetSize.BigEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.VolumeSetSize.BigEndian) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.LogicalBlockSize) - Integer(@fDescriptor), 4) + 'h '
              + 'LogicalBlockSize = '
              + 'Intel: '                             + IntToHex( fDescriptor.Primary.LogicalBlockSize.LittleEndian,
                                                           SizeOf(fDescriptor.Primary.LogicalBlockSize.LittleEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LogicalBlockSize.LittleEndian) + 'd '
              + 'Motorola: '                          + IntToHex( fDescriptor.Primary.LogicalBlockSize.BigEndian,
                                                           SizeOf(fDescriptor.Primary.LogicalBlockSize.BigEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LogicalBlockSize.BigEndian) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.PathTableSize) - Integer(@fDescriptor), 4) + 'h '
              + 'PathTableSize = '
              + 'Intel: '                             + IntToHex( fDescriptor.Primary.PathTableSize.LittleEndian,
                                                           SizeOf(fDescriptor.Primary.PathTableSize.LittleEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.PathTableSize.LittleEndian) + 'd '
              + 'Motorola: '                          + IntToHex( fDescriptor.Primary.PathTableSize.BigEndian,
                                                           SizeOf(fDescriptor.Primary.PathTableSize.BigEndian)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.PathTableSize.BigEndian) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.LocationOfTypeLPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfTypeLPathTable = '         + IntToHex( fDescriptor.Primary.LocationOfTypeLPathTable,
                                                           SizeOf(fDescriptor.Primary.LocationOfTypeLPathTable)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LocationOfTypeLPathTable) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.LocationOfOptionalTypeLPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfOptionalTypeLPathTable = ' + IntToHex( fDescriptor.Primary.LocationOfOptionalTypeLPathTable,
                                                           SizeOf(fDescriptor.Primary.LocationOfOptionalTypeLPathTable)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LocationOfOptionalTypeLPathTable) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.LocationOfTypeMPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfTypeMPathTable = '         + IntToHex( fDescriptor.Primary.LocationOfTypeMPathTable,
                                                           SizeOf(fDescriptor.Primary.LocationOfTypeMPathTable)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LocationOfTypeMPathTable) + 'd');
    AOutput.Add(                                IntToHex(Integer(@fDescriptor.Primary.LocationOfOptionalTypeMPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfOptionalTypeMPathTable = ' + IntToHex( fDescriptor.Primary.LocationOfOptionalTypeMPathTable,
                                                           SizeOf(fDescriptor.Primary.LocationOfOptionalTypeMPathTable)*2) + 'h '
                                                      + IntToStr( fDescriptor.Primary.LocationOfOptionalTypeMPathTable) + 'd');

    // Root Directory Entry
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.LengthOfDirectoryRecord) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: LengthOfDirectoryRecord = '       + IntToHex( fDescriptor.Primary.RootDirectory.LengthOfDirectoryRecord,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.LengthOfDirectoryRecord)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.LengthOfDirectoryRecord) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.ExtendedAttributeRecordLength) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: ExtendedAttributeRecordLength = ' + IntToHex( fDescriptor.Primary.RootDirectory.ExtendedAttributeRecordLength,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.ExtendedAttributeRecordLength)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.ExtendedAttributeRecordLength) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.LocationOfExtent) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: LocationOfExtent = '
              + 'Intel: '                              + IntToHex( fDescriptor.Primary.RootDirectory.LocationOfExtent.LittleEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.LocationOfExtent.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.LocationOfExtent.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Primary.RootDirectory.LocationOfExtent.BigEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.LocationOfExtent.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.LocationOfExtent.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.DataLength) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: DataLength = '
              + 'Intel: '                              + IntToHex( fDescriptor.Primary.RootDirectory.DataLength.LittleEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.DataLength.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.DataLength.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Primary.RootDirectory.DataLength.BigEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.DataLength.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.DataLength.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.FileFlags) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: FileFlags = '                     + IntToHex( fDescriptor.Primary.RootDirectory.FileFlags,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.FileFlags)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.FileFlags ) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.FileUnitSize) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: FileUnitSize = '                  + IntToHex( fDescriptor.Primary.RootDirectory.FileUnitSize,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.FileUnitSize)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.FileUnitSize) + 'd');
    AOutput.Add(IntToHex(Integer(@fDescriptor.Primary.RootDirectory.InterleaveGapSize) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: InterleaveGapSize = '             + IntToHex( fDescriptor.Primary.RootDirectory.InterleaveGapSize,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.InterleaveGapSize)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.InterleaveGapSize) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.VolumeSequenceNumber) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: VolumeSequenceNumber = '
              + 'Intel: '                              + IntToHex( fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.LittleEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.BigEndian,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.VolumeSequenceNumber.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.LengthOfFileIdentifier) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: LengthOfFileIdentifier = '        + IntToHex( fDescriptor.Primary.RootDirectory.LengthOfFileIdentifier,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.LengthOfFileIdentifier)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.LengthOfFileIdentifier) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Primary.RootDirectory.FileIdentifier) - Integer(@fDescriptor.Primary.RootDirectory), 4) + 'h '
              + 'RD: FileIdentifier = '                + IntToHex( fDescriptor.Primary.RootDirectory.FileIdentifier,
                                                            SizeOf(fDescriptor.Primary.RootDirectory.FileIdentifier)*2) + 'h '
                                                       + IntToStr( fDescriptor.Primary.RootDirectory.FileIdentifier) + 'd');

    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.VolumeSetIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSetIdentifier = '           + string(fDescriptor.Primary.VolumeSetIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.PublisherIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'PublisherIdentifier = '           + string(fDescriptor.Primary.PublisherIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.DataPreparerIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'DataPreparerIdentifier = '        + string(fDescriptor.Primary.DataPreparerIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.ApplicationIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'ApplicationIdentifier = '         + string(fDescriptor.Primary.ApplicationIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.CopyrightFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'CopyrightFileIdentifier = '       + string(fDescriptor.Primary.CopyrightFileIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.AbstractFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'AbstractFileIdentifier = '        + string(fDescriptor.Primary.AbstractFileIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.BibliographicFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'BibliographicFileIdentifier = '   + string(fDescriptor.Primary.BibliographicFileIdentifier));
    AOutput.Add(                          IntToHex(Integer(@fDescriptor.Primary.VolumeCreationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeCreationDateAndTime = '     + VolumeDateTimeToStr(fDescriptor.Primary.VolumeCreationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Primary.VolumeModificationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeModificationDateAndTime = ' + VolumeDateTimeToStr(fDescriptor.Primary.VolumeModificationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Primary.VolumeExpirationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeExpirationDateAndTime = '   + VolumeDateTimeToStr(fDescriptor.Primary.VolumeExpirationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Primary.VolumeEffectiveDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'h VolumeEffectiveDateAndTime = '  + VolumeDateTimeToStr(fDescriptor.Primary.VolumeEffectiveDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Primary.FileStructureVersion) - Integer(@fDescriptor), 4) + 'h '
              + 'FileStructureVersion = '                     + IntToHex(fDescriptor.Primary.FileStructureVersion, 2) + 'h '
                                                              + IntToStr(fDescriptor.Primary.FileStructureVersion) + 'd');
  end;
end;

function TPrimaryVolumeDescriptor.GetString(AIndex: Integer): string;
begin
  case AIndex of
    0 : Result := fDescriptor.Primary.SystemIdentifier;
    1 : Result := fDescriptor.Primary.VolumeIdentifier;
    2 : Result := fDescriptor.Primary.VolumeSetIdentifier;
    3 : Result := fDescriptor.Primary.PublisherIdentifier;
    4 : Result := fDescriptor.Primary.DataPreparerIdentifier;
    5 : Result := fDescriptor.Primary.ApplicationIdentifier;
    6 : Result := fDescriptor.Primary.CopyrightFileIdentifier;
    7 : Result := fDescriptor.Primary.AbstractFileIdentifier;
    8 : Result := fDescriptor.Primary.BibliographicFileIdentifier;
  end;
end;

procedure TPrimaryVolumeDescriptor.SetString(AIndex: Integer; const Value: string);
begin
  // Since StrPCopy() is the easiest method to fill in a array of char, we use it
  // here, but we have to care about the length of the record, because StrPCopy()
  // will copy the given string completly, overwriting the following fields...

  case AIndex of
    0 : StrPCopy(fDescriptor.Primary.SystemIdentifier,            Copy(Value, 1, Length(fDescriptor.Primary.SystemIdentifier)));
    1 : StrPCopy(fDescriptor.Primary.VolumeIdentifier,            Copy(Value, 1, Length(fDescriptor.Primary.VolumeIdentifier)));
    2 : StrPCopy(fDescriptor.Primary.VolumeSetIdentifier,         Copy(Value, 1, Length(fDescriptor.Primary.VolumeSetIdentifier)));
    3 : StrPCopy(fDescriptor.Primary.PublisherIdentifier,         Copy(Value, 1, Length(fDescriptor.Primary.PublisherIdentifier)));
    4 : StrPCopy(fDescriptor.Primary.DataPreparerIdentifier,      Copy(Value, 1, Length(fDescriptor.Primary.DataPreparerIdentifier)));
    5 : StrPCopy(fDescriptor.Primary.ApplicationIdentifier,       Copy(Value, 1, Length(fDescriptor.Primary.ApplicationIdentifier)));
    6 : StrPCopy(fDescriptor.Primary.CopyrightFileIdentifier,     Copy(Value, 1, Length(fDescriptor.Primary.CopyrightFileIdentifier)));
    7 : StrPCopy(fDescriptor.Primary.AbstractFileIdentifier,      Copy(Value, 1, Length(fDescriptor.Primary.AbstractFileIdentifier)));
    8 : StrPCopy(fDescriptor.Primary.BibliographicFileIdentifier, Copy(Value, 1, Length(fDescriptor.Primary.BibliographicFileIdentifier)));
  end;
end;

{ TSupplementaryVolumeDescriptor }

constructor TSupplementaryVolumeDescriptor.Create;
begin
  inherited;

  FillChar(fDescriptor, SizeOf(fDescriptor), 0);

  fDescriptor.DescriptorType := vdtSVD;

  with fDescriptor.Supplementary do
  begin
    StandardIdentifier      := 'CD001';
    VolumeDescriptorVersion := $01;
    VolumeSetSize           := BuildBothEndianWord(1);
    ApplicationIdentifier   := 'ISOLibrary ' + coISOLibVersion;
    FileStructureVersion    := $01;
  end;
end;

constructor TSupplementaryVolumeDescriptor.Create(const ASupplementaryVolumeDescriptor: TVolumeDescriptor);
begin
  inherited Create;

  if ( ASupplementaryVolumeDescriptor.DescriptorType <> vdtSVD ) then
    raise EVDWrongDescriptorType.Create('Descriptor type mismatch');

  fDescriptor := ASupplementaryVolumeDescriptor;
end;

destructor TSupplementaryVolumeDescriptor.Destroy;
begin
  inherited;
end;

procedure TSupplementaryVolumeDescriptor.Dump(AOutput: TStrings);
begin
  if Assigned(AOutput) then
  begin
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.StandardIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'StandardIdentifier = '                   + string(fDescriptor.Supplementary.StandardIdentifier));
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.VolumeDescriptorVersion) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeDescriptorVersion = '           + IntToHex( fDescriptor.Supplementary.VolumeDescriptorVersion,
                                                            SizeOf(fDescriptor.Supplementary.VolumeDescriptorVersion)*2) + 'h');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.VolumeFlags) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeFlags = '                        + IntToHex(fDescriptor.Supplementary.VolumeFlags, 2) + 'h '
                                                        + IntToStr(fDescriptor.Supplementary.VolumeFlags) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.SystemIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'SystemIdentifier = '                     + string(fDescriptor.Supplementary.SystemIdentifier));
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.VolumeIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeIdentifier = '                     + string(fDescriptor.Supplementary.VolumeIdentifier));
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.VolumeSpaceSize) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSpaceSize = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.VolumeSpaceSize.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.VolumeSpaceSize.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.VolumeSpaceSize.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.VolumeSpaceSize.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.VolumeSpaceSize.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.VolumeSpaceSize.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.VolumeSetSize) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSetSize = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.VolumeSetSize.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.VolumeSetSize.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.VolumeSetSize.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.VolumeSetSize.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.VolumeSetSize.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.VolumeSetSize.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.LogicalBlockSize) - Integer(@fDescriptor), 4) + 'h '
              + 'LogicalBlockSize = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.LogicalBlockSize.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.LogicalBlockSize.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LogicalBlockSize.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.LogicalBlockSize.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.LogicalBlockSize.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LogicalBlockSize.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.PathTableSize) - Integer(@fDescriptor), 4) + 'h '
              + 'PathTableSize = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.PathTableSize.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.PathTableSize.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.PathTableSize.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.PathTableSize.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.PathTableSize.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.PathTableSize.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.LocationOfTypeLPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfTypeLPathTable = '          + IntToHex( fDescriptor.Supplementary.LocationOfTypeLPathTable,
                                                            SizeOf(fDescriptor.Supplementary.LocationOfTypeLPathTable)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LocationOfTypeLPathTable) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfOptionalTypeLPathTable = '  + IntToHex( fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable,
                                                            SizeOf(fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.LocationOfTypeMPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfTypeMPathTable = '          + IntToHex( fDescriptor.Supplementary.LocationOfTypeMPathTable,
                                                            SizeOf(fDescriptor.Supplementary.LocationOfTypeMPathTable)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LocationOfTypeMPathTable) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable) - Integer(@fDescriptor), 4) + 'h '
              + 'LocationOfOptionalTypeMPathTable = '  + IntToHex( fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable,
                                                            SizeOf(fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable) + 'd');

    // Root Directory Entry
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.LengthOfDirectoryRecord) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: LengthOfDirectoryRecord = '       + IntToHex( fDescriptor.Supplementary.RootDirectory.LengthOfDirectoryRecord,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.LengthOfDirectoryRecord)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.LengthOfDirectoryRecord) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.ExtendedAttributeRecordLength) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: ExtendedAttributeRecordLength = ' + IntToHex( fDescriptor.Supplementary.RootDirectory.ExtendedAttributeRecordLength,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.ExtendedAttributeRecordLength)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.ExtendedAttributeRecordLength) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.LocationOfExtent) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: LocationOfExtent = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.RootDirectory.LocationOfExtent.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.LocationOfExtent.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.LocationOfExtent.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.RootDirectory.LocationOfExtent.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.LocationOfExtent.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.LocationOfExtent.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.DataLength) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: DataLength = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.RootDirectory.DataLength.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.DataLength.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.DataLength.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.RootDirectory.DataLength.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.DataLength.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.DataLength.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.FileFlags) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: FileFlags = '                     + IntToHex( fDescriptor.Supplementary.RootDirectory.FileFlags,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.FileFlags)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.FileFlags ) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.FileUnitSize) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: FileUnitSize = '                  + IntToHex( fDescriptor.Supplementary.RootDirectory.FileUnitSize,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.FileUnitSize)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.FileUnitSize) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.InterleaveGapSize) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: InterleaveGapSize = '             + IntToHex( fDescriptor.Supplementary.RootDirectory.InterleaveGapSize,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.InterleaveGapSize)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.InterleaveGapSize) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: VolumeSequenceNumber = '
              + 'Intel: '                              + IntToHex( fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.LittleEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.LittleEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.LittleEndian) + 'd '
              + 'Motorola: '                           + IntToHex( fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.BigEndian,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.BigEndian)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.VolumeSequenceNumber.BigEndian) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.LengthOfFileIdentifier) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: LengthOfFileIdentifier = '        + IntToHex( fDescriptor.Supplementary.RootDirectory.LengthOfFileIdentifier,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.LengthOfFileIdentifier)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.LengthOfFileIdentifier) + 'd');
    AOutput.Add(                                 IntToHex(Integer(@fDescriptor.Supplementary.RootDirectory.FileIdentifier) - Integer(@fDescriptor.Supplementary.RootDirectory), 4) + 'h '
              + 'RD: FileIdentifier = '                + IntToHex( fDescriptor.Supplementary.RootDirectory.FileIdentifier,
                                                            SizeOf(fDescriptor.Supplementary.RootDirectory.FileIdentifier)*2) + 'h '
                                                       + IntToStr( fDescriptor.Supplementary.RootDirectory.FileIdentifier) + 'd');

    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.VolumeSetIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeSetIdentifier = '                        + string(fDescriptor.Supplementary.VolumeSetIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.PublisherIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'PublisherIdentifier = '                        + string(fDescriptor.Supplementary.PublisherIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.DataPreparerIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'DataPreparerIdentifier = '                     + string(fDescriptor.Supplementary.DataPreparerIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.ApplicationIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'ApplicationIdentifier = '                      + string(fDescriptor.Supplementary.ApplicationIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.CopyrightFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'CopyrightFileIdentifier = '                    + string(fDescriptor.Supplementary.CopyrightFileIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.AbstractFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'AbstractFileIdentifier = '                     + string(fDescriptor.Supplementary.AbstractFileIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.BibliographicFileIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'BibliographicFileIdentifier = '                + string(fDescriptor.Supplementary.BibliographicFileIdentifier));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.VolumeCreationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeCreationDateAndTime = '     + VolumeDateTimeToStr(fDescriptor.Supplementary.VolumeCreationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.VolumeModificationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeModificationDateAndTime = ' + VolumeDateTimeToStr(fDescriptor.Supplementary.VolumeModificationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.VolumeExpirationDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'VolumeExpirationDateAndTime = '   + VolumeDateTimeToStr(fDescriptor.Supplementary.VolumeExpirationDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.VolumeEffectiveDateAndTime) - Integer(@fDescriptor), 4) + 'h '
              + 'h VolumeEffectiveDateAndTime = '  + VolumeDateTimeToStr(fDescriptor.Supplementary.VolumeEffectiveDateAndTime));
    AOutput.Add(                                       IntToHex(Integer(@fDescriptor.Supplementary.FileStructureVersion) - Integer(@fDescriptor), 4) + 'h '
              + 'FileStructureVersion = '                     + IntToHex(fDescriptor.Supplementary.FileStructureVersion, 2) + 'h '
                                                              + IntToStr(fDescriptor.Supplementary.FileStructureVersion) + 'd');
  end;
end;

function TSupplementaryVolumeDescriptor.GetString(AIndex: Integer): string;
begin
  case AIndex of
    0 : Result := fDescriptor.Supplementary.SystemIdentifier;
    1 : Result := fDescriptor.Supplementary.VolumeIdentifier;
    2 : Result := fDescriptor.Supplementary.VolumeSetIdentifier;
    3 : Result := fDescriptor.Supplementary.PublisherIdentifier;
    4 : Result := fDescriptor.Supplementary.DataPreparerIdentifier;
    5 : Result := fDescriptor.Supplementary.ApplicationIdentifier;
    6 : Result := fDescriptor.Supplementary.CopyrightFileIdentifier;
    7 : Result := fDescriptor.Supplementary.AbstractFileIdentifier;
    8 : Result := fDescriptor.Supplementary.BibliographicFileIdentifier;
  end;
end;

procedure TSupplementaryVolumeDescriptor.SetString(AIndex: Integer; const Value: string);
begin
  // Since StrPCopy() is the easiest method to fill in a array of char, we use it
  // here, but we have to care about the length of the record, because StrPCopy()
  // will copy the given string completly, overwriting the following fields...

  case AIndex of
    0 : StrPCopy(fDescriptor.Supplementary.SystemIdentifier,            Copy(Value, 1, Length(fDescriptor.Supplementary.SystemIdentifier)));
    1 : StrPCopy(fDescriptor.Supplementary.VolumeIdentifier,            Copy(Value, 1, Length(fDescriptor.Supplementary.VolumeIdentifier)));
    2 : StrPCopy(fDescriptor.Supplementary.VolumeSetIdentifier,         Copy(Value, 1, Length(fDescriptor.Supplementary.VolumeSetIdentifier)));
    3 : StrPCopy(fDescriptor.Supplementary.PublisherIdentifier,         Copy(Value, 1, Length(fDescriptor.Supplementary.PublisherIdentifier)));
    4 : StrPCopy(fDescriptor.Supplementary.DataPreparerIdentifier,      Copy(Value, 1, Length(fDescriptor.Supplementary.DataPreparerIdentifier)));
    5 : StrPCopy(fDescriptor.Supplementary.ApplicationIdentifier,       Copy(Value, 1, Length(fDescriptor.Supplementary.ApplicationIdentifier)));
    6 : StrPCopy(fDescriptor.Supplementary.CopyrightFileIdentifier,     Copy(Value, 1, Length(fDescriptor.Supplementary.CopyrightFileIdentifier)));
    7 : StrPCopy(fDescriptor.Supplementary.AbstractFileIdentifier,      Copy(Value, 1, Length(fDescriptor.Supplementary.AbstractFileIdentifier)));
    8 : StrPCopy(fDescriptor.Supplementary.BibliographicFileIdentifier, Copy(Value, 1, Length(fDescriptor.Supplementary.BibliographicFileIdentifier)));
  end;
end;

{ TBootRecordVolumeDescriptor }

constructor TBootRecordVolumeDescriptor.Create;
begin
  inherited;

  FillChar(fDescriptor, SizeOf(fDescriptor), 0);

  fDescriptor.DescriptorType := vdtBR;

  with fDescriptor.BootRecord do
  begin
    StandardIdentifier      := 'CD001';
    VersionOfDescriptor     := $01;
  end;
end;

constructor TBootRecordVolumeDescriptor.Create(const ABootRecordVolumeDescriptor: TVolumeDescriptor);
begin
  inherited Create;

  if ( ABootRecordVolumeDescriptor.DescriptorType <> vdtBR ) then
    raise EVDWrongDescriptorType.Create('Descriptor type mismatch');

  fDescriptor := ABootRecordVolumeDescriptor;
end;

destructor TBootRecordVolumeDescriptor.Destroy;
begin
  inherited;
end;

procedure TBootRecordVolumeDescriptor.Dump(AOutput: TStrings);
begin
  if Assigned(AOutput) then
  begin
    AOutput.Add(                    IntToHex(Integer(@fDescriptor.BootRecord.StandardIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'StandardIdentifier = '      + string(fDescriptor.BootRecord.StandardIdentifier));
    AOutput.Add(                    IntToHex(Integer(@fDescriptor.BootRecord.VersionOfDescriptor) - Integer(@fDescriptor), 4) + 'h '
              + 'VersionOfDescriptor = '  + IntToHex( fDescriptor.BootRecord.VersionOfDescriptor,
                                               SizeOf(fDescriptor.BootRecord.VersionOfDescriptor)*2) + 'h');
    AOutput.Add(                    IntToHex(Integer(@fDescriptor.BootRecord.BootSystemIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'BootSystemIdentifier = '    + string(fDescriptor.BootRecord.BootSystemIdentifier));
    AOutput.Add(                    IntToHex(Integer(@fDescriptor.BootRecord.BootIdentifier) - Integer(@fDescriptor), 4) + 'h '
              + 'BootIdentifier = '          + string(fDescriptor.BootRecord.BootIdentifier));
    AOutput.Add(                    IntToHex(Integer(@fDescriptor.BootRecord.BootCatalogPointer) - Integer(@fDescriptor), 4) + 'h '
              + 'BootCatalogPointer = '   + IntToHex( fDescriptor.BootRecord.BootCatalogPointer,
                                               SizeOf(fDescriptor.BootRecord.BootCatalogPointer)*2) + 'h '
              +                             IntToStr( fDescriptor.BootRecord.BootCatalogPointer) + 'd');
  end;
end;

function TBootRecordVolumeDescriptor.GetString(AIndex: Integer): string;
begin
  case AIndex of
    0 : Result := fDescriptor.BootRecord.BootSystemIdentifier;
    1 : Result := fDescriptor.BootRecord.BootIdentifier;
  end;
end;

procedure TBootRecordVolumeDescriptor.SetString(AIndex: Integer; const Value: string);
begin
  // Since StrPCopy() is the easiest method to fill in a array of char, we use it
  // here, but we have to care about the length of the record, because StrPCopy()
  // will copy the given string completly, overwriting the following fields...

  case AIndex of
    0 : StrPCopy(fDescriptor.BootRecord.BootSystemIdentifier, Copy(Value, 1, Length(fDescriptor.BootRecord.BootSystemIdentifier)));
    1 : StrPCopy(fDescriptor.BootRecord.BootIdentifier,       Copy(Value, 1, Length(fDescriptor.BootRecord.BootIdentifier)));
  end;
end;

end.

//  Log List
//
// $Log: VolumeDescriptors.pas,v $
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//
//

