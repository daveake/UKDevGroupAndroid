unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Sensors, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Sensors.Components, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
{$IFDEF ANDROID}
  Androidapi.JNIBridge, Androidapi.Helpers, AndroidAPI.jni.OS, System.Permissions,
{$ENDIF}
  FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes, FMX.TMSFNCCustomControl, FMX.TMSFNCWebBrowser,
  FMX.TMSFNCMaps, FMX.TMSFNCMapsCommonTypes;

type
  TForm1 = class(TForm)
    LocationSensor1: TLocationSensor;
    Button1: TButton;
    TMSFNCMaps1: TTMSFNCMaps;
    procedure Button1Click(Sender: TObject);
    procedure LocationSensor1LocationChanged(Sender: TObject;
      const OldLocation, NewLocation: TLocationCoord2D);
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
    PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
            if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then begin
                LocationSensor1.Active := True;
            end;
        end);
{$ELSE}
    LocationSensor1.Active := True;
{$ENDIF}
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
    Marker: TTMSFNCMapsMarker;
begin
    if TMSFNCMaps1.Markers.Count > 0 then begin
        Marker := TMSFNCMaps1.Markers[0];
    end else begin
        Marker := TMSFNCMaps1.Markers.Add;
    end;

    Marker.Latitude := NewLocation.Latitude;
    Marker.Longitude := NewLocation.Longitude;

    TMSFNCMaps1.SetCenterCoordinate(NewLocation.Latitude, NewLocation.Longitude);
end;

end.
