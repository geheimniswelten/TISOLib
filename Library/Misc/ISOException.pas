//
//  TISOLib - Exception definitions
//
//  refer to http://isolib.xenome.info/
//

//
// $Id:  $
//

Unit ISOException;

Interface

Uses
  SysUtils;   // for Exception

Type
  EISOLibException = Class(Exception);
  EISOLibImageException = Class(EISOLibException);
  EISOLibContainerException = Class(EISOLibException);

Implementation

End.

//  Log List
//
// $Log:  $
//
//
//
//
