program TestApp_ISOLib;

uses
  Forms,
  VolumeDescriptors in '..\..\Library\Image\VolumeDescriptors.pas',
  ImageFileHandler in '..\..\Library\Image\ImageFileHandler.pas',
  ISOImage in '..\..\Library\Image\ISOImage.pas',
  DataTree in '..\..\Library\Image\DataTree.pas',
  ISOToolBox in '..\..\Library\Misc\ISOToolBox.pas',
  ISOException in '..\..\Library\Misc\ISOException.pas',
  ISOIntStructs in '..\..\Library\Misc\ISOIntStructs.pas',
  ISOStructs in '..\..\Library\Misc\ISOStructs.pas',
  GlobalDefs in '..\..\Library\Misc\GlobalDefs.pas',
  MainForm in 'MainForm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

