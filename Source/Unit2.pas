unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles;

type
  TSettings = class(TForm)
    AddUnblockContextMenuCB: TCheckBox;
    ApplyBtn: TButton;
    CancelBtn: TButton;
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

procedure TSettings.ApplyBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Setup.ini');
  Main.CompactContextMenu:=not AddUnblockContextMenuCB.Checked;
  Ini.WriteBool('Main', 'CompactContextMenu', Main.CompactContextMenu);
  Ini.Free;
  Main.ContextMenu(true, Main.CompactContextMenu);
  Close;
end;

procedure TSettings.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSettings.FormCreate(Sender: TObject);
begin
  AddUnblockContextMenuCB.Checked:=not Main.CompactContextMenu;
  Caption:=Main.SettingsBtn.Caption;
  AddUnblockContextMenuCB.Caption:=ID_UNBLOCK_ACCESS_CONTEXT_MENU;
  ApplyBtn.Caption:=ID_APPLY;
  CancelBtn.Caption:=ID_CANCEL;
end;

end.
