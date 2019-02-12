object ProferencesForm: TProferencesForm
  Left = 710
  Top = 250
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 349
  ClientWidth = 403
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
    403
    349)
  PixelsPerInch = 96
  TextHeight = 13
  object btApply: TButton
    Left = 319
    Top = 315
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1085#1103#1090#1100
    Default = True
    TabOrder = 0
    OnClick = btApplyClick
  end
  object btCansel: TButton
    Left = 239
    Top = 315
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = btCanselClick
  end
  object PreferencesPages: TPageControl
    Left = 8
    Top = 8
    Width = 386
    Height = 300
    ActivePage = GeneralTab
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object GeneralTab: TTabSheet
      Caption = #1043#1083#1072#1074#1085#1099#1077
      DesignSize = (
        378
        272)
      object imgScan: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object Bevel2: TBevel
        Left = 128
        Top = 143
        Width = 241
        Height = 2
      end
      object lbInfected: TLabel
        Left = 8
        Top = 136
        Width = 102
        Height = 13
        Caption = #1047#1072#1088#1072#1078#1077#1085#1085#1099#1077' '#1092#1072#1081#1083#1099
      end
      object imgInfected: TImage
        Left = 16
        Top = 160
        Width = 32
        Height = 32
        AutoSize = True
      end
      object spSelQuarantineDir: TSpeedButton
        Left = 345
        Top = 211
        Width = 22
        Height = 21
        Caption = '...'
        OnClick = spSelQuarantineDirClick
      end
      object cbScanInSubDir: TCheckBox
        Left = 56
        Top = 40
        Width = 313
        Height = 17
        Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1055#1086#1076#1082#1072#1090#1072#1083#1086#1075#1072#1093
        TabOrder = 0
      end
      object cbUseXForce: TCheckBox
        Left = 56
        Top = 56
        Width = 313
        Height = 17
        Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1090#1077#1093#1085#1086#1083#1086#1075#1080#1102' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1103' xForce'
        TabOrder = 1
      end
      object cbScanOnlyPE: TCheckBox
        Left = 56
        Top = 72
        Width = 313
        Height = 17
        Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' Windows PE '#1092#1072#1081#1083#1099
        TabOrder = 2
      end
      object cbScanArch: TCheckBox
        Left = 56
        Top = 88
        Width = 313
        Height = 17
        Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100' '#1040#1088#1093#1080#1074#1099' (RAR, ZIP)'
        TabOrder = 3
      end
      object rbReportOnly: TRadioButton
        Left = 56
        Top = 160
        Width = 313
        Height = 17
        Caption = #1058#1086#1083#1100#1082#1086' '#1054#1090#1095#1077#1090
        TabOrder = 4
      end
      object rbRemove: TRadioButton
        Left = 56
        Top = 176
        Width = 313
        Height = 17
        Caption = #1059#1076#1072#1083#1103#1090#1100
        TabOrder = 5
      end
      object rbQuarantine: TRadioButton
        Left = 56
        Top = 192
        Width = 313
        Height = 17
        Caption = #1055#1077#1088#1077#1084#1077#1097#1072#1090#1100' '#1074' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1102' '#1050#1072#1088#1072#1085#1090#1080#1085#1072':'
        TabOrder = 6
      end
      object edQuarantine: TEdit
        Left = 56
        Top = 211
        Width = 287
        Height = 21
        ImeName = 'Russian'
        TabOrder = 7
      end
      object cbUnloadInfected: TCheckBox
        Left = 56
        Top = 244
        Width = 313
        Height = 17
        Caption = #1042#1099#1075#1088#1091#1078#1072#1090#1100' '#1079#1072#1088#1072#1078#1077#1085#1085#1099#1077' '#1092#1072#1081#1083#1099' '#1080#1079' '#1057#1080#1089#1090#1077#1084#1085#1086#1081' '#1055#1072#1084#1103#1090#1080
        TabOrder = 8
      end
      object cbLoadUserDB: TCheckBox
        Left = 56
        Top = 104
        Width = 313
        Height = 17
        Caption = #1047#1072#1075#1088#1091#1078#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1080#1077' '#1041#1072#1079#1099' '#1057#1080#1075#1085#1072#1090#1091#1088
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 9
      end
      object TopPanel: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 10
        object imgTopBk: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbMain: TLabel
          Left = 8
          Top = 5
          Width = 160
          Height = 13
          Alignment = taCenter
          Caption = #1054#1073#1097#1080#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1082#1072#1085#1077#1088#1072
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
    object FilterTab: TTabSheet
      Caption = #1060#1080#1083#1100#1090#1088
      ImageIndex = 1
      DesignSize = (
        378
        272)
      object lbFilterInfo: TLabel
        Left = 56
        Top = 40
        Width = 313
        Height = 41
        AutoSize = False
        Caption = 
          #1044#1072#1085#1085#1099#1081' '#1089#1087#1080#1089#1086#1082' '#1074#1082#1083#1102#1095#1072#1077#1090' '#1101#1083#1083#1077#1084#1077#1085#1090#1099' '#1082#1086#1090#1086#1088#1099#1077' '#1073#1091#1076#1091#1090' '#1087#1088#1086#1074#1077#1088#1103#1090#1100#1089#1103' '#1085#1072' '#1085#1072 +
          #1083#1080#1095#1080#1077' '#1074#1080#1088#1091#1089#1086#1074' '#1087#1088#1080' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1080'. (".*" - '#1042#1082#1083#1102#1095#1072#1077#1090' '#1074#1089#1077' '#1092#1072#1081#1083#1099').'
        WordWrap = True
      end
      object imgFilter: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object ButtonPanel: TPanel
        Left = 56
        Top = 88
        Width = 313
        Height = 29
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
        DesignSize = (
          313
          29)
        object sbFilterDelete: TSpeedButton
          Left = 285
          Top = 2
          Width = 23
          Height = 22
          Anchors = [akTop, akRight]
          OnClick = sbFilterDeleteClick
        end
        object sbFilterAdd: TSpeedButton
          Left = 261
          Top = 2
          Width = 23
          Height = 22
          Anchors = [akTop, akRight]
          OnClick = sbFilterAddClick
        end
      end
      object lbFilter: TListBox
        Left = 56
        Top = 120
        Width = 313
        Height = 140
        Anchors = [akLeft, akTop, akRight, akBottom]
        ImeName = 'Russian'
        ItemHeight = 13
        TabOrder = 1
      end
      object TopPanel_2: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 2
        object imgTopBk_2: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbScanFilter: TLabel
          Left = 8
          Top = 5
          Width = 135
          Height = 13
          Alignment = taCenter
          Caption = #1060#1080#1083#1100#1090#1088' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1103
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
    object LimitsTab: TTabSheet
      Caption = #1054#1075#1088#1072#1085#1080#1095#1077#1085#1080#1103
      ImageIndex = 2
      DesignSize = (
        378
        272)
      object lbFileLimit: TLabel
        Left = 56
        Top = 48
        Width = 178
        Height = 13
        Caption = #1053#1077' '#1087#1088#1086#1074#1077#1088#1103#1090#1100' '#1060#1072#1081#1083#1099' '#1073#1086#1083#1100#1096#1077' (Mb):'
      end
      object lbArchLimit: TLabel
        Left = 56
        Top = 80
        Width = 179
        Height = 13
        Caption = #1053#1077' '#1087#1088#1086#1074#1077#1088#1103#1090#1100' '#1040#1088#1093#1080#1074#1099' '#1073#1086#1083#1100#1096#1077' (Mb):'
      end
      object ImgLimit: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object seFileLimit: TSpinEdit
        Left = 248
        Top = 44
        Width = 121
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 1024
      end
      object seArchLimit: TSpinEdit
        Left = 248
        Top = 76
        Width = 121
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 10
      end
      object TopPanel_3: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 2
        object imgTopBk_3: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbLimits: TLabel
          Left = 8
          Top = 5
          Width = 144
          Height = 13
          Alignment = taCenter
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1086#1075#1088#1072#1085#1080#1095#1077#1085#1080#1081
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
    object LocationsTab: TTabSheet
      Caption = #1055#1091#1090#1080
      ImageIndex = 3
      DesignSize = (
        378
        272)
      object imgFolders: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object lbDataBase: TLabel
        Left = 56
        Top = 44
        Width = 136
        Height = 13
        Caption = #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1041#1072#1079' '#1057#1080#1075#1085#1072#1090#1091#1088':'
      end
      object sbSelDB: TSpeedButton
        Left = 345
        Top = 59
        Width = 22
        Height = 21
        Caption = '...'
        OnClick = sbSelDBClick
      end
      object sbSelTemp: TSpeedButton
        Left = 345
        Top = 107
        Width = 22
        Height = 21
        Caption = '...'
        OnClick = sbSelTempClick
      end
      object lbTemp: TLabel
        Left = 56
        Top = 92
        Width = 125
        Height = 13
        Caption = #1042#1088#1077#1084#1077#1085#1085#1072#1103' '#1044#1080#1088#1077#1082#1090#1086#1088#1080#1103':'
      end
      object lbReportLoc: TLabel
        Left = 8
        Top = 136
        Width = 67
        Height = 13
        Caption = #1060#1072#1081#1083' '#1054#1090#1095#1077#1090#1072
      end
      object Bevel6: TBevel
        Left = 88
        Top = 143
        Width = 281
        Height = 2
      end
      object imgReport: TImage
        Left = 16
        Top = 160
        Width = 32
        Height = 32
        AutoSize = True
      end
      object sbSelReport: TSpeedButton
        Left = 345
        Top = 179
        Width = 22
        Height = 21
        Caption = '...'
        OnClick = sbSelReportClick
      end
      object lbReport: TLabel
        Left = 56
        Top = 164
        Width = 95
        Height = 13
        Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1086#1090#1095#1077#1090' '#1074':'
      end
      object edDataBase: TEdit
        Left = 56
        Top = 59
        Width = 287
        Height = 21
        ImeName = 'Russian'
        TabOrder = 0
      end
      object edTemp: TEdit
        Left = 56
        Top = 107
        Width = 287
        Height = 21
        ImeName = 'Russian'
        TabOrder = 1
      end
      object edReport: TEdit
        Left = 56
        Top = 179
        Width = 287
        Height = 21
        ImeName = 'Russian'
        TabOrder = 2
      end
      object TopPanel_4: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 3
        object imgTopBk_4: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbPathes: TLabel
          Left = 8
          Top = 5
          Width = 192
          Height = 13
          Alignment = taCenter
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1080#1089#1087#1086#1083#1100#1079#1091#1077#1084#1099#1093' '#1087#1091#1090#1077#1081
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
    object UpdateTab: TTabSheet
      Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077
      ImageIndex = 4
      DesignSize = (
        378
        272)
      object imgUpdate: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object lbUpdateURL: TLabel
        Left = 56
        Top = 44
        Width = 152
        Height = 13
        Caption = #1054#1073#1085#1086#1074#1083#1103#1090#1100' '#1041#1072#1079#1099' '#1057#1080#1075#1085#1072#1090#1091#1088' '#1080#1079':'
      end
      object lbDefaultURL: TLabel
        Left = 272
        Top = 88
        Width = 70
        Height = 13
        Cursor = crHandPoint
        Caption = #1055#1086#1091#1084#1086#1083#1095#1072#1085#1080#1102
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = lbDefaultURLClick
      end
      object edUpdate: TEdit
        Left = 56
        Top = 59
        Width = 289
        Height = 21
        ImeName = 'Russian'
        TabOrder = 0
      end
      object TopPanel_5: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 1
        object imgTopBk_5: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbUpdate: TLabel
          Left = 8
          Top = 5
          Width = 192
          Height = 13
          Alignment = taCenter
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1077#1088#1074#1077#1088#1072' '#1086#1073#1085#1086#1074#1083#1077#1085#1080#1081
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
    object PriorityTab: TTabSheet
      Caption = #1055#1088#1080#1086#1088#1080#1090#1077#1090
      ImageIndex = 5
      DesignSize = (
        378
        272)
      object imgPriority: TImage
        Left = 16
        Top = 40
        Width = 32
        Height = 32
        AutoSize = True
      end
      object lbSelPriority: TLabel
        Left = 56
        Top = 43
        Width = 171
        Height = 13
        Caption = #1055#1088#1080#1086#1088#1080#1090#1077#1090' '#1087#1086#1090#1086#1082#1072' '#1057#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1103':'
        WordWrap = True
      end
      object cbPriority: TComboBox
        Left = 256
        Top = 40
        Width = 113
        Height = 21
        Style = csDropDownList
        ImeName = 'Russian'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 0
        Text = 'Normal'
        Items.Strings = (
          'Normal'
          'Low')
      end
      object TopPanel_6: TPanel
        Left = 8
        Top = 8
        Width = 361
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        ParentBackground = False
        TabOrder = 1
        object imgTopBk_6: TImage
          Left = 2
          Top = 2
          Width = 357
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
        object lbPriority: TLabel
          Left = 8
          Top = 5
          Width = 225
          Height = 13
          Alignment = taCenter
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1088#1080#1086#1088#1080#1090#1077#1090#1072' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1103
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
  object SaveDialog: TSaveDialog
    DefaultExt = '.txt'
    FileName = 'Report.txt'
    Filter = 'Text files|.txt'
    Left = 12
    Top = 312
  end
end
