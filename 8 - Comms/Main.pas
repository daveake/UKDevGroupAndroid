unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Radio, RadioBase,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Ani;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    FloatAnimation1: TFloatAnimation;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    RadioModule: TRadio;
    procedure RadioCallback(Status: TRadioStatus; Source, Target, Content: String);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
    DeviceName, Callsign: String;
begin
{$IFDEF MSWINDOWS}
  DeviceName := 'COM4';
  Callsign := 'WINDOWS';
{$ENDIF}
{$IFDEF ANDROID}
  DeviceName := 'HAB BT';
  Callsign := 'ANDROID';
{$ENDIF}

    RadioModule := TRadio.Create(DeviceName, Callsign, 1, 2, RadioCallback);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
    RadioModule.SetFrequency(434.500 + TButton(Sender).Tag * 0.025);
end;

procedure TForm1.RadioCallback(Status: TRadioStatus; Source, Target, Content: String);
begin
    Memo1.Lines.Add(Content);
    Memo1.SelStart := Length(Memo1.text);
end;


end.
