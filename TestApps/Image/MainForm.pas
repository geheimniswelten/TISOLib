unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, ISOImage, ISOStructs, DataTree;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    mm_File: TMenuItem;
    sm_File_Open: TMenuItem;
    sm_File_Close: TMenuItem;
    sm_File_Break1: TMenuItem;
    sm_File_Quit: TMenuItem;
    dlg_OpenImage: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    pnl_BorderBG: TPanel;
    mem_DebugOut: TMemo;
    TabSheet2: TTabSheet;
    tv_PathTable: TTreeView;
    TabSheet3: TTabSheet;
    pnl_Info: TPanel;
    sm_File_SaveAs: TMenuItem;
    gbx_ItemInfo: TGroupBox;
    pnl_FileTree: TPanel;
    tv_Directory: TTreeView;
    Splitter1: TSplitter;
    lb_EntType_Info: TLabel;
    lb_EntType: TLabel;
    lb_EntName_Info: TLabel;
    lb_EntName: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label1: TLabel;
    Label10: TLabel;
    Label13: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    procedure sm_File_QuitClick(Sender: TObject);
    procedure sm_File_OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tv_DirectoryDblClick(Sender: TObject);
    procedure sm_File_CloseClick(Sender: TObject);
    procedure tv_DirectoryChange(Sender: TObject; Node: TTreeNode);
  private
    fISOImage  : TISOImage;
    procedure  BuildStructureTree(ATV: TTreeView; RootNode: TTreeNode; ADirEntry: TDirectoryEntry);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.sm_File_QuitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.sm_File_OpenClick(Sender: TObject);
var
  Node : TTreeNode;
begin
  if ( dlg_OpenImage.Execute ) then
  begin
    FreeAndNil(fISOImage);

    mem_DebugOut.Clear;
    tv_Directory.Items.Clear;
    tv_PathTable.Items.Clear;

    fISOImage := TISOImage.Create(dlg_OpenImage.FileName, mem_DebugOut.Lines);

    try
      fISOImage.OpenImage;

        // only for debugging, later not needed - will be recreated on
        // save...
      fISOImage.ParsePathTable(tv_PathTable);

      Node := tv_Directory.Items.Add(nil, '/');
      Node.Data := fISOImage.Structure.RootDirectory;
      BuildStructureTree(tv_Directory, Node, fISOImage.Structure.RootDirectory);

      // sm_File_SaveAs.Enabled := True; not yet ready
      sm_File_Close.Enabled := True;

    except
      on E: Exception do
      begin
        mem_DebugOut.Lines.Add('Exception: ' + E.ClassName + ' -> ' + E.Message);
        raise;
        //fISOImage.CloseImage;
      end;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  fISOImage := nil;   // not necessary, but safety first...
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fISOImage);
end;

procedure TForm1.tv_DirectoryDblClick(Sender: TObject);
var
  Node : TTreeNode;
  Obj  : TObject;
begin
  Node := TTreeView(Sender).Selected;

  if Assigned(Node.Data) then
  begin
    Obj := TObject(Node.Data);
    if ( Obj is TFileEntry ) and ( SaveDialog1.Execute ) then
      fISOImage.ExtractFile(TFileEntry(Obj), SaveDialog1.FileName);
  end;
end;

procedure TForm1.BuildStructureTree(ATV: TTreeView; RootNode: TTreeNode; ADirEntry: TDirectoryEntry);
var
  i : Integer;
  Node : TTreeNode;
  Dir  : TDirectoryEntry;
  Fil  : TFileEntry;
begin
  for i := 0 to ADirEntry.DirectoryCount-1 do
  begin
    Dir := ADirEntry.Directories[i];

    Node := ATV.Items.AddChild(RootNode, Dir.Name + '/');
    Node.Data := Pointer(Dir);

    BuildStructureTree(ATV, Node, Dir);
  end;

  for i := 0 to ADirEntry.FileCount-1 do
  begin
    Fil := ADirEntry.Files[i];

    Node := ATV.Items.AddChild(RootNode, Fil.Name);
    Node.Data := Pointer(Fil);
  end;
end;

procedure TForm1.sm_File_CloseClick(Sender: TObject);
begin
  if ( Assigned(fISOImage) ) then
    fISOImage.CloseImage;

  sm_File_Close.Enabled  := False;
  sm_File_SaveAs.Enabled := False;
end;

procedure TForm1.tv_DirectoryChange(Sender: TObject; Node: TTreeNode);
var
  Obj : TObject;
begin
  if Assigned(Node) then
  begin
    Obj := TObject(Node.Data);

    lb_EntType.Caption := 'unknown';

    if Assigned(Obj) then
    begin
      if ( Obj is TDirectoryEntry ) then
      begin
        lb_EntType.Caption  := 'directory';
        lb_EntName.Caption  := TDirectoryEntry(Obj).Name;
        lb_EntName.Hint     := '';
        lb_EntName.ShowHint := False;
      end;

      if ( Obj is TFileEntry ) then
      begin
        lb_EntType.Caption  := 'file';
        lb_EntName.Caption  := TFileEntry(Obj).Name;
        lb_EntName.Hint     := TFileEntry(Obj).Path;
        lb_EntName.ShowHint := True;
      end;
    end;
  end;
end;

end.

