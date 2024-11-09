//
//  TISOLib - Volume Descriptors
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: DataTree.pas,v 1.4 2004/06/15 15:32:32 muetze1 Exp $
//

unit DataTree;

interface

uses
  SysUtils,       // for FreeAndNil
  Classes,
  Types,
  Contnrs,        // for TObjectList
  ISOStructs,     // for TDirectoryRecord
  ISOException,   // for EISOLibContainerException
  {*}ISOToolBox;

type
  TDataTree  = class;  // forward declaration
  TFileEntry = class;  // forward declaration

  TDataSourceFlag = (dsfFromImage, dsfFromLocal, dsfOldSession);
  TEntryFlags     = (efNone, efAdded, efDeleted, efModified);
  TDirectoryEntry = class
  private
    function GetDirCount: Integer;
    function GetFileCount: Integer;
    function GetDirEntry(Index: Integer): TDirectoryEntry;
    function GetFileEntry(Index: Integer): TFileEntry;

  protected
    // management
    fDataTree    : TDataTree;
    fParent      : TDirectoryEntry;
    fDirectories : TObjectList;
    fFiles       : TObjectList;

    // handling
    fSource      : TDataSourceFlag;
    fFlags       : TEntryFlags;

    // ISO
    fISOData     : TDirectoryRecord;

    // helper
    fName        : AnsiString;

    function AddFile(AFileEntry: TFileEntry): Integer;
    function DelFile(AFileEntry: TFileEntry): Boolean;
    function AddDirectory(ADirEntry: TDirectoryEntry): Integer;
    function DelDirectory(ADirEntry: TDirectoryEntry): Boolean;

  public
    constructor Create(ADataTree: TDataTree; AParentDir: TDirectoryEntry; ASource: TDataSourceFlag); virtual;
    destructor  Destroy; override;

    procedure MoveDirTo(ANewDirectory: TDirectoryEntry);

    property Files[Index: Integer]: TFileEntry            read GetFileEntry;
    property Directories[Index: Integer]: TDirectoryEntry read GetDirEntry;

  public{published}
    property FileCount      : Integer          read GetFileCount;
    property DirectoryCount : Integer          read GetDirCount;
    property Parent         : TDirectoryEntry  read fParent;
    property Name           : AnsiString       read fName    write fName;
    property ISOData        : TDirectoryRecord read fISOData write fISOData;
    property SourceOfData   : TDataSourceFlag  read fSource;
    property Flags          : TEntryFlags      read fFlags;
  end;

  TFileEntry = class
  private
    function GetFullPath: AnsiString;

  protected
    // management
    fDirectory   : TDirectoryEntry;
    fName        : AnsiString;

    // handling
    fSource      : TDataSourceFlag;
    fFlags       : TEntryFlags;

    // ISO
    fISOData     : TDirectoryRecord;

    // local filesystem
    fSourceFile  : string; // or TFileName

  public
    constructor Create(ADirectoryEntry: TDirectoryEntry; ASource: TDataSourceFlag); virtual;
    destructor  Destroy; override;

    procedure MoveTo(ANewDirectoryEntry: TDirectoryEntry);

    // only valid, if SourceOfData = dsfFromLocal
    procedure FillISOData;

  public{published}
    property Name           : AnsiString       read fName       write fName;
    property Path           : AnsiString       read GetFullPath;

    // ISO Data
    property ISOData        : TDirectoryRecord read fISOData    write fISOData;

    property SourceOfData   : TDataSourceFlag  read fSource;
    property Flags          : TEntryFlags      read fFlags;

    property SourceFileName : string           read fSourceFile write fSourceFile;
  end;

  TDataTree = class
  protected
    fRootDir : TDirectoryEntry;
  public
    constructor Create; virtual;
    destructor  Destroy; override;
  public{published}
    property RootDirectory : TDirectoryEntry read fRootDir;
  end;

implementation

{ TFileEntry }

constructor TFileEntry.Create(ADirectoryEntry: TDirectoryEntry; ASource: TDataSourceFlag);
begin
  inherited Create;

  fSource     := ASource;
  fSourceFile := '';

  fDirectory  := ADirectoryEntry;
  fDirectory.AddFile(Self);

  fFlags      := efNone;
end;

destructor TFileEntry.Destroy;
begin
  inherited;
end;

procedure TFileEntry.FillISOData;
begin
  if ( fSource <> dsfFromLocal ) then
    raise EISOLibImageException.Create('not a local file entry, can not fill ISO structure...');

  fName := AnsiString(ExtractFileName(fSourceFile));

  with fISOData do
  begin
    DataLength.LittleEndian       := RetrieveFileSize(fSourceFile);
    DataLength.BigEndian          := SwapDWord(DataLength.LittleEndian);
//    RecordingDateAndTime          : TDirectoryDateTime;

//    LocationOfExtent              : TBothEndianDWord;
//    VolumeSequenceNumber          : TBothEndianWord;

//    ExtendedAttributeRecordLength := 0; // ???

//    LengthOfDirectoryRecord       := 0; // think of padding bytes !

//    FileFlags                     : Byte;
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

//    FileUnitSize                  := 0; // ???
//    InterleaveGapSize             := 0; // ???
    LengthOfFileIdentifier        := Length(fName);
      // padding bytes
  end;
end;

function TFileEntry.GetFullPath: AnsiString;
var
  ADir : TDirectoryEntry;
begin
  ADir := fDirectory;
  Result := '';

  while ( Assigned(ADir) ) do
  begin
    Result := ADir.Name + '/' + Result;
    ADir   := ADir.Parent;
  end;
end;

procedure TFileEntry.MoveTo(ANewDirectoryEntry: TDirectoryEntry);
begin
  fDirectory.DelFile(Self);
  fDirectory := ANewDirectoryEntry;
  ANewDirectoryEntry.AddFile(Self);
end;

{ TDirectoryEntry }

function TDirectoryEntry.AddDirectory(ADirEntry: TDirectoryEntry): Integer;
begin
  if ( fDirectories.IndexOf(ADirEntry) > -1 ) then
    raise EISOLibContainerException.Create('directory entry already added');
  if ( Assigned(ADirEntry.fParent) ) and ( ADirEntry.fParent <> Self ) then
    raise EISOLibContainerException.Create('directory entry already added - use MoveDirTo() instead!');

  Assert(ADirEntry.fParent = Self, 'Assertion: directory entry on AddDirectory() has different parent directory');
  //ADirEntry.fParent := Self; // normal case: it is already assign

  Result := fDirectories.Add(ADirEntry);
end;

function TDirectoryEntry.AddFile(AFileEntry: TFileEntry): Integer;
begin
  if ( fFiles.IndexOf(AFileEntry) > -1 ) then
    raise EISOLibContainerException.Create('file entry already added');
  if ( Assigned(AFileEntry.fDirectory) ) and ( AFileEntry.fDirectory <> Self ) then
    raise EISOLibContainerException.Create('file entry already listed in different directory');

  Assert(AFileEntry.fDirectory <> nil, 'Assertion: file entry on AddFile() has no directory assigned');
  //  AFileEntry.fDirectory := Self; // normal case: it is already assign

  Result := fFiles.Add(AFileEntry);
end;

constructor TDirectoryEntry.Create(ADataTree: TDataTree; AParentDir: TDirectoryEntry; ASource: TDataSourceFlag);
begin
  inherited Create;

  fDataTree    := ADataTree;
  fParent      := AParentDir;
  fFiles       := TObjectList.Create(True);
  fDirectories := TObjectList.Create(True);

  if Assigned(fParent) then
    fParent.AddDirectory(Self);

  fSource      := ASource;
  fFlags       := efNone;
end;

function TDirectoryEntry.DelDirectory(ADirEntry: TDirectoryEntry): Boolean;
begin
  Result := False;

  if ( fDirectories.IndexOf(ADirEntry) = -1 ) then
    Exit;

  fDirectories.Extract(ADirEntry);
  ADirEntry.fParent := nil;

  Result := True;
end;

function TDirectoryEntry.DelFile(AFileEntry: TFileEntry): Boolean;
begin
  Result := False;

  if ( fFiles.IndexOf(AFileEntry) = -1 ) then
    Exit;

  fFiles.Extract(AFileEntry);
  AFileEntry.fDirectory := nil;

  Result := True;
end;

destructor TDirectoryEntry.Destroy;
begin
  FreeAndNil(fFiles);
  FreeAndNil(fDirectories);

  inherited;
end;

function TDirectoryEntry.GetDirCount: Integer;
begin
  if ( Assigned(fDirectories) ) then
    Result := fDirectories.Count
  else
    Result := 0;
end;

function TDirectoryEntry.GetDirEntry(Index: Integer): TDirectoryEntry;
begin
  Result := fDirectories[Index] as TDirectoryEntry;
end;

function TDirectoryEntry.GetFileCount: Integer;
begin
  if ( Assigned(fFiles) ) then
    Result := fFiles.Count
  else
    Result := 0;
end;

function TDirectoryEntry.GetFileEntry(Index: Integer): TFileEntry;
begin
  Result := fFiles[Index] as TFileEntry;
end;

procedure TDirectoryEntry.MoveDirTo(ANewDirectory: TDirectoryEntry);
begin
  if ( Self = ANewDirectory ) then
    raise EISOLibContainerException.Create('can not move directory to itself');
  if ( fParent = ANewDirectory ) then
  begin
    Assert(False, 'senseless move of directory');
    Exit; // this we have already
  end;

  fParent.DelDirectory(Self); // hoffentlich kein Absturz hier, da DelDirectory Parent auf Nil setzt
  fParent := ANewDirectory;
  ANewDirectory.AddDirectory(Self);
end;

{ TDataTree }

constructor TDataTree.Create;
begin
  inherited;
  fRootDir := TDirectoryEntry.Create(Self, nil, dsfFromImage);  // Root hat keinen Parent
end;

destructor TDataTree.Destroy;
begin
  FreeAndNil(fRootDir);
  inherited;
end;

end.

//  Log List
//
// $Log: DataTree.pas,v $
// Revision 1.4  2004/06/15 15:32:32  muetze1
// bug fix for GetFullPath
//
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//
//
//

