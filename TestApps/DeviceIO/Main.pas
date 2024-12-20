unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ISODiscLib, StdCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure BuildDriveList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.BuildDriveList;
type
  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM, dtRAM);
var
  DriveNum: Integer;
  DriveChar: Char;
  DriveType: TDriveType;
  DriveBits: set of 0..25;
  DriveAdded: Boolean;
begin
  DriveAdded := False;
  ComboBox1.Clear;
  Integer(DriveBits) := GetLogicalDrives;

  for DriveNum := 0 to 25 do
  begin
    if not (DriveNum in DriveBits) then
      Continue;
    DriveChar := Char(DriveNum + Ord('a'));
    DriveType := TDriveType(GetDriveType(PChar(DriveChar + ':\')));
    if DriveType in [dtCDROM] then
    begin
      ComboBox1.Items.Add(UpperCase(DriveChar) + ':\');
      DriveAdded := True;
    end;
  end;

  if DriveAdded then
    ComboBox1.ItemIndex := 0
  else
  begin
    Button1.Enabled   := False;
    Button1.Caption   := 'No CD/DVD drive found!';
    ComboBox1.Enabled := False;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  DiscLib: TISODiscLib;
  Handle:  THandle;
begin
  DiscLib := TISODiscLib.Create;
  try
    Handle := DiscLib.OpenDrive(ComboBox1.Text[1]);
    DiscLib.Test(Handle);
  finally
    DiscLib.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BuildDriveList;
end;

end.

