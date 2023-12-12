unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Sensors, FMX.Controls.Presentation, FMX.StdCtrls,
{$IFDEF ANDROID}
  Androidapi.JNIBridge, Androidapi.Helpers, AndroidAPI.jni.OS, System.Permissions,
{$ENDIF}
  System.Sensors.Components, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TForm1 = class(TForm)
    LocationSensor1: TLocationSensor;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
{$IFDEF ANDROID}
    Memo1.Lines.Add('Requesting Location Permission');

    PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
            if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then begin
                Memo1.Lines.Add('Location Permission Given');
                LocationSensor1.Active := True;
            end else begin
                Memo1.Lines.Add('Location Permission NOT Given');
            end;
        end);
{$ENDIF}
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    Memo1.Lines.Add(FormatFloat('0.00000', LocationSensor1.Sensor.Latitude) + ', ' + FormatFloat('0.00000', LocationSensor1.Sensor.Longitude));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    LocationSensor1.Active := False;
end;

end.
