object OpenDescForm: TOpenDescForm
  Left = 610
  Top = 153
  Width = 438
  Height = 478
  BorderIcons = [biSystemMenu]
  Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1086#1090#1082#1088#1099#1090#1099#1093' '#1076#1077#1089#1082#1088#1080#1087#1090#1086#1088#1086#1074' '#1092#1072#1081#1083#1086#1074
  Color = clBtnFace
  Constraints.MinHeight = 478
  Constraints.MinWidth = 438
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 408
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 0
    DesignSize = (
      430
      408)
    object Bevel4: TBevel
      Left = 8
      Top = 33
      Width = 414
      Height = 9
      Align = alTop
      Shape = bsSpacer
    end
    object TopPanel: TPanel
      Left = 8
      Top = 8
      Width = 414
      Height = 25
      Align = alTop
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 0
      object imgTopBk: TImage
        Left = 2
        Top = 2
        Width = 410
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
      object lbAutoRunExplorer: TLabel
        Left = 8
        Top = 5
        Width = 256
        Height = 13
        Alignment = taCenter
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1086#1090#1082#1088#1099#1090#1099#1093' '#1076#1077#1089#1082#1088#1080#1087#1090#1086#1088#1086#1074' '#1092#1072#1081#1083#1086#1074
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
    object OpenDescExplorer: TVirtualStringTree
      Left = 8
      Top = 42
      Width = 414
      Height = 358
      Align = alClient
      CheckImageKind = ckXP
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'MS Sans Serif'
      Header.Font.Style = []
      Header.Height = 17
      ScrollBarOptions.AlwaysVisible = True
      ScrollBarOptions.ScrollBars = ssVertical
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
      TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnBeforeCellPaint = OpenDescExplorerBeforeCellPaint
      OnDblClick = OpenDescExplorerDblClick
      OnGetText = OpenDescExplorerGetText
      OnGetImageIndex = OpenDescExplorerGetImageIndex
      OnMouseMove = OpenDescExplorerMouseMove
      OnResize = OpenDescExplorerResize
      Columns = <
        item
          Position = 0
          Width = 300
        end>
    end
    object pnProgress: TPanel
      Left = 32
      Top = 192
      Width = 361
      Height = 49
      Anchors = []
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 2
      Visible = False
      DesignSize = (
        361
        49)
      object lbDescProgress: TLabel
        Left = 8
        Top = 8
        Width = 301
        Height = 13
        Caption = #1048#1076#1077#1090' '#1087#1086#1083#1091#1095#1077#1085#1080#1077' '#1089#1087#1080#1089#1082#1072' '#1086#1090#1082#1088#1099#1090#1099#1093' '#1076#1077#1089#1082#1088#1080#1087#1090#1086#1088#1086#1074'...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object pbProgress: TProgressBar
        Left = 8
        Top = 24
        Width = 345
        Height = 16
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 408
    Width = 430
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      430
      39)
    object btClose: TButton
      Left = 340
      Top = 4
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Default = True
      TabOrder = 0
      OnClick = btCloseClick
    end
    object btRefresh: TButton
      Left = 252
      Top = 4
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 1
      OnClick = btRefreshClick
    end
    object btUnload: TButton
      Left = 8
      Top = 4
      Width = 81
      Height = 25
      Caption = #1042#1099#1075#1088#1091#1079#1080#1090#1100
      TabOrder = 2
      OnClick = btUnloadClick
    end
  end
end
