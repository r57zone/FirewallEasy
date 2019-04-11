unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComObj, ShellAPI, ComCtrls, ExtCtrls, Menus, Registry, IniFiles;

type
  TMain = class(TForm)
    AddBtn: TButton;
    RemBtn: TButton;
    CheckBtn: TButton;
    ListBox: TListBox;
    FirewallBtn: TButton;
    CloseBtn: TButton;
    OpenDialog: TOpenDialog;
    NameAppLbl: TLabel;
    AppPathLbl: TLabel;
    SearchEdt: TEdit;
    StatusBar: TStatusBar;
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure FirewallBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure StatusBarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBtnClick(Sender: TObject);
    procedure SearchEdtMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SearchEdtChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBoxKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  protected
    procedure WMDropFiles (var Msg: TMessage); message wm_DropFiles;
  private
    procedure LoadRegRules;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;
  RuleNames, RulePaths: TStringList;
  CloseDuplicate: boolean;
  CountBlock: integer;

  //Перевод / Tranlate
  ID_SEARCH: string;

  ID_ABOUT_TITLE, ID_LAST_UPDATE: string;

  ID_RULE_SUCCESSFULLY_CREATED, ID_RULE_ALREADY_EXISTS, ID_RULE_SUCCESSFULLY_REMOVED,
  ID_CHOOSE_RULE, ID_RULES_SUCCESSFULLY_CREATED, ID_FAILED_CREATE_RULES,
  ID_REMOVED_RULES_FOR_NONEXISTENT_APPS, ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND: string;

const
  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_IP_PROTOCOL_UDP = 17;

  NET_FW_RULE_DIR_IN = 1;   //IN - входящие соединения
  NET_FW_RULE_DIR_OUT = 2;  //OUT - исходящие

implementation

{$R *.dfm}
{$R UAC.res}

procedure AddToFirewall(const Caption, Executable: string; NET_FW_IP_PROTOCOL, NET_FW_RULE_DIR: integer);
const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;

  NET_FW_IP_PROTOCOL_ICMPv4 = 1;
  NET_FW_IP_PROTOCOL_ICMPv6 = 58;

  NET_FW_ACTION_ALLOW = 1;
  NET_FW_ACTION_BLOCK = 0;
var
  fwPolicy2: OleVariant;
  RulesObject: OleVariant;
  Profile: integer;
  NewRule: OleVariant;
begin
  Profile:=NET_FW_PROFILE2_PRIVATE or NET_FW_PROFILE2_PUBLIC or NET_FW_PROFILE2_DOMAIN; //Профили
  fwPolicy2:=CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject:=fwPolicy2.Rules;
  NewRule:=CreateOleObject('HNetCfg.FWRule');
  NewRule.Name:=Caption;
  NewRule.Description:=Caption;
  NewRule.Applicationname:=Executable;
  NewRule.Protocol:=NET_FW_IP_PROTOCOL; //Протоколы
  //NewRule.LocalPorts:=Port; Если порт, dword
  NewRule.Direction:=NET_FW_RULE_DIR; //Входящие и исходящие соединения
  NewRule.Enabled:=true;
  NewRule.Grouping:='FirewallEasy';
  NewRule.Profiles:=Profile;
  NewRule.Action:=NET_FW_ACTION_BLOCK; //NET_FW_ACTION_BLOCK - запретить, NET_FW_ACTION_ALLOW - разрешить
  RulesObject.Add(NewRule);
end;

procedure AddRulesForApp(const Caption, Executable: string);
begin
  AddToFirewall(Caption + '_TCP_IN', Executable, NET_FW_IP_PROTOCOL_TCP, NET_FW_RULE_DIR_IN);
  AddToFirewall(Caption + '_TCP_OUT', Executable, NET_FW_IP_PROTOCOL_TCP, NET_FW_RULE_DIR_OUT);
  AddToFirewall(Caption + '_UDP_IN', Executable, NET_FW_IP_PROTOCOL_UDP, NET_FW_RULE_DIR_IN);
  AddToFirewall(Caption + '_UDP_OUT', Executable, NET_FW_IP_PROTOCOL_UDP, NET_FW_RULE_DIR_OUT);
end;

procedure RemoveFromFirewall(const RuleName: string);
const
  NET_FW_PROFILE2_DOMAIN = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC = 4;
var
  Profile: integer;
  Policy2: OleVariant;
  RObject: OleVariant;
begin
  Profile:=NET_FW_PROFILE2_PRIVATE or NET_FW_PROFILE2_PUBLIC or NET_FW_PROFILE2_DOMAIN;
  Policy2:=CreateOleObject('HNetCfg.FwPolicy2');
  RObject:=Policy2.Rules;
  RObject.Remove(RuleName);
end;

procedure RemoveAppRules(const RuleName: string);
begin
  RemoveFromFirewall(RuleName + '_TCP_IN');
  RemoveFromFirewall(RuleName + '_TCP_OUT');
  RemoveFromFirewall(RuleName + '_UDP_IN');
  RemoveFromFirewall(RuleName + '_UDP_OUT');
end;

function CutStr(Str: string; CharCount: integer): string;
begin
  if Length(Str) > CharCount then
    Result:=Copy(Str, 1, CharCount - 3) + '...'
  else
    Result:=Str;
end;

procedure TMain.AddBtnClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    if Pos(OpenDialog.FileName, RulePaths.Text) = 0 then begin
      RuleNames.Add(ExtractFileName(OpenDialog.FileName) + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time));
      RulePaths.Add(OpenDialog.FileName);
      AddRulesForApp(RuleNames.Strings[RuleNames.Count - 1], RulePaths.Strings[RulePaths.Count - 1]);
      ListBox.Items.Add(CutStr(ExtractFileName(RulePaths.Strings[RulePaths.Count - 1]), 23) + ^I + CutStr(RulePaths.Strings[RulePaths.Count - 1], 38));
      StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_CREATED, [CutStr(ExtractFileName(OpenDialog.FileName), 22)]);
    end else StatusBar.SimpleText:=' ' + Format(ID_RULE_ALREADY_EXISTS, [CutStr(ExtractFileName(OpenDialog.FileName), 23)]);
end;

procedure TMain.RemBtnClick(Sender: TObject);
begin
  if ListBox.ItemIndex <> - 1 then begin
    RemoveAppRules(RuleNames.Strings[ListBox.ItemIndex]);
    StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_REMOVED, [CutStr(ExtractFileName(RulePaths.Strings[ListBox.ItemIndex]), 22)]);
    RuleNames.Delete(ListBox.ItemIndex);
    RulePaths.Delete(ListBox.ItemIndex);
    ListBox.Items.Delete(ListBox.ItemIndex);
  end else StatusBar.SimpleText:=' ' + ID_CHOOSE_RULE;
end;

procedure TMain.FirewallBtnClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'WF.msc', nil, nil, SW_SHOWNORMAL);
end;

procedure TMain.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.WMDropFiles(var Msg: TMessage);
var
  i, c, Amount, Size: integer;
  Filename: PChar; Path: string;
begin
  inherited;
  Amount:=DragQueryFile(Msg.WParam, $FFFFFFFF, Filename, 255);
  c:=0;
  for i:=0 to Amount - 1 do begin
   Size:=DragQueryFile(Msg.WParam, i, nil, 0) + 1;
   Filename:=StrAlloc(Size);
    DragQueryFile(Msg.WParam, i, Filename, Size);
    Path:=StrPas(Filename);
    StrDispose(Filename);
    if AnsiLowerCase(ExtractFileExt(Path)) = '.exe' then
      if FileExists(Path) then
        if Pos(Path, RulePaths.Text) = 0 then begin
          inc(c);
          RuleNames.Add(ExtractFileName(Path) + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time));
          RulePaths.Add(Path);
          AddRulesForApp(RuleNames.Strings[RuleNames.Count - 1], RulePaths.Strings[RulePaths.Count - 1]);
          ListBox.Items.Add(CutStr(ExtractFileName(RulePaths.Strings[RulePaths.Count - 1]), 23) + ^I + CutStr(RulePaths.Strings[RulePaths.Count - 1], 38));
        end;
  end;
  DragFinish(Msg.WParam);
  if c > 0 then
    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_CREATED + ' ' + IntToStr(c)
  else
    StatusBar.SimpleText:=' ' + ID_FAILED_CREATE_RULES;
end;

procedure TMain.StatusBarClick(Sender: TObject);
begin
  Application.MessageBox(PChar(Caption + ' 0.6.4' + #13#10 +
  ID_LAST_UPDATE + ' 11.04.2019' + #13#10 +
  'https://r57zone.github.io' + #13#10 +
  'r57zone@gmail.com'), PChar(ID_ABOUT_TITLE), MB_ICONINFORMATION);
end;

procedure TMain.LoadRegRules;
var
  Rules: TStringList;
  i: integer;
  Reg : TRegistry;
  SubKeyNames: TStringList;
  RegName: string;
begin
  RuleNames.Clear;
  RulePaths.Clear;
  ListBox.Clear;

  Rules:=TStringList.Create;
  Reg:=TRegistry.Create;
  SubKeyNames:=TStringList.Create;
  Reg.RootKey:=HKEY_LOCAL_MACHINE;
  Reg.OpenKeyReadOnly('SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules');
  Reg.GetValueNames(Rules);
  for i:=0 to Rules.Count - 1 do begin
    RegName:=Reg.ReadString(Rules.Strings[i]);
    if (Pos('EmbedCtxt=FirewallEasy', RegName) > 0) and (Pos('Dir=In', RegName) > 0) and (Pos('_UDP_', RegName) > 0) then begin
      Delete(RegName, 1, Pos('App=', RegName) + 3);
      RulePaths.Add(Copy(RegName, 1, Pos('|', RegName) - 1));
      Delete(RegName, 1, Pos('Name=', RegName) + 4);
      RegName:=Copy(RegName, 1, Pos('|', RegName) - 1);
      RegName:=Copy(RegName, 1, Pos('_UDP_', RegName) - 1);
      RuleNames.Add(RegName);
      ListBox.Items.Add(CutStr(ExtractFileName(RulePaths.Strings[RulePaths.Count - 1]), 23) + ^I + CutStr(RulePaths.Strings[RulePaths.Count - 1], 38));
    end;
  end;
  Reg.CloseKey;
  Rules.Free;
  Reg.Free;
end;

procedure SendMessageToHandle(TrgWnd: hWnd; MsgToHandle: string);
var
  CDS: TCopyDataStruct;
begin
  CDS.dwData:=0;
  CDS.cbData:=(Length(MsgToHandle) + 1) * Sizeof(char);
  CDS.lpData:=PChar(MsgToHandle);
  SendMessage(TrgWnd,WM_COPYDATA, Integer(Application.Handle), Integer(@CDS));
end;

function GetLocaleInformation(flag: integer): string;
var
  pcLCA: array [0..20] of Char;
begin
  if GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, flag, pcLCA, 19) <= 0 then
    pcLCA[0]:=#0;
  Result:=pcLCA;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  WND: HWND; Ini: TIniFile; Reg: TRegistry;
begin
  //Перевод / Translate
  if FileExists(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini') then
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini')
  else
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\English.ini');

  NameAppLbl.Caption:=Ini.ReadString('Main', 'ID_APP_NAME', '');
  AppPathLbl.Caption:=Ini.ReadString('Main', 'ID_APP_PATH', '');

  ID_SEARCH:=Ini.ReadString('Main', 'ID_SEARCH', '');
  SearchEdt.Text:=ID_SEARCH;

  AddBtn.Caption:=Ini.ReadString('Main', 'ID_ADD', '');
  OpenDialog.Filter:=Ini.ReadString('Main', 'ID_ADD_FILTER_NAME', '') + OpenDialog.Filter;
  RemBtn.Caption:=Ini.ReadString('Main', 'ID_REMOVE', '');
  CheckBtn.Caption:=Ini.ReadString('Main', 'ID_CHECK', '');
  FirewallBtn.Caption:=Ini.ReadString('Main', 'ID_FIREWALL', '');
  CloseBtn.Caption:=Ini.ReadString('Main', 'ID_EXIT', '');

  ID_RULE_SUCCESSFULLY_CREATED:=Ini.ReadString('Main', 'ID_RULE_SUCCESSFULLY_CREATED', '');
  ID_RULE_ALREADY_EXISTS:=Ini.ReadString('Main', 'ID_RULE_ALREADY_EXISTS', '');
  ID_RULE_SUCCESSFULLY_REMOVED:=Ini.ReadString('Main', 'ID_RULE_SUCCESSFULLY_REMOVED', '');
  ID_CHOOSE_RULE:=Ini.ReadString('Main', 'ID_CHOOSE_RULE', '');
  ID_RULES_SUCCESSFULLY_CREATED:=Ini.ReadString('Main', 'ID_RULES_SUCCESSFULLY_CREATED', '');
  ID_FAILED_CREATE_RULES:=Ini.ReadString('Main', 'ID_FAILED_CREATE_RULES', '');
  ID_REMOVED_RULES_FOR_NONEXISTENT_APPS:=Ini.ReadString('Main', 'ID_REMOVED_RULES_FOR_NONEXISTENT_APPS', '');
  ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND:=Ini.ReadString('Main', 'ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND', '');

  ID_ABOUT_TITLE:=Ini.ReadString('Main', 'ID_ABOUT_TITLE', '');
  ID_LAST_UPDATE:=Ini.ReadString('Main', 'ID_LAST_UPDATE', '');

  DragAcceptFiles(Handle, True);
  RuleNames:=TStringList.Create;
  RulePaths:=TStringList.Create;

  LoadRegRules;

  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CLASSES_ROOT;
  if (Reg.OpenKeyReadOnly('\exefile\shell\FirewallEasy') = false) and (Reg.OpenKey('\exefile\shell\FirewallEasy', true)) then begin
    Reg.WriteString('', Ini.ReadString('Main', 'ID_BLOCK_ACCESS', ''));
    Reg.WriteString('Icon', ParamStr(0));
    Reg.OpenKey('\exefile\shell\FirewallEasy\command', true);
    Reg.WriteString('', ParamStr(0) + ' "%1"');
  end;
  Reg.CloseKey;
  Reg.Free;
  Ini.Free;

  //Повторный запуск, передача ParamStr(1)
  if ParamCount > 0 then
    if AnsiLowerCase(ExtractFileExt(ParamStr(1))) = '.exe' then begin
      if Pos(ParamStr(1), RulePaths.Text) = 0 then begin
        RuleNames.Add(ExtractFileName(ParamStr(1)) + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time));
        RulePaths.Add(ParamStr(1));
        AddRulesForApp(RuleNames.Strings[RuleNames.Count - 1], RulePaths.Strings[RulePaths.Count - 1]);
        ListBox.Items.Add(CutStr(ExtractFileName(RulePaths.Strings[RulePaths.Count - 1]), 23) + ^I + CutStr(RulePaths.Strings[RulePaths.Count - 1], 38));
        StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_CREATED, [CutStr(ExtractFileName(ParamStr(1)), 22)]);
        inc(CountBlock);
        WND:=FindWindow('TMain', 'Firewall Easy');
        if WND <> 0 then begin
          CloseDuplicate:=true;
          SendMessageToHandle(WND, '%ADDED%');
        end;

      end else StatusBar.SimpleText:=' ' + Format(ID_RULE_ALREADY_EXISTS, [CutStr(ExtractFileName(ParamStr(1)), 22)]);
    end;

  if CloseDuplicate = false then
    Caption:='Firewall Easy';
  Application.Title:=Caption;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RuleNames.Free;
  RulePaths.Free;
end;

procedure TMain.ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if Button = mbRight then begin
    P.X:=X;
    P.Y:=Y;
    ListBox.ItemIndex:=ListBox.ItemAtPos(P, true);
  end;
  if ListBox.ItemIndex <> -1 then begin
    StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListBox.ItemIndex], 62);
    if Button = mbRight then
      ShellExecute(0, 'open', 'explorer', PChar('/select, "' + RulePaths.Strings[ListBox.ItemIndex] + '"'), nil, SW_SHOW);
  end;
end;

procedure TMain.CheckBtnClick(Sender: TObject);
var
  i, c: integer;
begin
  c:=0;
  for i:=RulePaths.Count - 1 downto 0 do
    if not FileExists(RulePaths.Strings[i]) then begin
      RemoveAppRules(RuleNames.Strings[i]);
      RuleNames.Delete(i);
      RulePaths.Delete(i);
      ListBox.Items.Delete(i);
      inc(c);
    end;
  if c <> 0 then StatusBar.SimpleText:=' ' + ID_REMOVED_RULES_FOR_NONEXISTENT_APPS + ' '+IntToStr(c) else
    StatusBar.SimpleText:=' ' + ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND;
end;

procedure TMain.SearchEdtMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if SearchEdt.Text = ID_SEARCH then begin
    SearchEdt.Font.Color:=clBlack;
    SearchEdt.Clear;
  end;
end;

procedure TMain.SearchEdtChange(Sender: TObject);
var
  i: integer;
begin
 if ListBox.Count > 0 then begin
  for i:=0 to RuleNames.Count - 1 do
      if Pos(AnsiLowerCase(SearchEdt.Text), AnsiLowerCase(RuleNames.Strings[i])) > 0 then
        ListBox.Selected[i]:=true;
    if ListBox.ItemIndex <> -1 then
      StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListBox.ItemIndex], 63);
  end;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  ListBox.SetFocus;
  if CloseDuplicate then Close;
end;

procedure TMain.ListBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ListBox.ItemIndex <> -1 then
    StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListBox.ItemIndex], 62);
end;

procedure TMain.WMCopyData(var Msg: TWMCopyData);
begin
  if PChar(TWMCopyData(msg).CopyDataStruct.lpData) = '%ADDED%' then begin
    Inc(CountBlock);
    LoadRegRules;
    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_CREATED + ' ' + IntToStr(CountBlock);
  end;
  Msg.Result:=Integer(True);
end;

end.
