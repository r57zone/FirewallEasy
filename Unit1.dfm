object Main: TMain
  Left = 192
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'App'
  ClientHeight = 320
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object NameLabel: TLabel
    Left = 9
    Top = 8
    Width = 50
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object PathLabel: TLabel
    Left = 160
    Top = 8
    Width = 75
    Height = 13
    Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object AddBtn: TButton
    Left = 8
    Top = 271
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = AddBtnClick
  end
  object RemoveBtn: TButton
    Left = 88
    Top = 271
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 1
    OnClick = RemoveBtnClick
  end
  object CheckBtn: TButton
    Left = 168
    Top = 271
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '
    TabOrder = 2
    OnClick = CheckBtnClick
  end
  object ListBox: TListBox
    Left = 8
    Top = 24
    Width = 393
    Height = 217
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    TabWidth = 100
    OnKeyUp = ListBoxKeyUp
    OnMouseDown = ListBoxMouseDown
  end
  object FirewallBtn: TButton
    Left = 248
    Top = 271
    Width = 75
    Height = 25
    Caption = #1041#1088#1072#1085#1076#1084#1072#1091#1101#1088
    TabOrder = 4
    OnClick = FirewallBtnClick
  end
  object CloseBtn: TButton
    Left = 328
    Top = 271
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 5
    OnClick = CloseBtnClick
  end
  object Search: TEdit
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
    TabOrder = 6
    Text = #1055#1086#1080#1089#1082'...'
    OnChange = SearchChange
    OnMouseDown = SearchMouseDown
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 301
    Width = 408
    Height = 19
    Panels = <>
    SimplePanel = True
    OnClick = StatusBarClick
  end
  object OpenDialog: TOpenDialog
    Filter = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077' (.exe) '#1080' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1080' (.dll)|*.exe;*.dll'
    Left = 16
    Top = 32
  end
  object PopupMenu: TPopupMenu
    Left = 48
    Top = 32
    object N1: TMenuItem
      Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1092#1072#1081#1083#1072
    end
  end
end
