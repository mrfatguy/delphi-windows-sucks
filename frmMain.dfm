object MainForm: TMainForm
  Left = 241
  Top = 166
  AutoScroll = False
  Caption = 'Windows Sucks! 1.00'
  ClientHeight = 481
  ClientWidth = 825
  Color = clBtnFace
  Constraints.MinHeight = 519
  Constraints.MinWidth = 801
  Font.Charset = EASTEUROPE_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 825
    Height = 481
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      825
      481)
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 693
      Height = 16
      AutoSize = False
      Caption = 
        'Choose a folder by clicking on the [...] button. Then select dat' +
        'e for each file, by clicking in any date column in grid below.'
      Transparent = False
    end
    object lblTimeZone: TLabel
      Left = 8
      Top = 433
      Width = 472
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 
        'Time in EXIF record can be shifted. If so - set correct GMT offs' +
        'et, using list below:'
      Transparent = False
    end
    object gbFile: TGroupBox
      Left = 8
      Top = 28
      Width = 809
      Height = 45
      Anchors = [akLeft, akTop, akRight]
      Caption = ' Folder '
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      DesignSize = (
        809
        45)
      object lblDir: TLabel
        Left = 8
        Top = 17
        Width = 766
        Height = 19
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'C:\'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object btnSelectDir: TButton
        Left = 779
        Top = 14
        Width = 25
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '...'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = btnSelectDirClick
      end
    end
    object sgSummary: TStringGrid
      Left = 8
      Top = 80
      Width = 808
      Height = 348
      Anchors = [akLeft, akTop, akRight, akBottom]
      DefaultColWidth = 130
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      GridLineWidth = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      TabOrder = 1
      OnDrawCell = sgSummaryDrawCell
      OnSelectCell = sgSummarySelectCell
      ColWidths = (
        130
        130
        130
        130
        130)
    end
    object btnGo: TButton
      Left = 743
      Top = 443
      Width = 75
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = 'Start!'
      Default = True
      Enabled = False
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = btnGoClick
    end
    object btnCancel: TButton
      Left = 663
      Top = 443
      Width = 75
      Height = 33
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object cbTimeZone: TComboBox
      Left = 8
      Top = 451
      Width = 569
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akBottom]
      Enabled = False
      ItemHeight = 16
      TabOrder = 4
      OnChange = cbTimeZoneChange
    end
    object btnAbout: TButton
      Left = 583
      Top = 443
      Width = 75
      Height = 33
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'About...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = btnAboutClick
    end
  end
  object pnlProcess: TPanel
    Left = 80
    Top = 220
    Width = 665
    Height = 37
    TabOrder = 0
    Visible = False
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 73
      Height = 16
      Caption = 'Processing...'
    end
    object pbMain: TProgressBar
      Left = 88
      Top = 6
      Width = 489
      Height = 25
      TabOrder = 0
    end
    object btnAbort: TButton
      Left = 584
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Abort!'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnAbortClick
    end
  end
end
