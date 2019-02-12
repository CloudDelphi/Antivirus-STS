object Form1: TForm1
  Left = 195
  Top = 282
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DataBase Create  v1.0.0.0   -= StalkerSTS =-'
  ClientHeight = 320
  ClientWidth = 1015
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 329
    Top = 125
    Width = 8
    Height = 16
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DBListView: TListView
    Left = 0
    Top = 0
    Width = 1015
    Height = 113
    Align = alTop
    Columns = <
      item
        Caption = #1058#1080#1087
      end
      item
        Caption = #1048#1084#1103
        Width = 150
      end
      item
        Caption = #1057#1080#1075#1085#1072#1090#1091#1088#1072
        Width = 250
      end
      item
        Caption = #1056#1072#1079#1084#1077#1088
        Width = 150
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object btn1: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 1
    OnClick = btn1Click
  end
  object ProgressBar1: TProgressBar
    Left = 752
    Top = 135
    Width = 287
    Height = 17
    TabOrder = 2
    Visible = False
  end
  object btn2: TButton
    Left = 88
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 3
    OnClick = btn2Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 301
    Width = 1015
    Height = 19
    Panels = <
      item
        Width = 400
      end
      item
        Width = 400
      end
      item
        Width = 50
      end>
  end
  object btn3: TButton
    Left = 168
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 5
    OnClick = btn3Click
  end
  object grp1: TGroupBox
    Left = 0
    Top = 148
    Width = 1015
    Height = 153
    Align = alBottom
    Caption = 'New Virus'
    TabOrder = 6
    object ReportMemo: TRichEdit
      Left = 2
      Top = 15
      Width = 1011
      Height = 136
      Align = alClient
      ImeName = 'Russian'
      TabOrder = 0
    end
  end
  object DelVir: TButton
    Left = 248
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 7
    OnClick = DelVirClick
  end
end
