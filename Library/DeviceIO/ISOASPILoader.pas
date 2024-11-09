//
//  TISOLib - ASPI Loader
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ISOASPILoader.pas,v 1.3 2004/06/07 02:24:41 nalilord Exp $
//

unit ISOASPILoader;

interface

uses
  Windows,
  ISOSCSIStructs;

var
  WNASPI32_Loaded         : Boolean                 = False;
  SendASPI32Command       : TSendASPI32Command      = nil;
  GetASPI32SupportInfo    : TGetASPI32SupportInfo   = nil;
  GetASPI32Buffer         : TGetASPI32Buffer        = nil;
  FreeASPI32Buffer        : TFreeASPI32Buffer       = nil;
  TranslateASPI32Address  : TTranslateASPI32Address = nil;

const
  WNASPI32_Lib = 'wnaspi32.dll';

function InitializeASPI: Boolean;
function UnInitializeASPI: Boolean;

implementation

var
  WNASPI32_Instance : THandle = 0;

function InitializeASPI: Boolean;
begin
  Result          := False;
  WNASPI32_Loaded := False;

  WNASPI32_Instance := LoadLibrary(PChar(WNASPI32_Lib));
  if ( WNASPI32_Instance <> 0 ) then
  begin
    @SendASPI32Command      := GetProcAddress(WNASPI32_Instance, 'SendASPI32Command');
    @GetASPI32SupportInfo   := GetProcAddress(WNASPI32_Instance, 'GetASPI32SupportInfo');
    @GetASPI32Buffer        := GetProcAddress(WNASPI32_Instance, 'GetASPI32Buffer');
    @FreeASPI32Buffer       := GetProcAddress(WNASPI32_Instance, 'FreeASPI32Buffer');
    @TranslateASPI32Address := GetProcAddress(WNASPI32_Instance, 'TranslateASPI32Address');

    WNASPI32_Loaded := True;
    Result          := True;
  end;
end;

function UnInitializeASPI: Boolean;
begin
  Result := False;

  if WNASPI32_Loaded then
  begin
    WNASPI32_Loaded   := FreeLibrary(WNASPI32_Instance);
    WNASPI32_Instance := 0;

    @SendASPI32Command      := nil;
    @GetASPI32SupportInfo   := nil;
    @GetASPI32Buffer        := nil;
    @FreeASPI32Buffer       := nil;
    @TranslateASPI32Address := nil;

    Result := True;
  end;
end;

end.

//  Log List
//
// $Log: ISOASPILoader.pas,v $
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//

