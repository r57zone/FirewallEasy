object Form1: TForm1
  Left = 192
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1076#1086#1089#1090#1091#1087#1086#1084' '#1074' '#1080#1085#1090#1077#1088#1085#1077#1090
  ClientHeight = 307
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 69
    Height = 13
    Caption = #1052#1086#1080' '#1087#1088#1072#1074#1080#1083#1072':'
  end
  object Button1: TButton
    Left = 8
    Top = 256
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 256
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 168
    Top = 256
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '
    TabOrder = 2
    OnClick = Button3Click
  end
  object ListBox1: TListBox
    Left = 8
    Top = 32
    Width = 394
    Height = 217
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    TabWidth = 125
    OnMouseDown = ListBox1MouseDown
  end
  object Button4: TButton
    Left = 248
    Top = 256
    Width = 75
    Height = 25
    Caption = #1041#1088#1072#1085#1076#1084#1072#1091#1101#1088
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 328
    Top = 256
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 5
    OnClick = Button5Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 288
    Width = 410
    Height = 19
    Panels = <>
    SimplePanel = True
    OnClick = StatusBar1Click
  end
  object XPManifest1: TXPManifest
    Left = 8
    Top = 8
  end
  object OpenDialog1: TOpenDialog
    Filter = #1055#1088#1080#1083#1086#1078#1077#1085#1080#1077' (.exe) '#1080' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1080' (.dll)|*.exe;*.dll'
    Left = 40
    Top = 8
  end
end
