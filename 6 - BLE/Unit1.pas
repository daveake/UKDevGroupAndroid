unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Bluetooth, FMX.Layouts, FMX.ListBox, System.Bluetooth.Components,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  Androidapi.JNIBridge, AndroidApi.JNI.Media,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, Androidapi.JNI.Net,
  FMX.Helpers.Android, FMX.Platform.Android, AndroidApi.Jni.App,
  AndroidAPI.jni.OS, System.Permissions, FMX.Memo, FMX.Edit;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    BluetoothLE1: TBluetoothLE;
    Button4: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BluetoothLE1DiscoverLEDevice(const Sender: TObject;
      const ADevice: TBluetoothLEDevice; Rssi: Integer;
      const ScanResponse: TScanResponse);
    procedure Button3Click(Sender: TObject);
    procedure BluetoothLE1EndDiscoverServices(const Sender: TObject;
      const AServiceList: TBluetoothGattServiceList);
    procedure BluetoothLE1CharacteristicRead(const Sender: TObject;
      const ACharacteristic: TBluetoothGattCharacteristic;
      AGattStatus: TBluetoothGattStatus);
    procedure Button4Click(Sender: TObject);
    procedure BluetoothLE1CharacteristicWrite(const Sender: TObject;
      const ACharacteristic: TBluetoothGattCharacteristic;
      AGattStatus: TBluetoothGattStatus);
    procedure BluetoothLE1CharacteristicWriteRequest(const Sender: TObject;
      const ACharacteristic: TBluetoothGattCharacteristic;
      var AGattStatus: TBluetoothGattStatus;
      const AValue: TArray<System.Byte>);
  private
    { Private declarations }
    DeviceIndex: Integer;
    SerialDevice: TBluetoothLEDevice;
    SerialService: TBluetoothGattService;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.BluetoothLE1CharacteristicRead(const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  AGattStatus: TBluetoothGattStatus);
var
    Temp: String;
    i, j: Integer;
begin
    j := Length(ACharacteristic.Value);
    Temp := '';

    for i := 0 to j-1 do begin
        Temp := Temp + Chr(ACharacteristic.GetValueAsInt8(i));
    end;

    Edit2.Text := Temp;
end;

procedure TForm1.BluetoothLE1CharacteristicWrite(const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  AGattStatus: TBluetoothGattStatus);
begin
    Memo1.Lines.Add('OnWrite');
end;

procedure TForm1.BluetoothLE1CharacteristicWriteRequest(
  const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  var AGattStatus: TBluetoothGattStatus;
  const AValue: TArray<System.Byte>);
begin
    Memo1.Lines.Add('OnWriteRequest');
end;

procedure TForm1.BluetoothLE1DiscoverLEDevice(const Sender: TObject;
  const ADevice: TBluetoothLEDevice; Rssi: Integer;
  const ScanResponse: TScanResponse);
var
    i: Integer;
begin
    if BluetoothLE1.DiscoveredDevices.Count > ListBox1.Items.Count then begin
        for i := ListBox1.Items.Count to BluetoothLE1.DiscoveredDevices.Count-1 do begin
            ListBox1.Items.Add(IntToStr(i) + ': ' +
//                                 ', Add=' + BluetoothLE1.DiscoveredDevices.Items[i].Address +
                                   'Name=' + BluetoothLE1.DiscoveredDevices.Items[i].DeviceName +
                                   ', ID=' + BluetoothLE1.DiscoveredDevices.Items[i].Identifier);
//                                 ', TS=' + BluetoothLE1.DiscoveredDevices.Items[i].ToString);
        end;
    end;
end;

procedure TForm1.BluetoothLE1EndDiscoverServices(const Sender: TObject;
  const AServiceList: TBluetoothGattServiceList);
var
    Service: TBluetoothGattService;
    i, j: Integer;
begin
    SerialService := nil;

    Memo1.Lines.Add('Discovered ' + IntToStr(AServiceList.Count) + ' services');
    for i := 0 to AServiceList.Count-1 do begin
        Memo1.Lines.Add('  ' + IntToStr(i) + ': ' + AServiceList.Items[i].UUIDName + ' = ' + AServiceList.Items[i].UUID.ToString);
        Service := BluetoothLE1.DiscoveredDevices[DeviceIndex].GetService(AServiceList.Items[i].UUID);
        for j := 0 to Service.Characteristics.Count-1 do begin
            Memo1.Lines.Add('    ' + IntToStr(j) + ': ' + Service.Characteristics[j].UUIDName + ' = ' + Service.Characteristics[j].UUID.ToString);
        end;
        if (AServiceList.Items[i].UUIDName = 'Key Service') or
           (AServiceList.Items[i].UUID.ToString = '{6E400001-B5A3-F393-E0A9-E50E24DCCA9E}') or
           (i = (AServiceList.Count-1)) then begin
            SerialService := Service;
        end;
    end;

    if SerialService = nil then begin
        Memo1.Lines.Add('No serial service found');
    end else begin
        if BluetoothLE1.SubscribeToCharacteristic(SerialDevice, SerialService.Characteristics[0]) then begin
            Memo1.Lines.Add('Subscribed OK');
        end else begin
            Memo1.Lines.Add('Failed to subscribed to serial service');
        end;
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  cPermissionBluetooth = 'android.permission.BLUETOOTH';
  cPermissionBluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';
  cPermissionBluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';
  cPermissionBluetoothScan = 'android.permission.BLUETOOTH_SCAN';
begin
    Memo1.Lines.Add('Requesting Permissions');

    PermissionsService.RequestPermissions([cPermissionBluetooth, cPermissionBluetoothConnect, cPermissionBluetoothScan, JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
        end);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    ListBox1.Items.Clear;
    BluetoothLE1.Enabled := True;
    BluetoothLE1.DiscoverDevices(5000);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    DeviceIndex := ListBox1.ItemIndex;
    if DeviceIndex >= 0 then begin
        Memo1.Lines.Add('Discover Services ...');
        SerialDevice := BluetoothLE1.DiscoveredDevices[DeviceIndex];
        BluetoothLE1.DiscoverServices(SerialDevice);
    end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
    Temp: String;
begin
    Temp := Edit1.Text + #13;
    SerialService.Characteristics[1].SetValueAsString(Temp);
    BluetoothLE1.WriteCharacteristic(SerialDevice, SerialService.Characteristics[1]);
end;

end.
