object Main: TMain
  Left = 192
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'App'
  ClientHeight = 323
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object AddBtn: TButton
    Left = 7
    Top = 271
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = AddBtnClick
  end
  object RemBtn: TButton
    Left = 87
    Top = 271
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 2
    OnClick = RemBtnClick
  end
  object CheckBtn: TButton
    Left = 167
    Top = 271
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '
    TabOrder = 3
    OnClick = CheckBtnClick
  end
  object FirewallBtn: TButton
    Left = 247
    Top = 271
    Width = 75
    Height = 25
    Caption = #1041#1088#1072#1085#1076#1084#1072#1091#1101#1088
    TabOrder = 4
    OnClick = FirewallBtnClick
  end
  object CloseBtn: TButton
    Left = 327
    Top = 271
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 5
    OnClick = CloseBtnClick
  end
  object SearchEdt: TEdit
    Left = 8
    Top = 246
    Width = 393
    Height = 21
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = #1055#1086#1080#1089#1082'...'
    OnChange = SearchEdtChange
    OnKeyDown = SearchEdtKeyDown
    OnKeyUp = SearchEdtKeyUp
    OnMouseDown = SearchEdtMouseDown
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 304
    Width = 409
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ListView: TListView
    Left = 8
    Top = 8
    Width = 393
    Height = 233
    Columns = <
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 176
      end
      item
        Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077
        Width = 194
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 7
    ViewStyle = vsReport
    OnDblClick = ListViewDblClick
    OnKeyDown = ListViewKeyDown
    OnKeyUp = ListViewKeyUp
    OnMouseDown = ListViewMouseDown
  end
  object OpenDialog: TOpenDialog
    Filter = '|*.exe'
    Left = 48
    Top = 32
  end
  object ImportDialog: TOpenDialog
    Filter = 'Firewall Easy|*.fer'
    Left = 80
    Top = 32
  end
  object ExportDialog: TSaveDialog
    DefaultExt = 'Firewall Easy|*.fer'
    Filter = 'Firewall Easy|*.fer'
    Left = 112
    Top = 32
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 32
    object RulesItem: TMenuItem
      Caption = #1055#1088#1072#1074#1080#1083#1072
      object ImportBtn: TMenuItem
        Caption = #1048#1084#1087#1086#1088#1090
        OnClick = ImportBtnClick
      end
      object ExportBtn: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090
        OnClick = ExportBtnClick
      end
    end
    object HelpItem: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object AboutBtn: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077'...'
        OnClick = AboutBtnClick
      end
    end
  end
end
