object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 382
  ClientWidth = 565
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 336
    Width = 5
    Height = 18
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object MainMenu: TMainMenu
    Left = 472
    Top = 16
    object Juego1: TMenuItem
      Caption = 'Juego'
      object Jugar: TMenuItem
        Caption = '&Jugar'
        OnClick = JugarClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Salir: TMenuItem
        Caption = '&Salir'
        OnClick = SalirClick
      end
    end
  end
end
