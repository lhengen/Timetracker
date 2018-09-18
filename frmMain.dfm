object MainForm: TMainForm
  Left = 0
  Top = 0
  ActiveControl = edActivityDescription
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Enter Activity'
  ClientHeight = 128
  ClientWidth = 645
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 21
    Width = 174
    Height = 13
    Caption = 'Enter Description of Current Activity'
  end
  object btOk: TButton
    Left = 526
    Top = 88
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btOkClick
  end
  object btIgnore: TButton
    Left = 445
    Top = 88
    Width = 75
    Height = 25
    Caption = '&Ignore'
    TabOrder = 1
    OnClick = btIgnoreClick
  end
  object edActivityDescription: TComboBoxEx
    Left = 32
    Top = 40
    Width = 569
    Height = 22
    ItemsEx = <>
    TabOrder = 2
  end
  object PopupMenu1: TPopupMenu
    Left = 312
    Top = 64
    object mnuOpen: TMenuItem
      Caption = '&Open'
      OnClick = mnuOpenClick
    end
    object mnuOpenLog: TMenuItem
      Caption = 'Open &Log'
      OnClick = mnuOpenLogClick
    end
    object mnuShowFolderinExplorer: TMenuItem
      Caption = 'Show Folder in Explorer'
      OnClick = mnuShowFolderinExplorerClick
    end
    object Exit1: TMenuItem
      Caption = 'E&xit'
      OnClick = Exit1Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 384
    Top = 72
  end
end
