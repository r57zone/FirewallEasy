unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles, ExtCtrls;

type
  TSettings = class(TForm)
    AddUnblockContextMenuCB: TCheckBox;
    EnableDragAndDropCB: TCheckBox;
    Panel: TPanel;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    procedure DragAndDropShowWarning(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Settings: TSettings;

implementation

uses Unit1;

{$R *.dfm}

procedure TSettings.DragAndDropShowWarning(Sender: TOBject);
begin
  if EnableDragAndDropCB.Checked then
    Application.MessageBox(PChar(ID_DRAG_AND_DROP_WARNING), PChar(ID_WARNING), MB_ICONWARNING);
end;

procedure TSettings.ApplyBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Main.CompactContextMenu:=not AddUnblockContextMenuCB.Checked;
  Main.DragAndDropEnabled:=EnableDragAndDropCB.Checked;
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Setup.ini');
  Ini.WriteBool('Main', 'CompactContextMenu', Main.CompactContextMenu);
  Ini.Free;
  Main.ContextMenu(true, Main.CompactContextMenu);
  Main.EnableLUA(Main.DragAndDropEnabled);
  Close;
end;

procedure TSettings.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSettings.FormCreate(Sender: TObject);
begin
  AddUnblockContextMenuCB.Checked:=not Main.CompactContextMenu;
  EnableDragAndDropCB.Checked:=Main.DragAndDropEnabled;
  EnableDragAndDropCB.OnClick:=DragAndDropShowWarning;
  Caption:=Main.SettingsBtn.Caption;
  AddUnblockContextMenuCB.Caption:=ID_UNBLOCK_ACCESS_CONTEXT_MENU;
  EnableDragAndDropCB.Caption:=ID_ENABLE_DRAG_AND_DROP;
  ApplyBtn.Caption:=ID_APPLY;
  CancelBtn.Caption:=ID_CANCEL;
end;

end.
