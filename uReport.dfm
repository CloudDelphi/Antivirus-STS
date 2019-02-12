object ReportForm: TReportForm
  Left = 541
  Top = 317
  Width = 497
  Height = 399
  BorderIcons = [biSystemMenu]
  Caption = #1054#1090#1095#1077#1090
  Color = clBtnFace
  Constraints.MinHeight = 399
  Constraints.MinWidth = 497
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 489
    Height = 329
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 0
    object Bevel4: TBevel
      Left = 8
      Top = 33
      Width = 473
      Height = 9
      Align = alTop
      Shape = bsSpacer
    end
    object ReportMemo: TRichEdit
      Left = 8
      Top = 42
      Width = 473
      Height = 279
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object TopPanel: TPanel
      Left = 8
      Top = 8
      Width = 473
      Height = 25
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 1
      object imgTopBk: TImage
        Left = 2
        Top = 2
        Width = 469
        Height = 21
        Align = alClient
        Picture.Data = {
          07544269746D6170D6000000424DD60000000000000036000000280000000200
          0000140000000100180000000000A00000000000000000000000000000000000
          0000CAD2D6CAD2D60000CDD4D8CDD4D80000CFD6DACFD6DA0000D2D8DCD2D8DC
          0000D5DBDED5DBDE0000D7DDE0D7DDE00000DADFE2DADFE20000DCE1E4DCE1E4
          0000DFE4E6DFE4E60000E2E6E8E2E6E80000E4E8EAE4E8EA0000E7EAECE7EAEC
          0000EAEDEEEAEDEE0000ECEFF0ECEFF00000EFF1F2EFF1F20000F1F3F4F1F3F4
          0000F4F6F6F4F6F60000F7F8F8F7F8F80000F9FAFAF9FAFA0000FCFCFCFCFCFC
          0000}
        Stretch = True
      end
      object lbReport: TLabel
        Left = 8
        Top = 5
        Width = 191
        Height = 13
        Alignment = taCenter
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1086#1090#1095#1077#1090#1072' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 329
    Width = 489
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      489
      39)
    object btClose: TButton
      Left = 399
      Top = 4
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Default = True
      TabOrder = 0
      OnClick = btCloseClick
    end
    object btClear: TButton
      Left = 311
      Top = 4
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 1
      OnClick = btClearClick
    end
  end
end
