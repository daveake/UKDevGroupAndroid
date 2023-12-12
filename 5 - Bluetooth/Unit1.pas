unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Bluetooth, FMX.Layouts, FMX.ListBox, System.Bluetooth.Components,
{$IFDEF ANDROID}
  Androidapi.JNIBridge, Androidapi.Helpers, AndroidAPI.jni.OS, System.Permissions,
{$ENDIF}
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    ListBox2: TListBox;
    Button3: TButton;
    Timer1: TTimer;
    Memo1: TMemo;
    Bluetooth1: TBluetooth;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    Socket: TBluetoothSocket;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

const
cPermissionBluetooth = 'android.permission.BLUETOOTH';
  cPermissionBluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';
  cPermissionBluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';
  cPermissionBluetoothScan = 'android.permission.BLUETOOTH_SCAN';


procedure TForm1.Button1Click(Sender: TObject);
var
    i: Integer;
begin
    ListBox1.Items.Clear;

    try
        Bluetooth1.Enabled := True;

        if Bluetooth1.LastPairedDevices <> nil then begin
            for i := 0 to Bluetooth1.LastPairedDevices.Count-1 do begin
                ListBox1.Items.Add(Bluetooth1.LastPairedDevices[i].DeviceName);
            end;
        end;
    finally
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
    Device: TBluetoothDevice;
    Services: TBluetoothServiceList;
    i, DeviceIndex, ServiceIndex: Integer;
begin
    ListBox2.Items.Clear;

    if ListBox1.ItemIndex >= 0 then begin
        try
            Device := Bluetooth1.LastPairedDevices[ListBox1.ItemIndex];

            Services := Device.GetServices;

            for i := 0 to Services.Count-1 do begin
                ListBox2.Items.Add(Services[i].Name);
            end;

        finally
        end;
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
    Bluetooth1: TBluetooth;
    BluetoothDevice: TBluetoothDevice;
    Services: TBluetoothServiceList;
    Service: TBluetoothService;
    AUUID: TGUID;
begin
    Memo1.Lines.Clear;

    if (ListBox1.ItemIndex >= 0) and (ListBox2.ItemIndex >= 0) then begin
        Bluetooth1 := TBluetooth.Create(nil);
        Bluetooth1.Enabled := True;

        Bluetooth1 := TBluetooth.Create(nil);
        Bluetooth1.Enabled := True;
        BluetoothDevice := Bluetooth1.LastPairedDevices[ListBox1.ItemIndex];

        Services := BluetoothDevice.LastServiceList;        // Cached - to get afresh, use GetServices;

        BluetoothDevice := Bluetooth1.PairedDevices[ListBox1.ItemIndex];
        Services := BluetoothDevice.LastServiceList;        // Cached - to get afresh, use GetServices;
        Service := Services[ListBox2.ItemIndex];
        AUUID := Service.UUID;
        Socket := BluetoothDevice.CreateClientSocket(AUUID, False);
        if Socket = nil then begin
            Memo1.Lines.Add('Cannot open');
        end else begin
            Memo1.Lines.Add('Opened OK');
            Socket.Connect;
            if Socket.Connected then begin
                Memo1.Lines.Add('Connected OK');
                Timer1.Enabled := True;
            end else begin
                Memo1.Lines.Add('NOT Connected');
            end;
        end;
    end;
end;


procedure TForm1.Button4Click(Sender: TObject);
const
  cPermissionBluetooth = 'android.permission.BLUETOOTH';
  cPermissionBluetoothAdmin = 'android.permission.BLUETOOTH_ADMIN';
  cPermissionBluetoothConnect = 'android.permission.BLUETOOTH_CONNECT';
  cPermissionBluetoothScan = 'android.permission.BLUETOOTH_SCAN';
begin
{$IFDEF ANDROID}
    PermissionsService.RequestPermissions([cPermissionBluetooth, cPermissionBluetoothConnect, cPermissionBluetoothScan],
        procedure(const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray) begin
//          if PermissionsService.IsPermissionGranted(cPermissionBluetooth) then
//          begin
//            ListBox1.Items.Add('cPermissionBluetooth: Granted');
//          end else
//          begin
//            ListBox1.Items.Add('cPermissionBluetooth: NOT Granted!');
//          end;
//
//          if PermissionsService.IsPermissionGranted(cPermissionBluetoothConnect) then
//          begin
//            ListBox1.Items.Add('cPermissionBluetoothConnect: Granted');
//          end else
//          begin
//            ListBox1.Items.Add('cPermissionBluetoothConnect: NOT Granted!');
//          end;
//
//          if PermissionsService.IsPermissionGranted(cPermissionBluetoothScan) then
//          begin
//            ListBox1.Items.Add('cPermissionBluetoothScan: Granted');
//          end else
//          begin
//            ListBox1.Items.Add('cPermissionBluetoothScan: NOT Granted!');
//          end;
//            if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then begin
//                ListBox1.Items.Add('Bluetooth Permission Given');
//            end else begin
//                ListBox1.Items.Add('Bluetooth Permission NOT Given');
//            end;
        end);
{$ENDIF}
  // if TGrantResults(AGrantResults).AreAllGranted then
  end;

function GetLine(var Line: String; Delimiter: String): String;
var
    Position: Integer;
begin
    Position := Pos(Delimiter, Line);
    if Position > 0 then begin
        Result := Copy(Line, 1, Position-1);
        Line := Copy(Line, Position+Length(Delimiter), Length(Line));
    end else begin
        Result := '';
    end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
    Bytes: TBytes;
    Buffer: String;
begin
    if Socket <> nil then begin
        if Socket.Connected then begin
            Bytes := Socket.ReceiveData;

            Buffer := StringOf(Bytes);

            Memo1.Text := Memo1.Text + Buffer;
        end;
    end;
end;

end.
