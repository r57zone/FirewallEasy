object Form1: TForm1
  Left = 192
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1076#1086#1089#1090#1091#1087#1086#1084' '#1074' '#1080#1085#1090#1077#1088#1085#1077#1090
  ClientHeight = 365
  ClientWidth = 411
  Color = clWhite
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 7
    Top = 8
    Width = 76
    Height = 25
    Caption = #1055#1088#1072#1074#1080#1083#1072
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clGray
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 9
    Top = 40
    Width = 60
    Height = 17
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 200
    Top = 40
    Width = 92
    Height = 17
    Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 8
    Top = 315
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 315
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 168
    Top = 315
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '
    TabOrder = 2
    OnClick = Button3Click
  end
  object ListBox1: TListBox
    Left = 8
    Top = 60
    Width = 393
    Height = 217
    BorderStyle = bsNone
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 17
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    TabWidth = 110
    OnKeyUp = ListBox1KeyUp
    OnMouseDown = ListBox1MouseDown
  end
  object Button4: TButton
    Left = 248
    Top = 315
    Width = 75
    Height = 25
    Caption = #1041#1088#1072#1085#1076#1084#1072#1091#1101#1088
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 328
    Top = 315
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 5
    OnClick = Button5Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 346
    Width = 411
    Height = 19
    Panels = <>
    ParentShowHint = False
    ShowHint = True
    SimplePanel = True
    OnClick = StatusBar1Click
  end
  object Edit1: TEdit
    Left = 9
    Top = 285
    Width = 393
    Height = 25
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clSilver
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    Text = #1055#1086#1080#1089#1082'...'
    OnChange = Edit1Change
    OnKeyDown = Edit1KeyDown
    OnMouseDown = Edit1MouseDown
  end
  object XPManifest1: TXPManifest
    Left = 48
    Top = 104
  end
  object OpenDialog1: TOpenDialog
    Filter = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077' (.exe) '#1080' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1080' (.dll)|*.exe;*.dll'
    Left = 168
    Top = 120
  end
  object PopupMenu1: TPopupMenu
    Left = 200
    Top = 88
    object N1: TMenuItem
      Caption = #1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1092#1072#1081#1083#1072
    end
  end
end
