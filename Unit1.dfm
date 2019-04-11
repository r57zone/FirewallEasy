object Main: TMain
  Left = 192
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'App'
  ClientHeight = 320
  ClientWidth = 409
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
  object NameAppLbl: TLabel
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
  object AppPathLbl: TLabel
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
    Left = 7
    Top = 271
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 2
    OnClick = AddBtnClick
  end
  object RemBtn: TButton
    Left = 87
    Top = 271
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 3
    OnClick = RemBtnClick
  end
  object CheckBtn: TButton
    Left = 167
    Top = 271
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '
    TabOrder = 4
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
    TabOrder = 0
    TabWidth = 100
    OnKeyUp = ListBoxKeyUp
    OnMouseDown = ListBoxMouseDown
  end
  object FirewallBtn: TButton
    Left = 247
    Top = 271
    Width = 75
    Height = 25
    Caption = #1041#1088#1072#1085#1076#1084#1072#1091#1101#1088
    TabOrder = 5
    OnClick = FirewallBtnClick
  end
  object CloseBtn: TButton
    Left = 327
    Top = 271
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 6
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
    TabOrder = 1
    Text = #1055#1086#1080#1089#1082'...'
    OnChange = SearchEdtChange
    OnMouseDown = SearchEdtMouseDown
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 301
    Width = 409
    Height = 19
    Panels = <>
    SimplePanel = True
    OnClick = StatusBarClick
  end
  object OpenDialog: TOpenDialog
    Filter = '|*.exe'
    Left = 16
    Top = 32
  end
end
