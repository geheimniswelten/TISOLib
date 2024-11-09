//
//  TISOLib - Exception definitions
//
//  refer to http://isolib.xenome.info/
//

//
// $Id: ISOException.pas,v 1.3 2004/06/07 02:24:41 nalilord Exp $
//

unit ISOException;

interface

uses
  SysUtils;   // for Exception

type
  EISOLibException = class(Exception);
  EISOLibImageException = class(EISOLibException);
  EISOLibContainerException = class(EISOLibException);

implementation

end.

//  Log List
//
// $Log: ISOException.pas,v $
// Revision 1.3  2004/06/07 02:24:41  nalilord
// first isolib cvs check-in
//
//
//
//
//

