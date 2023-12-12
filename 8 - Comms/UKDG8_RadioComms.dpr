program UKDG8_RadioComms;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  RadioBase in 'RadioBase.pas',
  RadioWindows in 'RadioWindows.pas',
  radio in 'radio.pas',
  RadioAndroid in 'RadioAndroid.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
