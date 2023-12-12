unit radio;

interface

uses
  RadioWindows, RadioAndroid, RadioBase;

type
{$IFDEF MSWINDOWS}
  TRadio = class(TRadioWindows)
{$ENDIF}
{$IFDEF ANDROID}
  TRadio = class(TRadioAndroid)
{$ENDIF}
  private
    { Private declarations }
  protected
    { Protected declarations }
    // procedure Execute; override;
  public
    { Public declarations }
  end;

implementation

end.
