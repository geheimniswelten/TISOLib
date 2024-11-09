//
//  TISOLib
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ImageFileHandler.pas,v 1.4 2004/06/15 14:45:31 muetze1 Exp $
//

unit ImageFileHandler;

interface

uses
  SysUtils, // for FileExists
  Classes,
  ISOException;

type
  EISOImageHandlerException = class(EISOLibException);

  // Yellow Book Format
  //
  //   ybfAuto   = auto detect
  //   ybfMode1  = 2048 byte user data
  //   ybfMode2  = 2336 byte user data
  //
  TISOYellowBookFormat = (ybfAuto, ybfMode1, ybfMode2);

  // Image Format
  //
  //   ifCompleteSectors  = with SYNC, Header, etc
  //   ifOnlyData         = only the user data
  //
  TISOImageFormat = (ifAuto, ifCompleteSectors, ifOnlyData);

  TImageFileHandler = class
  private
    fYellowBookFormat : TISOYellowBookFormat;
    fImageFormat      : TISOImageFormat;

    fImageOffset      : Cardinal; // e.g. used by Nero Images
    fFileStream       : TFileStream;

    fCurrentSector    : Cardinal;

  protected
    procedure DetectImageType; virtual;
    function  CalcSectorOffset(ASector: Cardinal): Integer; virtual;
    function  CalcUserDataOffset: Integer; virtual;
    function  GetSectorDataSize: Cardinal; virtual;

  public
    constructor Create(const AFileName: string; AImageFormat: TISOImageFormat); overload; virtual;
    constructor Create(const ANewFileName: string; AYellowBookFormat: TISOYellowBookFormat; AImageFormat: TISOImageFormat); overload; virtual;
    destructor  Destroy; override;

    function SeekSector(ASector: Cardinal; AGrow: Boolean=True): Boolean; virtual;

    function ReadSector_Data(var ABuffer; ABufferSize: Integer=-1): Boolean; virtual;
    function ReadSector_Raw (var ABuffer; ABufferSize: Integer=-1): Boolean; virtual;

  published
    property YellowBookFormat : TISOYellowBookFormat read fYellowBookFormat;
    property ImageFormat      : TISOImageFormat      read fImageFormat;
    property ImageOffset      : Cardinal             read fImageOffset;
    property SectorDataSize   : Cardinal             read GetSectorDataSize;
    property CurrentSector    : Cardinal             read fCurrentSector;

    property Stream           : TFileStream          read fFileStream;
  end;

implementation

{ TImageFileHandler }

constructor TImageFileHandler.Create(const AFileName: string; AImageFormat: TISOImageFormat);
begin
  inherited Create;

  if ( not FileExists(AFileName) ) then
    raise EISOImageHandlerException.Create('image file not found');

  fFileStream := TFileStream.Create(AFileName, fmOpenReadWrite or fmShareDenyNone);

  DetectImageType;

  SeekSector(fCurrentSector);
end;

constructor TImageFileHandler.Create(const ANewFileName: string; AYellowBookFormat: TISOYellowBookFormat; AImageFormat: TISOImageFormat);
begin
  inherited Create;

  if ( AYellowBookFormat = ybfAuto ) then
    raise EISOImageHandlerException.Create('yellow book format has to be defined!');

  if ( AImageFormat = ifAuto ) then
    raise EISOImageHandlerException.Create('image format has to be defined!');

  fYellowBookFormat  := AYellowBookFormat;
  fImageFormat       := AImageFormat;
  fImageOffset       := 0;

  fFileStream := TFileStream.Create(ANewFileName, fmCreate or fmShareDenyNone);

  SeekSector(fCurrentSector);
end;

destructor TImageFileHandler.Destroy;
begin
  FreeAndNil(fFileStream);
  inherited;
end;

function TImageFileHandler.CalcUserDataOffset: Integer;
begin
  case fImageFormat of
    ifCompleteSectors : Result := 16; // 12 bytes SYNC, 4 byte Header
    ifOnlyData        : Result := 0;
    ifAuto            : raise EISOImageHandlerException.Create('can not calculate sector offset with auto values!');
    else                raise EISOImageHandlerException.Create('TImageFileHandler.CalcUserDataOffset(): Implementation error!');
  end;
end;

function TImageFileHandler.CalcSectorOffset(ASector: Cardinal): Integer;
begin
  case fImageFormat of
    ifCompleteSectors : Result := fImageOffset + ASector * 2352;
    ifOnlyData        :
      begin
        case fYellowBookFormat of
          ybfMode1 : Result := fImageOffset + ASector * 2048;
          ybfMode2 : Result := fImageOffset + ASector * 2336;
          ybfAuto  : raise EISOImageHandlerException.Create('can not calculate sector with auto settings');
        else
          raise EISOImageHandlerException.Create('TImageFileHandler.CalcSectorOffset(): Implementation error!');
        end;
      end;
    ifAuto : raise EISOImageHandlerException.Create('can not calculate sector with auto settings');
    else     raise EISOImageHandlerException.Create('TImageFileHandler.CalcSectorOffset(): Implementation error!');
  end;
end;

procedure TImageFileHandler.DetectImageType;
type
  TCheckBuf = packed record
    DeskID : Byte;
    StdID  : array[0..4] of Char;
  end;
  TRawCheckBuf = packed record
    SYNC   : array[0..11] of Byte;
    Header_SectMin,
    Header_SectSec,
    Header_SectNo,
    Header_Mode  : Byte;
    Deskriptor   : TCheckBuf;
  end;
var
  Buff    : TCheckBuf;
  RawBuff : TRawCheckBuf;
  Tries   : Boolean;
begin
  fYellowBookFormat := ybfAuto;
  fImageFormat      := ifAuto;
  fImageOffset      := 0;

  if ( Assigned(fFileStream) ) and ( fFileStream.Size > 16*2048 ) then
  begin
    for Tries := False to True do
    begin
      if ( Tries ) then // ok, 2nd run, last try: nero .nrg image file
        fImageOffset := 307200;

      fFileStream.Position := fImageOffset + 16 * 2048;
      fFileStream.ReadBuffer(Buff, SizeOf(Buff));

      if ( string(Buff.StdID) = 'CD001' ) then
      begin
        fImageFormat      := ifOnlyData;
        fYellowBookFormat := ybfMode1;

        Break;
      end;

      fFileStream.Position := fImageOffset + 16 * 2336;
      fFileStream.ReadBuffer(Buff, SizeOf(Buff));

      if ( string(Buff.StdID) = 'CD001' ) then
      begin
        fImageFormat      := ifOnlyData;
        fYellowBookFormat := ybfMode2;

        Break;
      end;

      fFileStream.Position := fImageOffset + 16 * 2352;
      fFileStream.ReadBuffer(RawBuff, SizeOf(RawBuff));

      if ( string(RawBuff.Deskriptor.StdID) = 'CD001' ) then
      begin
        fImageFormat := ifCompleteSectors;

        if ( RawBuff.Header_Mode = 1 ) then
          fYellowBookFormat := ybfMode1
        else if ( RawBuff.Header_Mode = 2 ) then
          fYellowBookFormat := ybfMode2
        else
          raise EISOImageHandlerException.Create('unkown Yellow Book mode!');

        Break;
      end;
    end;
  end;

  if ( fImageFormat = ifAuto ) or ( fYellowBookFormat = ybfAuto ) then
    raise EISOImageHandlerException.Create('unkown image format!');
end;

function TImageFileHandler.SeekSector(ASector: Cardinal; AGrow: Boolean): Boolean;
var
  lFPos : Integer;
begin
  Result := False;

  if ( Assigned(fFileStream) ) then
  begin
    lFPos := CalcSectorOffset(ASector);

    if ( (lFPos+2048) > fFileStream.Size ) and ( not AGrow ) then
      Exit;

    fFileStream.Position := lFPos;

    fCurrentSector := ASector;
  end;
end;

function TImageFileHandler.ReadSector_Data(var ABuffer; ABufferSize: Integer=-1): Boolean;
var
  lDataOffset : Integer;
begin
  Result := False;

  if ( Assigned(fFileStream) ) then
  begin
    lDataOffset := CalcUserDataOffset;

    fFileStream.Seek(lDataOffset, soFromCurrent);

    if ( ABufferSize > -1 ) and ( Cardinal(ABufferSize) < GetSectorDataSize ) then
      raise EISOImageHandlerException.Create('TImageFileHandler.ReadSector_Data(): buffer overflow protection');

    fFileStream.ReadBuffer(ABuffer, GetSectorDataSize);

    SeekSector(fCurrentSector+1);

    Result := True;
  end;
end;

function TImageFileHandler.ReadSector_Raw(var ABuffer; ABufferSize: Integer=-1): Boolean;
begin
  Result := False;

  if ( Assigned(fFileStream) ) then
  begin
    if ( ABufferSize > -1 ) and ( ABufferSize < 2352 ) then
      raise EISOImageHandlerException.Create('TImageFileHandler.ReadSector_Raw(): buffer overflow protection');

    fFileStream.ReadBuffer(ABuffer, 2352);

    Result := True;
  end;
end;

function TImageFileHandler.GetSectorDataSize: Cardinal;
begin
  case fYellowBookFormat of
    ybfMode1 : Result := 2048;
    ybfMode2 : Result := 2336;
    else       raise EISOImageHandlerException.Create('can not figure out sector data size on auto type');
  end;
end;

end.

//  Log List
//
// $Log: ImageFileHandler.pas,v $
// Revision 1.4  2004/06/15 14:45:31  muetze1
// removed warnings and old comments
//
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//
//

