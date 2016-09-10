unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComObj, ShellAPI, ComCtrls, ExtCtrls, Menus, Registry;

type
  TForm1 = class(TForm)
    AddBtn: TButton;
    RemoveBtn: TButton;
    CheckBtn: TButton;
    ListBox: TListBox;
    FirewallBtn: TButton;
    CloseBtn: TButton;
    OpenDialog1: TOpenDialog;
    NameLabel: TLabel;
    PathLabel: TLabel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    Search: TEdit;
    StatusBar: TStatusBar;
    procedure AddBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure FirewallBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure StatusBarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBtnClick(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SearchMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SearchChange(Sender: TObject);
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
  Form1: TForm1;
  RuleNames, RulePaths: TStringList;
  CloseDuplicate: boolean;
  CountBlock: integer;

implementation

{$R *.dfm}
{$R UAC.res}

procedure RemoveFromFirewall(const RuleName:string);
const
  NET_FW_PROFILE2_DOMAIN=1;
  NET_FW_PROFILE2_PRIVATE=2;
  NET_FW_PROFILE2_PUBLIC=4;
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

procedure AddToFirewall(Const Caption, Executable: String;Direct:boolean);
const
  NET_FW_PROFILE2_DOMAIN=1;
  NET_FW_PROFILE2_PRIVATE=2;
  NET_FW_PROFILE2_PUBLIC=4;

  NET_FW_IP_PROTOCOL_TCP=6;
  NET_FW_IP_PROTOCOL_UDP=17;
  NET_FW_IP_PROTOCOL_ICMPv4=1;
  NET_FW_IP_PROTOCOL_ICMPv6=58;

  NET_FW_ACTION_ALLOW=1;
  NET_FW_RULE_DIR_IN=1;
  NET_FW_RULE_DIR_OUT=2;
  NET_FW_ACTION_BLOCK=0;
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
  NewRule.Applicationname:= Executable;
  NewRule.Protocol:=NET_FW_IP_PROTOCOL_TCP; //Протоколы
  //NewRule.LocalPorts:=Port; Если порт, dword
  if Direct then
    NewRule.Direction:=NET_FW_RULE_DIR_IN //OUT - исходящие, IN - входящие
  else NewRule.Direction:=NET_FW_RULE_DIR_OUT;
  NewRule.Enabled:=true;
  NewRule.Grouping:='FirewallEasy';
  NewRule.Profiles:=Profile;
  NewRule.Action:=NET_FW_ACTION_BLOCK; //NET_FW_ACTION_BLOCK - запретить, NET_FW_ACTION_ALLOW - разрешить
  RulesObject.Add(NewRule);
end;

function CutName(Name: string; Count: integer):string;
begin
  if Length(name)>Count then Result:=Copy(Name,1,Count-3)+'...' else Result:=Name;
end;

procedure TForm1.AddBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    if Pos(OpenDialog1.FileName,RulePaths.Text)=0 then begin
      RuleNames.Add(ExtractFileName(OpenDialog1.FileName)+' '+DateToStr(Date)+' '+TimeToStr(Time));
      RulePaths.Add(OpenDialog1.FileName);
      AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],true);
      AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],false);
      ListBox.Items.Add(CutName(ExtractFileName(RulePaths.Strings[RulePaths.Count-1]),23)+^I+CutName(RulePaths.Strings[RulePaths.Count-1],38));
      StatusBar.SimpleText:=' Правило для приложения "'+CutName(ExtractFileName(OpenDialog1.FileName),23)+'" успешно создано';
    end else StatusBar.SimpleText:=' Правило для приложения "'+CutName(ExtractFileName(OpenDialog1.FileName),24)+'" уже существует';
end;

procedure TForm1.RemoveBtnClick(Sender: TObject);
begin
  if ListBox.ItemIndex<>-1 then begin
    RemoveFromFirewall(RuleNames.Strings[ListBox.ItemIndex]);
    RemoveFromFirewall(RuleNames.Strings[ListBox.ItemIndex]);
    StatusBar.SimpleText:=' Правило для приложения "'+CutName(ExtractFileName(RulePaths.Strings[ListBox.ItemIndex]),22)+'" успешно удалено';
    RuleNames.Delete(ListBox.ItemIndex);
    RulePaths.Delete(ListBox.ItemIndex);
    ListBox.Items.Delete(ListBox.ItemIndex);
  end else StatusBar.SimpleText:=' Выберите правило';
end;

procedure TForm1.FirewallBtnClick(Sender: TObject);
begin
  ShellExecute(0,'open','WF.msc',nil,nil,SW_ShowNormal);
end;

procedure TForm1.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.WMDropFiles(var Msg: TMessage);
var
i, c, Amount, Size: integer;
Filename: PChar; Path: string;
begin
  inherited;
  Amount:=DragQueryFile(Msg.WParam, $FFFFFFFF, Filename, 255);
  c:=0;
  for i:=0 to Amount-1 do begin
   Size:=DragQueryFile(Msg.WParam, i, nil, 0) + 1;
   Filename:=StrAlloc(size);
    DragQueryFile(Msg.WParam, i, Filename, size);
    Path:=StrPas(Filename);
    StrDispose(Filename);
    if (AnsiLowerCase(ExtractFileExt(path))='.dll') or (AnsiLowerCase(ExtractFileExt(path))='.exe') then if FileExists(Path) then
      if pos(Path,RulePaths.Text)=0 then begin
        inc(c);
        RuleNames.Add(ExtractFileName(Path)+' '+DateToStr(Date)+' '+TimeToStr(Time));
        RulePaths.Add(Path);
        AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],true);
        AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],false);
        ListBox.Items.Add(CutName(ExtractFileName(RulePaths.Strings[RulePaths.Count-1]),23)+^I+CutName(RulePaths.Strings[RulePaths.Count-1],38));
      end;
  end;
  DragFinish(Msg.WParam);
  if c>0 then StatusBar.SimpleText:=' Правил успешно создано : '+IntToStr(c);
  if c=0 then StatusBar.SimpleText:=' Не удалось создать правила';
end;

procedure TForm1.StatusBarClick(Sender: TObject);
begin
  Application.MessageBox(PChar(Caption+' 0.5 beta'+#13#10+'Последнее обновление: 10.09.2016'+#13#10+'https://r57zone.github.io'+#13#10+'r57zone@gmail.com'),'О программе...',0);
end;

procedure TForm1.LoadRegRules;
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
  for i:=0 to Rules.Count-1 do begin
    RegName:=Reg.ReadString(Rules.Strings[i]);
    if (pos('EmbedCtxt=FirewallEasy',RegName)>0) and (pos('Dir=In',RegName)>0) then begin
      Delete(RegName,1,pos('App=',RegName)+3);
      RulePaths.Add(Copy(RegName,1,pos('|',RegName)-1));
      Delete(RegName,1,pos('Name=',RegName)+4);
      RuleNames.Add(Copy(RegName,1,pos('|',RegName)-1));
      ListBox.Items.Add(CutName(ExtractFileName(RulePaths.Strings[RulePaths.Count-1]),23)+^I+CutName(RulePaths.Strings[RulePaths.Count-1],38));
    end;
  end;
  Reg.CloseKey;
  Rules.Free;
  Reg.Free;
end;

procedure SendMessageToHandle(TRGWND:hWnd; MsgToHandle: string);
var
  CDS: TCopyDataStruct;
begin
  CDS.dwData:=0;
  CDS.cbData:=(Length(MsgToHandle)+1)*Sizeof(char);
  CDS.lpData:=PChar(MsgToHandle);
  SendMessage(TRGWND,WM_COPYDATA, Integer(Application.Handle), Integer(@CDS));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  WND: HWND;
begin
  DragAcceptFiles(Handle, True);
  RuleNames:=TStringList.Create;
  RulePaths:=TStringList.Create;

  LoadRegRules;

  //Повторный запуск, передача ParamStr(1)
  if ParamCount>0 then
    if (AnsiLowerCase(ExtractFileExt(ParamStr(1)))='.dll') or (AnsiLowerCase(ExtractFileExt(ParamStr(1)))='.exe') then begin
      if Pos(ParamStr(1),RulePaths.Text)=0 then begin
        RuleNames.Add(ExtractFileName(ParamStr(1))+' '+DateToStr(Date)+' '+TimeToStr(Time));
        RulePaths.Add(ParamStr(1));
        AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],true);
        AddToFirewall(RuleNames.Strings[RuleNames.Count-1],RulePaths.Strings[RulePaths.Count-1],false);
        ListBox.Items.Add(CutName(ExtractFileName(RulePaths.Strings[RulePaths.Count-1]),23)+^I+CutName(RulePaths.Strings[RulePaths.Count-1],38));
        StatusBar.SimpleText:=' Правило для приложения "'+CutName(ExtractFileName(ParamStr(1)),22)+'" успешно создано';
        inc(CountBlock);
        WND:=FindWindow('TForm1', 'Firewall Easy');
        if WND<>0 then begin
          CloseDuplicate:=true;
          SendMessageToHandle(WND,'%ADDED%');
        end;

      end else StatusBar.SimpleText:=' Не удалось создать правило для приложения "'+CutName(ExtractFileName(ParamStr(1)),22)+'"';
    end;

  if CloseDuplicate=false then
    Caption:='Firewall Easy';
  Application.Title:=Caption;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RuleNames.Free;
  RulePaths.Free;
end;

procedure TForm1.ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if Button=mbRight then begin
    P.X:=X;
    P.Y:=Y;
    ListBox.ItemIndex:=ListBox.ItemAtPos(P,true);
  end;
  if ListBox.ItemIndex<>-1 then begin
    StatusBar.SimpleText:=' '+CutName(RulePaths.Strings[ListBox.ItemIndex],63);
    if Button=mbRight then ShellExecute(0, 'open', 'explorer', PChar('/select, '+RulePaths.Strings[ListBox.ItemIndex]),nil,SW_SHOW);
  end;
end;

procedure TForm1.CheckBtnClick(Sender: TObject);
var
i, c: integer;
begin
  c:=0;
  for i:=RulePaths.Count-1 downto 0 do
    if not FileExists(RulePaths.Strings[i]) then begin
      RemoveFromFirewall(RuleNames.Strings[i]);
      RemoveFromFirewall(RuleNames.Strings[i]);
      RuleNames.Delete(i);
      RulePaths.Delete(i);
      ListBox.Items.Delete(i);
      Inc(c);
    end;
  if c<>0 then StatusBar.SimpleText:=' Удалено правил для несуществующих приложений : '+IntToStr(c) else
    StatusBar.SimpleText:=' Правил для несуществующих приложений не найдено';
end;

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Search.Text='Поиск...' then begin Search.Font.Color:=clBlack; Search.Clear; end;
end;

procedure TForm1.SearchMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Search.Text='Поиск...' then begin Search.Font.Color:=clBlack; Search.Clear; end;
end;

procedure TForm1.SearchChange(Sender: TObject);
var
i: integer;
begin
  for i:=0 to RuleNames.Count-1 do
    if Pos(AnsiLowerCase(Search.Text),AnsiLowerCase(RuleNames.Strings[i]))>0 then ListBox.Selected[i]:=true;
  if ListBox.ItemIndex<>-1 then StatusBar.SimpleText:=' '+CutName(RulePaths.Strings[ListBox.ItemIndex],63);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ListBox.SetFocus;
  if CloseDuplicate then Close;
end;

procedure TForm1.ListBoxKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ListBox.ItemIndex<>-1 then StatusBar.SimpleText:=' '+CutName(RulePaths.Strings[ListBox.ItemIndex],63);
end;

procedure TForm1.WMCopyData(var Msg: TWMCopyData);
begin
  if PChar(TWMCopyData(msg).CopyDataStruct.lpData)='%ADDED%' then begin
    inc(CountBlock);
    LoadRegRules;
    StatusBar.SimpleText:=' Правил успешно создано : '+IntToStr(CountBlock);
  end;
  Msg.Result:=Integer(True);
end;

end.
