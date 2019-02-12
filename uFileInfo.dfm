object FileInfoForm: TFileInfoForm
  Left = 673
  Top = 335
  BorderStyle = bsDialog
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1092#1072#1081#1083#1077
  ClientHeight = 423
  ClientWidth = 371
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  DesignSize = (
    371
    423)
  PixelsPerInch = 96
  TextHeight = 13
  object lbFullDelete: TLabel
    Left = 8
    Top = 395
    Width = 148
    Height = 13
    Cursor = crHandPoint
    Caption = #1054#1090#1083#1086#1078#1077#1085#1085#1086#1077' '#1091#1076#1072#1083#1077#1085#1080#1077' '#1092#1072#1081#1083#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lbFullDeleteClick
  end
  object btClose: TButton
    Left = 286
    Top = 389
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    Default = True
    TabOrder = 0
    OnClick = btCloseClick
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 353
    Height = 374
    ActivePage = InformationTab
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object InformationTab: TTabSheet
      Caption = #1048#1085#1092#1086#1088#1084#1072#1088#1094#1080#1103
      DesignSize = (
        345
        346)
      object imgFileIcon: TImage
        Left = 8
        Top = 40
        Width = 41
        Height = 41
        Center = True
      end
      object lbFileName: TLabel
        Left = 56
        Top = 40
        Width = 60
        Height = 13
        Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072':'
      end
      object lbPath: TLabel
        Left = 56
        Top = 64
        Width = 69
        Height = 13
        Caption = #1056#1072#1079#1084#1077#1097#1077#1085#1080#1077':'
      end
      object lbSize: TLabel
        Left = 56
        Top = 120
        Width = 42
        Height = 13
        Caption = #1056#1072#1079#1084#1077#1088':'
      end
      object lbMd5: TLabel
        Left = 56
        Top = 264
        Width = 27
        Height = 13
        Caption = #1052#1044'5:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Bevel2: TBevel
        Left = 56
        Top = 287
        Width = 281
        Height = 2
      end
      object imgAttributes: TImage
        Left = 8
        Top = 296
        Width = 41
        Height = 41
        Center = True
      end
      object lbFileChanged: TLabel
        Left = 56
        Top = 176
        Width = 49
        Height = 13
        Caption = #1048#1079#1084#1077#1085#1077#1085':'
      end
      object lbFileCreated: TLabel
        Left = 56
        Top = 152
        Width = 40
        Height = 13
        Caption = #1057#1086#1079#1076#1072#1085':'
      end
      object lbFileOpened: TLabel
        Left = 56
        Top = 200
        Width = 41
        Height = 13
        Caption = #1054#1090#1082#1088#1099#1090':'
      end
      object Label4: TLabel
        Left = 56
        Top = 96
        Width = 57
        Height = 13
        Caption = #1058#1080#1087' '#1092#1072#1081#1083#1072':'
      end
      object Bevel3: TBevel
        Left = 56
        Top = 87
        Width = 281
        Height = 2
      end
      object Bevel1: TBevel
        Left = 56
        Top = 143
        Width = 281
        Height = 2
      end
      object edFMD5: TEdit
        Left = 136
        Top = 264
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object edFSize: TEdit
        Left = 136
        Top = 120
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 1
      end
      object edFPath: TEdit
        Left = 136
        Top = 64
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 2
      end
      object edFName: TEdit
        Left = 136
        Top = 40
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 3
      end
      object cbHidden: TCheckBox
        Left = 56
        Top = 296
        Width = 137
        Height = 17
        Caption = #1057#1082#1088#1099#1090#1099#1081
        Enabled = False
        TabOrder = 4
      end
      object cbReadOnly: TCheckBox
        Left = 56
        Top = 320
        Width = 137
        Height = 17
        Caption = #1058#1086#1083#1100#1082#1086' '#1095#1090#1077#1085#1080#1077
        Enabled = False
        TabOrder = 5
      end
      object cbSystem: TCheckBox
        Left = 200
        Top = 296
        Width = 137
        Height = 17
        Caption = #1057#1080#1089#1090#1077#1084#1085#1099#1081
        Enabled = False
        TabOrder = 6
      end
      object edFileCreate: TEdit
        Left = 136
        Top = 152
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 7
      end
      object edFileChange: TEdit
        Left = 136
        Top = 176
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 8
      end
      object edFileLastAcces: TEdit
        Left = 136
        Top = 200
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 9
      end
      object cbArchive: TCheckBox
        Left = 200
        Top = 320
        Width = 137
        Height = 17
        Caption = #1040#1088#1093#1080#1074#1085#1099#1081
        Enabled = False
        TabOrder = 10
      end
      object edFileType: TEdit
        Left = 136
        Top = 96
        Width = 201
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = bsNone
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 11
      end
      object TopPanel: TPanel
        Left = 8
        Top = 8
        Width = 329
        Height = 25
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 12
        object imgTopBk: TImage
          Left = 2
          Top = 2
          Width = 325
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
        object lbInformation: TLabel
          Left = 8
          Top = 5
          Width = 171
          Height = 13
          Alignment = taCenter
          Caption = #1054#1073#1097#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1092#1072#1081#1083#1077
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
    object PEInformationTab: TTabSheet
      BorderWidth = 8
      Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1072#1103' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1103
      ImageIndex = 1
      object Bevel4: TBevel
        Left = 0
        Top = 25
        Width = 329
        Height = 9
        Align = alTop
        Shape = bsSpacer
      end
      object PEInfoMemo: TMemo
        Left = 0
        Top = 34
        Width = 329
        Height = 296
        Align = alClient
        Lines.Strings = (
          'PEInfoMemo')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object TopPanel_2: TPanel
        Left = 0
        Top = 0
        Width = 329
        Height = 25
        Align = alTop
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 1
        object imgTopBk_2: TImage
          Left = 2
          Top = 2
          Width = 325
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
        object lbPe: TLabel
          Left = 8
          Top = 5
          Width = 200
          Height = 13
          Alignment = taCenter
          Caption = #1055#1086#1076#1088#1086#1073#1085#1099#1077' '#1089#1074#1077#1076#1077#1085#1080#1103' '#1086' PE '#1092#1072#1081#1083#1077
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
  end
  object btHexView: TButton
    Left = 207
    Top = 389
    Width = 75
    Height = 25
    Caption = 'HEX View'
    TabOrder = 2
    OnClick = btHexViewClick
  end
end
