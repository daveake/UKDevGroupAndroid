unit RadioAndroid;

interface

{$IFDEF ANDROID}

uses  Classes, SysUtils,
      Androidapi.JNIBridge, Androidapi.Jni.App, Androidapi.Jni.JavaTypes, Androidapi.Helpers,
      Androidapi.Jni.Widget, Androidapi.Jni.Os, Androidapi.Jni,
      System.Bluetooth, System.Bluetooth.Components,
      System.Types, System.Permissions,
      RadioBase;


type
  TRadioAndroid = class(TRadioBase)
  private
    { Private declarations }
    Line: String;
  procedure Initialise;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  end;

{$ENDIF}

implementation

{$IFDEF ANDROID}

function SelectDevice(Bluetooth1: TBluetooth; DeviceName: String): Integer;
var
    i: Integer;
begin
    Result := -1;

    if Bluetooth1.LastPairedDevices <> nil then begin
        for i := 0 to Bluetooth1.LastPairedDevices.Count-1 do begin
            // if DeviceName = IntToStr(Ord(Bluetooth1.LastPairedDevices[i].State)) + ': ' + Bluetooth1.LastPairedDevices[i].DeviceName + ' - ' + Bluetooth1.LastPairedDevices[i].Address then begin
            if DeviceName = Bluetooth1.LastPairedDevices[i].DeviceName then begin
                Result := i;
                Exit;
            end;
        end;
    end;
end;

function FindService(LServices: TBluetoothServiceList): Integer;
var
    i: Integer;
begin
    Result := -1;

    for i := 0 to LServices.Count-1 do begin
        if Pos('SerialPort', LServices[i].Name) > 0 then begin
            Result := i;
            Exit;
        end;
    end;
end;

procedure TRadioAndroid.Execute;
const
    cPermissionBluetooth = 'android.permission.BLUETOOTH';
    cPermissionBluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';
    cPermissionBluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';
    cPermissionBluetoothScan = 'android.permission.BLUETOOTH_SCAN';
begin
    inherited;

    SyncCallback(rsInfo, '', '', 'Obtaining Perrmissions');

    PermissionsService.RequestPermissions([cPermissionBluetooth, cPermissionBluetoothConnect, cPermissionBluetoothScan, JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
        end);

    Initialise;
end;

procedure TRadioAndroid.Initialise;
var
    i, DeviceIndex, ServiceIndex: Integer;
    Connected: Boolean;
    Bytes: TBytes;
    Temp, Line, Command: String;
    Bluetooth1: TBluetooth;
    LDevice: TBluetoothDevice;
    LServices: TBluetoothServiceList;
    FSocket: TBluetoothSocket;
    Guid: TGUID;
begin
    SyncCallback(rsInfo, '', '', 'Loading Bluetooth Component');

    Bluetooth1 := TBluetooth.Create(nil);

    SyncCallback(rsInfo, '', '', 'Loaded Bluetooth Component');

    Bluetooth1.Enabled := True;

    SyncCallback(rsInfo, '', '', 'Enabled Bluetooth Component');

    while not Terminated do begin
        SyncCallback(rsConnecting, '', '', 'Connecting to ' + RadioSettings.DeviceName + ' ...');

            // Get device
        DeviceIndex := SelectDevice(Bluetooth1, RadioSettings.DeviceName);

        if DeviceIndex < 0 then begin
            SyncCallback(rsDisconnected, '', '', 'Cannot Find Device');
        end else begin
            SyncCallback(rsConnecting, '', '', 'Getting device services ...');

            LDevice := nil;
            LServices := nil;

            LDevice := Bluetooth1.LastPairedDevices[DeviceIndex];

            LServices := LDevice.GetServices;

            ServiceIndex := FindService(LServices);

            if ServiceIndex < 0 then begin
                SyncCallback(rsDisconnected, '', '', 'Device has no serial service');
            end else begin
                SyncCallback(rsConnecting, '', '', 'Device has serial service');

                Guid := LServices[ServiceIndex].UUID;

                // Now open socket
                FSocket := LDevice.CreateClientSocket(Guid, True);

                try
                    SyncCallback(rsConnecting, '', '', 'Attempting Connection');
                    FSocket.Connect;
                    Connected := True;
                    SyncCallback(rsConnected, '', '', 'Connected To Device');
                except
                    SyncCallback(rsDisconnected, '', '', 'Cannot Connect To Device');
                end;

                if FSocket.Connected then begin
                    Line := '';

                    // while (not Terminated) and (not GetGroupChangedFlag(GroupName)) and Connected and (DeviceName = GetSettingString(GroupName, 'Device', '')) do begin
                    while (not Terminated) and Connected  do begin
                        Command := GetCommand;
                        if Command <> '' then begin
                            try
                                // SendMessage('Sending ' + Commands[0]);
                                // Sleep(1000);
                                FSocket.SendData(TEncoding.UTF8.GetBytes(Command));
                                // Sleep(1000);
                                // SendMessage(' ');
                            except
                                Connected := False;
                                // SendMessage('Disconnected From Device');
                            end;
                        end;

                        Bytes := FSocket.ReceiveData;

                        for i := 0 to Length(Bytes)-1 do begin
                            if Bytes[i] = 13 then begin
                                SyncCallback(rsMessage, '', '', Line);
                                Line := '';
                            end else if Bytes[i] <> 10 then begin
                                Line := Line + Chr(Bytes[i]);
                            end;
                        end;

                        Sleep(200);
                    end;

                    FSocket.Free;
                end;
            end;

        end;

        Sleep(5000);
    end;

    Bluetooth1.Free;
end;


{$ENDIF}

end.


