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
    FirewallBtn: TButton;
    CloseBtn: TButton;
    OpenDialog: TOpenDialog;
    SearchEdt: TEdit;
    StatusBar: TStatusBar;
    ImportDialog: TOpenDialog;
    ExportDialog: TSaveDialog;
    MainMenu1: TMainMenu;
    RulesItem: TMenuItem;
    ImportBtn: TMenuItem;
    ExportBtn: TMenuItem;
    HelpItem: TMenuItem;
    AboutBtn: TMenuItem;
    ListView: TListView;
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure FirewallBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBtnClick(Sender: TObject);
    procedure SearchEdtMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SearchEdtChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchEdtKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SearchEdtKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImportBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure ListViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListViewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListViewDblClick(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  protected
    procedure WMDropFiles (var Msg: TMessage); message WM_DropFiles;
  private
    procedure LoadRegRules;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure HandleParams;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;
  RuleNames, RulePaths: TStringList;
  CloseDuplicate: boolean;
  BlockedCount: integer;
  UnblockedCount: integer;

  // ������� / Tranlate
  ID_SEARCH: string;

  ID_ABOUT, ID_LAST_UPDATE: string;

  ID_RULE_SUCCESSFULLY_CREATED, ID_RULE_ALREADY_EXISTS, ID_RULE_SUCCESSFULLY_REMOVED, ID_RULE_NOT_FOUND, ID_CHOOSE_RULE,
  ID_RULES_SUCCESSFULLY_CREATED, ID_FAILED_CREATE_RULES, ID_RULES_SUCCESSFULLY_REMOVED, ID_FAILED_REMOVE_RULES,
  ID_REMOVED_RULES_FOR_NONEXISTENT_APPS, ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND: string;

const
  NET_FW_IP_PROTOCOL_TCP = 6;
  NET_FW_IP_PROTOCOL_UDP = 17;

  NET_FW_RULE_DIR_IN = 1;   // IN - �������� ����������
  NET_FW_RULE_DIR_OUT = 2;  // OUT - ���������

implementation

{$R *.dfm}
{$R UAC.res}

function CutStr(Str: string; CharCount: integer): string;
begin
  if Length(Str) > CharCount then
    Result:=Copy(Str, 1, CharCount - 3) + '...'
  else
    Result:=Str;
end;

procedure AddRuleToFirewall(const Caption, Executable: string; NET_FW_IP_PROTOCOL, NET_FW_RULE_DIR: integer);
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
  Profile:=NET_FW_PROFILE2_PRIVATE or NET_FW_PROFILE2_PUBLIC or NET_FW_PROFILE2_DOMAIN; //�������
  fwPolicy2:=CreateOleObject('HNetCfg.FwPolicy2');
  RulesObject:=fwPolicy2.Rules;
  NewRule:=CreateOleObject('HNetCfg.FWRule');
  NewRule.Name:=Caption;
  NewRule.Description:=Caption;
  NewRule.Applicationname:=Executable;
  NewRule.Protocol:=NET_FW_IP_PROTOCOL; // ���������
  //NewRule.LocalPorts:=Port; // ���� ����, dword
  NewRule.Direction:=NET_FW_RULE_DIR; // �������� � ��������� ����������
  NewRule.Enabled:=true;
  NewRule.Grouping:='FirewallEasy';
  NewRule.Profiles:=Profile;
  NewRule.Action:=NET_FW_ACTION_BLOCK; // NET_FW_ACTION_BLOCK - ���������, NET_FW_ACTION_ALLOW - ���������
  RulesObject.Add(NewRule);
end;

procedure AddRulesForApp(const FilePath: string);
var
  RuleCaption: string;
begin
  RuleCaption:=ExtractFileName(FilePath) + ' ' + DateToStr(Date) + ' ' + TimeToStr(Time);

  // ��������� ��� ������� � Firewall
  AddRuleToFirewall(RuleCaption + '_TCP_IN', FilePath, NET_FW_IP_PROTOCOL_TCP, NET_FW_RULE_DIR_IN);
  AddRuleToFirewall(RuleCaption + '_TCP_OUT', FilePath, NET_FW_IP_PROTOCOL_TCP, NET_FW_RULE_DIR_OUT);
  AddRuleToFirewall(RuleCaption + '_UDP_IN', FilePath, NET_FW_IP_PROTOCOL_UDP, NET_FW_RULE_DIR_IN);
  AddRuleToFirewall(RuleCaption + '_UDP_OUT', FilePath, NET_FW_IP_PROTOCOL_UDP, NET_FW_RULE_DIR_OUT);

  // ��������� ������, ��������� RuleNames, RulePaths
  Main.LoadRegRules;
end;

procedure RemoveRuleFromFirewall(const RuleName: string);
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
  RemoveRuleFromFirewall(RuleName + '_TCP_IN');
  RemoveRuleFromFirewall(RuleName + '_TCP_OUT');
  RemoveRuleFromFirewall(RuleName + '_UDP_IN');
  RemoveRuleFromFirewall(RuleName + '_UDP_OUT');

  // ��������� ������, ��������� RuleNames, RulePaths
  Main.LoadRegRules;
end;

procedure TMain.AddBtnClick(Sender: TObject);
begin
  if not OpenDialog.Execute then Exit;
  if Pos(OpenDialog.FileName, RulePaths.Text) = 0 then begin
    AddRulesForApp(OpenDialog.FileName);
    StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_CREATED, [CutStr(ExtractFileName(OpenDialog.FileName), 22)]);
  end else StatusBar.SimpleText:=' ' + Format(ID_RULE_ALREADY_EXISTS, [CutStr(ExtractFileName(OpenDialog.FileName), 23)]);
end;

procedure TMain.RemBtnClick(Sender: TObject);
begin
  if ListView.ItemIndex <> - 1 then begin
    StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_REMOVED, [CutStr(ExtractFileName(RulePaths.Strings[ListView.ItemIndex]), 22)]); //����� �������� �������� ��� �� �����, ������� ����� ���������
    RemoveAppRules(RuleNames.Strings[ListView.ItemIndex]);
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
  i, AmountFiles, Size: integer;
  FileName: PChar; FilePath: string;
begin
  inherited;
  AmountFiles:=DragQueryFile(Msg.WParam, $FFFFFFFF, FileName, 255);
  BlockedCount:=0;
  for i:=0 to AmountFiles - 1 do begin
    Size:=DragQueryFile(Msg.WParam, i, nil, 0) + 1;
    FileName:=StrAlloc(Size);
    DragQueryFile(Msg.WParam, i, FileName, Size);
    FilePath:=StrPas(FileName);
    StrDispose(FileName);
    if (AnsiLowerCase(ExtractFileExt(FilePath)) = '.exe') and
       (FileExists(FilePath)) and (Pos(FilePath, RulePaths.Text) = 0) then
    begin
      AddRulesForApp(FilePath);
      Inc(BlockedCount);
    end;
  end;
  DragFinish(Msg.WParam);
  
  if BlockedCount > 0 then
    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_CREATED + ' ' + IntToStr(BlockedCount)
  else
    StatusBar.SimpleText:=' ' + ID_FAILED_CREATE_RULES;
end;

procedure TMain.LoadRegRules;
var
  Rules: TStringList;
  i: integer;
  Reg : TRegistry;
  SubKeyNames: TStringList;
  RegName: string;
  Item: TListItem;
begin
  RuleNames.Clear;
  RulePaths.Clear;
  ListView.Clear;

  Rules:=TStringList.Create;
  Reg:=TRegistry.Create;
  SubKeyNames:=TStringList.Create;
  Reg.RootKey:=HKEY_LOCAL_MACHINE;
  Reg.OpenKeyReadOnly('SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules');
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
      Item:=Main.ListView.Items.Add;
      Item.Caption:=ExtractFileName(RulePaths.Strings[RulePaths.Count - 1]);
      Item.SubItems.Add(RulePaths.Strings[RulePaths.Count - 1]);
    end;
  end;
  Reg.CloseKey;
  Rules.Free;
  Reg.Free;
end;

procedure SendMessageToHandle(TrgWND: HWND; MsgToHandle: string);
var
  CDS: TCopyDataStruct;
begin
  CDS.dwData:=0;
  CDS.cbData:=(Length(MsgToHandle) + 1) * Sizeof(char);
  CDS.lpData:=PChar(MsgToHandle);
  SendMessage(TrgWND, WM_COPYDATA, Integer(Application.Handle), Integer(@CDS));
end;

procedure TMain.HandleParams;
var
  i: Integer;
  WND: HWND;
  Msg: String;
begin
  // ��������� ������, �������� ParamStr
  if ParamCount >= 2 then begin
    if AnsiLowerCase(ExtractFileExt(ParamStr(2))) = '.exe' then begin

      // Handles /block
      if AnsiLowerCase(ParamStr(1)) = '/block' then begin
        if Pos(AnsiLowerCase(ExpandFileName(ParamStr(2))), AnsiLowerCase(RulePaths.Text)) = 0 then begin
          AddRulesForApp(ExpandFileName(ParamStr(2)));
          StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_CREATED, [CutStr(ExtractFileName(ParamStr(2)), 22)]);
          Inc(BlockedCount);
          Msg:='%ADDED%';

        end else begin
          StatusBar.SimpleText:=' ' + Format(ID_RULE_ALREADY_EXISTS, [CutStr(ExtractFileName(ParamStr(2)), 22)]);
          Msg:='%EXISTS%';
        end;

      // Handles /unblock
      end else if AnsiLowerCase(ParamStr(1)) = '/unblock' then begin
        if Pos(AnsiLowerCase(ExpandFileName(ParamStr(2))), AnsiLowerCase(RulePaths.Text)) > 0 then begin
          for i:=0 to RuleNames.Count - 1 do begin
            if AnsiLowerCase(ExpandFileName(ParamStr(2))) = AnsiLowerCase(RulePaths.Strings[i]) then begin
              RemoveAppRules(RuleNames.Strings[i]);
              StatusBar.SimpleText:=' ' + Format(ID_RULE_SUCCESSFULLY_REMOVED, [CutStr(ExtractFileName(ParamStr(2)), 22)]);
              Inc(UnblockedCount);
              Msg:='%REMOVED%';

              Break;
            end;
          end;

        end else begin
          StatusBar.SimpleText:=' ' + Format(ID_RULE_NOT_FOUND, [CutStr(ExtractFileName(ParamStr(2)), 22)]);
          Msg:='%MISSING%';
        end;
      end;

      if Msg <> '' then begin
        WND:=FindWindow('TMain', 'Firewall Easy');
        if WND <> 0 then begin
          CloseDuplicate:=true;
          SendMessageToHandle(WND, Msg);
        end;
      end;
    end;
  end;
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
  Ini: TIniFile; Reg: TRegistry;
begin
  // ������� / Translate
  if FileExists(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini') then
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini')
  else
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\English.ini');

  RulesItem.Caption:=Ini.ReadString('Main', 'ID_RULES', '');
  ImportBtn.Caption:=Ini.ReadString('Main', 'ID_IMPORT', '');
  ExportBtn.Caption:=Ini.ReadString('Main', 'ID_EXPORT', '');
  HelpItem.Caption:=Ini.ReadString('Main', 'ID_HELP', '');
  ID_ABOUT:=Ini.ReadString('Main', 'ID_ABOUT', '');
  AboutBtn.Caption:=ID_ABOUT;

  ListView.Columns[0].Caption:=Ini.ReadString('Main', 'ID_APP_NAME', '');
  ListView.Columns[1].Caption:=Ini.ReadString('Main', 'ID_APP_PATH', '');

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
  ID_RULE_NOT_FOUND:=Ini.ReadString('Main', 'ID_RULE_NOT_FOUND', '');
  ID_CHOOSE_RULE:=Ini.ReadString('Main', 'ID_CHOOSE_RULE', '');
  ID_RULES_SUCCESSFULLY_CREATED:=Ini.ReadString('Main', 'ID_RULES_SUCCESSFULLY_CREATED', '');
  ID_FAILED_CREATE_RULES:=Ini.ReadString('Main', 'ID_FAILED_CREATE_RULES', '');
  ID_RULES_SUCCESSFULLY_REMOVED:=Ini.ReadString('Main', 'ID_RULES_SUCCESSFULLY_REMOVED', '');
  ID_FAILED_REMOVE_RULES:=Ini.ReadString('Main', 'ID_FAILED_REMOVE_RULES', '');
  ID_REMOVED_RULES_FOR_NONEXISTENT_APPS:=Ini.ReadString('Main', 'ID_REMOVED_RULES_FOR_NONEXISTENT_APPS', '');
  ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND:=Ini.ReadString('Main', 'ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND', '');

  ID_LAST_UPDATE:=Ini.ReadString('Main', 'ID_LAST_UPDATE', '');

  DragAcceptFiles(Handle, true);
  RuleNames:=TStringList.Create;
  RulePaths:=TStringList.Create;

  LoadRegRules;

  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CLASSES_ROOT;
  if (Reg.OpenKeyReadOnly('\exefile\shell\FirewallEasy') = false) and (Reg.OpenKey('\exefile\shell\FirewallEasy', true)) then begin
    Reg.WriteString('MUIVerb', Ini.ReadString('Main', 'ID_CONTEXT_MENU', ''));
    Reg.WriteString('Icon', ParamStr(0));
    Reg.WriteString('SubCommands', '');
    Reg.OpenKey('\exefile\shell\FirewallEasy\Shell\Block', true);
    Reg.WriteString('MUIVerb', Ini.ReadString('Main', 'ID_BLOCK_ACCESS', ''));
    Reg.WriteString('HasLUAShield', '');
    Reg.OpenKey('\exefile\shell\FirewallEasy\Shell\Block\Command', true);
    Reg.WriteString('', '"' + ParamStr(0) + '" /block "%1"');
    Reg.OpenKey('\exefile\shell\FirewallEasy\Shell\Unblock', true);
    Reg.WriteString('MUIVerb', Ini.ReadString('Main', 'ID_UNBLOCK_ACCESS', ''));
    Reg.WriteString('HasLUAShield', '');
    Reg.OpenKey('\exefile\shell\FirewallEasy\Shell\Unblock\Command', true);
    Reg.WriteString('', '"' + ParamStr(0) + '" /unblock "%1"');
  end;
  Reg.CloseKey;
  Reg.Free;
  Ini.Free;

  HandleParams;

  if CloseDuplicate = false then
    Caption:='Firewall Easy';
  Application.Title:=Caption;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RuleNames.Free;
  RulePaths.Free;
end;

procedure TMain.CheckBtnClick(Sender: TObject);
var
  i, CountRemovedRules: integer;
begin
  CountRemovedRules:=0;
  for i:=RulePaths.Count - 1 downto 0 do
    if not FileExists(RulePaths.Strings[i]) then begin
      RemoveAppRules(RuleNames.Strings[i]);
      Inc(CountRemovedRules);
    end;

  if CountRemovedRules <> 0 then StatusBar.SimpleText:=' ' + ID_REMOVED_RULES_FOR_NONEXISTENT_APPS + ' ' + IntToStr(CountRemovedRules) else
    StatusBar.SimpleText:=' ' + ID_RULES_FOR_NONEXISTENT_APPS_NOT_FOUND;
end;

procedure TMain.FormShow(Sender: TObject);
begin
  ListView.SetFocus;
  if CloseDuplicate then Close;
end;

procedure TMain.ListViewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ListView.ItemIndex = -1 then Exit;
  StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListView.ItemIndex], 62);
  if Key = VK_DELETE then
    RemBtn.Click
  else if (Key = VK_RETURN) and (FileExists(RulePaths.Strings[ListView.ItemIndex])) then
    ShellExecute(0, 'open', 'explorer', PChar('/select, "' + RulePaths.Strings[ListView.ItemIndex] + '"'), nil, SW_SHOW);
end;

procedure TMain.WMCopyData(var Msg: TWMCopyData);
var
  Input: string;
begin
  Input:=PChar(TWMCopyData(Msg).CopyDataStruct.lpData);

  if Input = '%ADDED%' then begin
    Inc(BlockedCount);
    LoadRegRules;
    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_CREATED + ' ' + IntToStr(BlockedCount);
  end else if Input = '%REMOVED%' then begin
    Inc(UnblockedCount);
    LoadRegRules;
    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_REMOVED + ' ' + IntToStr(UnblockedCount);
  end else if Input = '%EXISTS%' then
    StatusBar.SimpleText:=' ' + ID_FAILED_CREATE_RULES
  else if Input = '%MISSING%' then
    StatusBar.SimpleText:=' ' + ID_FAILED_REMOVE_RULES;

  Msg.Result:=Integer(True);
end;

procedure TMain.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ������� ��� ������� ���������
  if Key = VK_MENU then
    Key:=0;
end;

procedure TMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ������� ��� ������� ���������
  if Key = VK_MENU then
    Key:=0;
end;

procedure TMain.ListViewDblClick(Sender: TObject);
begin
  if ListView.ItemIndex = -1 then Exit;
  if FileExists(RulePaths.Strings[ListView.ItemIndex]) then
    ShellExecute(0, 'open', 'explorer', PChar('/select, "' + RulePaths.Strings[ListView.ItemIndex] + '"'), nil, SW_SHOW);
end;

procedure ScrollToListViewItem(LV: TListview; ItemIndex: Integer);
var
  R: TRect;
begin
  R:=LV.Items[ItemIndex].DisplayRect(drBounds);
  LV.Scroll(0, R.Top - LV.ClientHeight div 2);
end;

procedure TMain.SearchEdtChange(Sender: TObject);
var
  i: integer;
begin
  if ListView.Items.Count = 0 then Exit;
  ListView.ItemIndex:=-1;
  for i:=0 to RuleNames.Count - 1 do
    if Pos(AnsiLowerCase(SearchEdt.Text), AnsiLowerCase(RuleNames.Strings[i])) > 0 then begin

      ScrollToListViewItem(ListView, i);
      //ListView.ItemIndex:=i;
      ListView.Items.Item[i].Selected:=true;
      Break;
    end;
  if ListView.ItemIndex <> -1 then
    StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListView.ItemIndex], 63)
  else
    StatusBar.SimpleText:=' ';
end;

procedure TMain.SearchEdtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ������� ��� ������� ���������
  if Key = VK_MENU then
    Key:=0;

  if SearchEdt.Text = ID_SEARCH then begin
    SearchEdt.Font.Color:=clBlack;
    SearchEdt.Clear;
  end;
end;

procedure TMain.SearchEdtKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if SearchEdt.Text = '' then begin
    SearchEdt.Font.Color:=clGray;
    SearchEdt.Text:=ID_SEARCH;
  end;
end;

procedure TMain.SearchEdtMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if SearchEdt.Text = ID_SEARCH then begin
    SearchEdt.Font.Color:=clBlack;
    SearchEdt.Clear;
  end;
end;

procedure TMain.ImportBtnClick(Sender: TObject);
var
  ImportRulesList: TStringList; i: integer;
begin
  if (ImportDialog.Execute) and (FileExists(ImportDialog.FileName)) then begin
    CheckBtn.Click;
    ImportRulesList:=TStringList.Create;
    ImportRulesList.LoadFromFile(ImportDialog.FileName);

    BlockedCount:=0;
    for i:=0 to ImportRulesList.Count - 1 do
      if Pos(ImportRulesList.Strings[i], RulePaths.Text) = 0 then begin
        AddRulesForApp(ImportRulesList.Strings[i]);
        Inc(BlockedCount);
      end;

    StatusBar.SimpleText:=' ' + ID_RULES_SUCCESSFULLY_CREATED + ' ' + IntToStr(BlockedCount);

    ImportRulesList.Free;
  end;
end;

procedure TMain.ExportBtnClick(Sender: TObject);
begin
  if (ExportDialog.Execute) and (RulePaths.Count > 0) then
    RulePaths.SaveToFile(ExportDialog.FileName);
end;

procedure TMain.AboutBtnClick(Sender: TObject);
begin
  Application.MessageBox(PChar(Caption + ' 0.8' + #13#10 +
  ID_LAST_UPDATE + ' 25.05.2025' + #13#10 +
  'https://r57zone.github.io' + #13#10 +
  'r57zone@gmail.com'), PChar(ID_ABOUT), MB_ICONINFORMATION);
end;

procedure TMain.ListViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ListView.ItemIndex <> -1 then
    StatusBar.SimpleText:=' ' + CutStr(RulePaths.Strings[ListView.ItemIndex], 62)
  else
    StatusBar.SimpleText:=' ';

  if SearchEdt.Text = '' then begin
    SearchEdt.Font.Color:=clGray;
    SearchEdt.Text:=ID_SEARCH;
  end;
end;

end.
