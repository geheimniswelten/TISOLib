//
//  TISOImage
//
//  refer to http://isolib.xenome.info/
//

//
//  Bei dem Nero Image File .NRG müsste man mal schauen, wo er denn nun was für
//  komische Zusatzdaten hinschreibt...
//

//
// $Id: ISOImage.pas,v 1.5 2004/06/15 15:33:29 muetze1 Exp $
//

unit ISOImage;

interface

uses
  SysUtils,           // for Exception
  ComCtrls,           // for TTreeView
  Classes,            // for TStrings
  Math,               // for Min
  ISOStructs,
  ISOException,
  ImageFileHandler,
  DataTree,
  VolumeDescriptors,
  ISOToolBox;  // IntToMB

type
  TISOImage = class
  private
    // Log Stream
    fLog      : TStrings;
    fFileName : string;

    // debug functions:
    procedure DumpData(ALength: Cardinal);

  protected
    fImage    : TImageFileHandler;
    fBRClass  : TBootRecordVolumeDescriptor;
    fPVDClass : TPrimaryVolumeDescriptor;
    fSVDClass : TSupplementaryVolumeDescriptor;
    fTree     : TDataTree;

    procedure Log(const AFunction, AMessage: string);

    function ParseDirectory(AUsePrimaryVD: Boolean=True): Boolean;
    function ParseDirectorySub(AParentDir: TDirectoryEntry; const AFileName: string; var ADirectoryEntry: PDirectoryRecord): Boolean;

  public
    constructor Create(const AFileName: string; ALog: TStrings=nil); virtual;
    destructor  Destroy; override;

    function OpenImage: Boolean;
    function ParsePathTable(ATreeView: TTreeView=nil): Boolean;
    function ExtractFile(const AFileEntry: TFileEntry; const AFileName: string): Boolean;
    function CloseImage: Boolean;

  published
    property Filename  : string    read fFileName;
    property Structure : TDataTree read fTree;
  end;

implementation

const
  UNIT_ID : string = '$Id: ISOImage.pas,v 1.5 2004/06/15 15:33:29 muetze1 Exp $';

{ TISOLib }

constructor TISOImage.Create(const AFileName: string; ALog: TStrings);
begin
  inherited Create;

  fLog           := ALog;
  fFileName      := AFileName;
  fImage         := nil;
  fPVDClass      := nil;
  fSVDClass      := nil;
  fBRClass       := nil;
  fTree          := TDataTree.Create;
end;

destructor TISOImage.Destroy;
begin
  FreeAndNil(fTree);
  FreeAndNil(fImage);
  FreeAndNil(fPVDClass);
  FreeAndNil(fSVDClass);
  FreeAndNil(fBRClass);
  inherited;
end;

function TISOImage.CloseImage: Boolean;
begin
  fFileName := '';
  FreeAndNil(fImage);
  FreeAndNil(fPVDClass);
  FreeAndNil(fSVDClass);
  FreeAndNil(fBRClass);
  FreeAndNil(fTree);
  Result := True;
end;

procedure TISOImage.DumpData(ALength: Cardinal);
var
  OrgPtr,
  Buffer   : PByte;
  Row      : Cardinal;
  Col      : Word;
  CharStr,
  DumpStr  : string;
begin
  GetMem(Buffer, ALength);
  OrgPtr := Buffer;
  try
    fImage.Stream.ReadBuffer(Buffer^, ALength);

    for Row := 0 to ((ALength-1) div 16) do
    begin
      DumpStr := IntToHex(Cardinal(fImage.Stream.Position) - ALength + Row*16, 8) + 'h | ';
      CharStr := '';
      for Col := 0 to Min(16, ALength - (Row+1)*16) do
      begin
        DumpStr := DumpStr + IntToHex(Buffer^, 2) + ' ';
        if ( Buffer^ > 32 ) then
          CharStr := CharStr + Chr(Buffer^)
        else
          CharStr := CharStr + ' ';
        Inc(Buffer);
      end;
      DumpStr := DumpStr + StringOfChar(' ', 61-Length(DumpStr)) + '| ' + CharStr;
      Log('Dump', DumpStr);
    end;
  finally
    FreeMem(OrgPtr, ALength);
  end;
end;

function TISOImage.ExtractFile(const AFileEntry: TFileEntry; const AFileName: string): Boolean;
var
  lFStream : TFileStream;
  lFSize   : Int64;
  lBuffer  : Pointer;
begin
  Result := False;

  if Assigned(AFileEntry) then
  begin
    fImage.SeekSector(AFileEntry.ISOData.LocationOfExtent.LittleEndian);

    lFStream := TFileStream.Create(AFileName, fmCreate);
    lFSize   := AFileEntry.ISOData.DataLength.LittleEndian;
    GetMem(lBuffer, fImage.SectorDataSize);
    try
      while ( lFSize > 0 ) do
      begin
        fImage.ReadSector_Data(lBuffer^, fImage.SectorDataSize);
        lFStream.WriteBuffer(lBuffer^, Min(lFSize, fImage.SectorDataSize));
        Dec(lFSize, fImage.SectorDataSize);
      end;

      Result := True;
    finally
      lFStream.Free;
      FreeMem(lBuffer, fImage.SectorDataSize);
    end;
  end;
end;

procedure TISOImage.Log(const AFunction, AMessage: string);
begin
  if ( Assigned(fLog) ) then
    fLog.Add(AFunction + '(): ' + AMessage);
end;

function TISOImage.OpenImage: Boolean;
var
  VD : TVolumeDescriptor;
begin
  Result := False;

  if ( FileExists(fFileName) ) then
  begin
    fImage := TImageFileHandler.Create(fFileName, ifAuto);

    Log('OpenImage', 'file "' + fFileName + '" opened...');

      // die Sektor 0 bis Sektor 15 enthalten nur 0-Sektoren
    fImage.SeekSector(16);

    if ( fImage.ImageFormat = ifCompleteSectors ) then
      Log('OpenImage', 'image contains RAW data')
    else if ( fImage.ImageFormat = ifOnlyData ) then
      Log('OpenImage', 'image contains sector data');

    if ( fImage.YellowBookFormat = ybfMode1 ) then
      Log('OpenImage', 'image contains yellow book mode 1 data')
    else if ( fImage.YellowBookFormat = ybfMode2 ) then
      Log('OpenImage', 'image contains yellow book mode 2 data');

    Log('OpenImage', 'user data sector size is ' + IntToStr(fImage.SectorDataSize) + ' bytes');
    Log('OpenImage', 'image data offset in image file is ' + IntToStr(fImage.ImageOffset) + ' bytes');

    if ( fImage.SectorDataSize <> 2048 ) then
    begin
      Log('OpenImage', 'sorry, but sector size other than 2048 bytes are not yet supported...');
      Exit;
    end;

    repeat
      fImage.ReadSector_Data(VD, SizeOf(TVolumeDescriptor));

      case Byte(VD.DescriptorType) of
        vdtBR  : begin
                   Log('OpenImage', 'Boot Record Volume Descriptor found'); // Boot Record VD
                   fBRClass.Free;
                   fBRClass := TBootRecordVolumeDescriptor.Create(VD);
                   // fBRClass.Dump(fLog);
                 end;
        vdtPVD : begin
                   Log('OpenImage', 'Primary Volume Descriptor found');
                   fPVDClass.Free;
                   fPVDClass := TPrimaryVolumeDescriptor.Create(VD);
                   // fPVDClass.Dump(fLog);
                 end;
        vdtSVD : begin
                   Log('OpenImage', 'Supplementary Volume Descriptor found'); // Supplementary Volume Descriptor
                   fSVDClass.Free;
                   fSVDClass := TSupplementaryVolumeDescriptor.Create(VD);
                   // fSVDClass.Dump(fLog);
                 end;
      end;
    until ( VD.DescriptorType = vdtVDST );

    ParseDirectory;

    Result := True;
  end
  else
  begin
    Log('OpenImage', 'file "' + fFileName + '" not found');
    raise EISOLibImageException.Create('image file not found');
  end;
end;

function TISOImage.ParseDirectory(AUsePrimaryVD: Boolean): Boolean;
var
  DirRootSourceRec : TRootDirectoryRecord;
  EndSector   : Cardinal;
  DR          : PDirectoryRecord;
  FileName    : string;
  lWorkPtr,
  lBuffer     : PByte;
begin
  Result := False;

  if ( AUsePrimaryVD ) then
  begin
    Log('ParseDirectory', 'parsing directory using primary volume descriptor...');
    DirRootSourceRec := fPVDClass.Descriptor.Primary.RootDirectory;
  end
  else
  begin
    Log('ParseDirectory', 'parsing directory using supplementary volume descriptor...');
    if not Assigned(fSVDClass) then
      raise EISOLibImageException.Create('no supplementary volume descriptor found!');

    DirRootSourceRec := fSVDClass.Descriptor.Primary.RootDirectory;
  end;
  Log('ParseDirectory', 'directory sector ' + IntToStr(DirRootSourceRec.LocationOfExtent.LittleEndian));

  EndSector := DirRootSourceRec.LocationOfExtent.LittleEndian
             + ( DirRootSourceRec.DataLength.LittleEndian + fImage.SectorDataSize-1 ) div fImage.SectorDataSize;

  fImage.SeekSector(DirRootSourceRec.LocationOfExtent.LittleEndian);

  GetMem(lBuffer, fImage.SectorDataSize);
  try
    lWorkPtr := lBuffer;
    fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);

    while ( fImage.CurrentSector <= EndSector ) do
    begin
      if ( fImage.SectorDataSize - ( Cardinal(lWorkPtr) - Cardinal(lBuffer) )) < SizeOf(TDirectoryRecord) then
      begin
        lWorkPtr := lBuffer;
        fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
      end;

      New(DR);
      Move(lWorkPtr^, DR^, SizeOf(TDirectoryRecord));
      Inc(lWorkPtr, SizeOf(TDirectoryRecord));

      SetLength(FileName, DR.LengthOfFileIdentifier);
      Move(lWorkPtr^, FileName[1], DR.LengthOfFileIdentifier);
      Inc(lWorkPtr, DR.LengthOfFileIdentifier);

        // padding bytes
      if ( ( SizeOf(TDirectoryRecord) + DR.LengthOfFileIdentifier ) < DR.LengthOfDirectoryRecord ) then
        Inc(lWorkPtr, DR.LengthOfDirectoryRecord - SizeOf(TDirectoryRecord) - DR.LengthOfFileIdentifier);

      ParseDirectorySub(fTree.RootDirectory, FileName, DR);
    end;
  finally
    FreeMem(lBuffer, fImage.SectorDataSize);
  end;
end;

function TISOImage.ParseDirectorySub(AParentDir: TDirectoryEntry; const AFileName: string; var ADirectoryEntry: PDirectoryRecord): Boolean;
var
  EndSector   : Cardinal;
  OldPosition : Integer;
  ActDir      : TDirectoryEntry;
  FileEntry   : TFileEntry;
  DRFileName  : string;
  DR          : PDirectoryRecord;
  lWorkPtr,
  lBuffer     : PByte;
begin
  if ( ADirectoryEntry.FileFlags and $2 ) = $2 then // directory
  begin
    OldPosition := fImage.CurrentSector;

    if ( AFileName <> #0 ) and ( AFileName <> #1 ) then
    begin
      ActDir := TDirectoryEntry.Create(fTree, AParentDir, dsfFromImage);
      ActDir.Name    := AFileName;
      ActDir.ISOData := ADirectoryEntry^;

      fImage.SeekSector(ADirectoryEntry.LocationOfExtent.LittleEndian);

      EndSector := ADirectoryEntry.LocationOfExtent.LittleEndian
                 + ( ADirectoryEntry.DataLength.LittleEndian + fImage.SectorDataSize-1 ) div fImage.SectorDataSize;

      Dispose(ADirectoryEntry);
      ADirectoryEntry := nil;

      GetMem(lBuffer, fImage.SectorDataSize);
      Try
        lWorkPtr := lBuffer;
        fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);

        while ( fImage.CurrentSector <= EndSector ) do
        begin
          if ( fImage.SectorDataSize - ( Cardinal(lWorkPtr) - Cardinal(lBuffer) )) < SizeOf(TDirectoryRecord) then
          begin
            lWorkPtr := lBuffer;
            fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
          end;

          New(DR);
          Move(lWorkPtr^, DR^, SizeOf(TDirectoryRecord));
          Inc(lWorkPtr, SizeOf(TDirectoryRecord));

          SetLength(DRFileName, DR.LengthOfFileIdentifier);
          Move(lWorkPtr^, DRFileName[1], DR.LengthOfFileIdentifier);
          Inc(lWorkPtr, DR.LengthOfFileIdentifier);

            // padding bytes
          if ( ( SizeOf(TDirectoryRecord) + DR.LengthOfFileIdentifier ) < DR.LengthOfDirectoryRecord ) then
            Inc(lWorkPtr, DR.LengthOfDirectoryRecord - SizeOf(TDirectoryRecord) - DR.LengthOfFileIdentifier);

          ParseDirectorySub(ActDir, DRFileName, DR);
        end;
      finally
        FreeMem(lBuffer, fImage.SectorDataSize);
      end;
    end;

    fImage.SeekSector(OldPosition);
  end
  else
  begin
    if ( AFileName <> '' ) and ( ADirectoryEntry.DataLength.LittleEndian > 0 ) then
    begin
      FileEntry := TFileEntry.Create(AParentDir, dsfFromImage);
      FileEntry.Name    := AFileName;
      FileEntry.ISOData := ADirectoryEntry^;
    end;
  end;

  Result := True;
end;

function TISOImage.ParsePathTable(ATreeView: TTreeView): Boolean;
var
  PathTableEntry : TPathTableRecord;
  FileName       : string;
  SectorCount    : Cardinal;
  Node           : TTreeNode;
  PathTabelEntryNumber : Integer;
  lWorkPtr,
  lBuffer        : PByte;
  i              : Integer;

  function FindParent(AParentPathNumber: Integer): TTreeNode;
  begin
    Result := ATreeView.Items.GetFirstNode;

    while ( Integer(Result.Data) <> AParentPathNumber ) do
      Result := Result.GetNext;
  end;

begin
  Result := False;

  Log('ParsePathTable', 'path table first sector ' + IntToStr(fPVDClass.Descriptor.Primary.LocationOfTypeLPathTable));
  Log('ParsePathTable', 'path table length ' + IntToStr(fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian) + ' bytes');

  if ( Assigned(ATreeView) ) then
    ATreeView.Items.Clear;

  SectorCount := ( fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian
                 + fImage.SectorDataSize -1 ) div fImage.SectorDataSize;

  fImage.SeekSector(fPVDClass.Descriptor.Primary.LocationOfTypeLPathTable);

  GetMem(lBuffer, SectorCount * fImage.SectorDataSize);
  lWorkPtr := lBuffer;
  try
    PathTabelEntryNumber := 0;

    for i := 1 to SectorCount do
    begin
      fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
      Inc(lWorkPtr, fImage.SectorDataSize);
    end;

    lWorkPtr := lBuffer;

    repeat
      Move(lWorkPtr^, PathTableEntry, SizeOf(PathTableEntry));
      Inc(lWorkPtr, SizeOf(PathTableEntry));

      SetLength(FileName, PathTableEntry.LengthOfDirectoryIdentifier);
      Move(lWorkPtr^, FileName[1], PathTableEntry.LengthOfDirectoryIdentifier);
      Inc(lWorkPtr, PathTableEntry.LengthOfDirectoryIdentifier);

      if ( Odd(PathTableEntry.LengthOfDirectoryIdentifier) ) then
        Inc(lWorkPtr, 1);

      Inc(PathTabelEntryNumber);

      if ( PathTableEntry.LengthOfDirectoryIdentifier = 1 ) then
      begin
        if ( Assigned(ATreeView) ) and ( PathTabelEntryNumber = 1 ) then
        begin
          Node := ATreeView.Items.AddChild(nil, '/');
          Node.Data := Pointer(PathTabelEntryNumber);
        end;
      end
      else
      begin
        if ( Assigned(ATreeView) ) then
        begin
          Node := ATreeView.Items.AddChild(FindParent(PathTableEntry.ParentDirectoryNumber), FileName);
          Node.Data := Pointer(PathTabelEntryNumber);
        end;
      end;
    until ( (Cardinal(lWorkPtr) - Cardinal(lBuffer) ) >= fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian );
  finally
    FreeMem(lBuffer, SectorCount * fImage.SectorDataSize);
  end;
end;

end.

//  Log List
//
// $Log: ISOImage.pas,v $
// Revision 1.5  2004/06/15 15:33:29  muetze1
// renamed class to prevent later problems when creatin TISOLib
//
// Revision 1.4  2004/06/15 14:46:03  muetze1
// removed warnings and old comments
//
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//

