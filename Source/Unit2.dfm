object Settings: TSettings
  Left = 192
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 97
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object AddUnblockContextMenuCB: TCheckBox
    Left = 37
    Top = 16
    Width = 265
    Height = 33
    Caption = #1056#1072#1079#1073#1083#1086#1082#1080#1088#1086#1074#1072#1090#1100'  '#1076#1086#1089#1090#1091#1087' '#1074' '#1080#1085#1090#1077#1088#1085#1077#1090' '#1074' '#1082#1086#1085#1090#1077#1082#1089#1090#1085#1086#1084' '#1084#1077#1085#1102
    TabOrder = 0
    WordWrap = True
  end
  object ApplyBtn: TButton
    Left = 65
    Top = 64
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 1
    OnClick = ApplyBtnClick
  end
  object CancelBtn: TButton
    Left = 145
    Top = 64
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = CancelBtnClick
  end
end
