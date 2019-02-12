object ScanForm: TScanForm
  Left = 564
  Top = 255
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1077'...'
  ClientHeight = 426
  ClientWidth = 570
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
  OnShow = FormShow
  DesignSize = (
    570
    426)
  PixelsPerInch = 96
  TextHeight = 13
  object ScanLabel: TLabel
    Left = 80
    Top = 342
    Width = 474
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = '\\'
  end
  object lbXCORE: TLabel
    Left = 16
    Top = 396
    Width = 152
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Antivirus Scanner '#174' StalkerSTS'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lbFilesScanned: TLabel
    Left = 80
    Top = 323
    Width = 119
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1086#1074#1077#1088#1077#1085#1086' '#1086#1073#1098#1077#1082#1090#1086#1074': 0'
  end
  object btSaveReport: TButton
    Left = 273
    Top = 388
    Width = 91
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1086#1090#1095#1077#1090
    Default = True
    Enabled = False
    TabOrder = 0
    OnClick = btSaveReportClick
  end
  object btStop: TButton
    Left = 465
    Top = 388
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1057#1090#1086#1087
    TabOrder = 1
    OnClick = btStopClick
  end
  object ReportMemo: TRichEdit
    Left = 80
    Top = 16
    Width = 474
    Height = 300
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object ProgressBar1: TProgressBar
    Left = 80
    Top = 360
    Width = 474
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 3
  end
  object pnAction: TPanel
    Left = 13
    Top = 16
    Width = 56
    Height = 300
    AutoSize = True
    BevelOuter = bvNone
    Color = clBlack
    ParentBackground = False
    TabOrder = 4
    object Animate1: TAnimate
      Left = 0
      Top = 0
      Width = 56
      Height = 300
      Transparent = False
    end
  end
  object btPause: TButton
    Left = 369
    Top = 388
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1072#1091#1079#1072
    TabOrder = 5
    OnClick = btPauseClick
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.rtf'
    Filter = 'Report files|.rtf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofNoReadOnlyReturn, ofNoNetworkButton, ofNoDereferenceLinks, ofEnableIncludeNotify, ofEnableSizing, ofDontAddToRecent]
    OptionsEx = [ofExNoPlacesBar]
    Left = 5
    Top = 328
  end
  object CloseTimer: TTimer
    Enabled = False
    OnTimer = CloseTimerTimer
    Left = 40
    Top = 328
  end
end
