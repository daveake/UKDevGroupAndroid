unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, Registry, Winapi.Windows,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Layouts;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    hCommFile : THandle;
    InputBuffer : AnsiString;
    procedure PollSerialPort;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
    CommPort: String;
    TimeoutBuffer: PCOMMTIMEOUTS;
    CommConfig: TCommConfig;
    DCB : TDCB;
begin
    if ComboBox1.ItemIndex >= 0 then begin
        // Serial port ID
        CommPort := ComboBox1.Items[ComboBox1.ItemIndex];

        // Open serial port as a file
        hCommFile := CreateFile(PChar(CommPort),
                              GENERIC_READ, //  or GENERIC_WRITE,
                              0,
                              nil,
                              OPEN_EXISTING,
                              FILE_ATTRIBUTE_NORMAL,
                              0);

        // Set baud rate etc
        GetCommState(hCommFile, DCB);
        DCB.BaudRate := 57600;
        DCB.ByteSize := 8;
        DCB.StopBits := 1;
        DCB.Parity := NOPARITY;
        SetCommState(hCommFile, DCB);

        // Set timeouts
        GetMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));
        GetCommTimeouts (hCommFile, TimeoutBuffer^);
        TimeoutBuffer.ReadIntervalTimeout        := 300;
        TimeoutBuffer.ReadTotalTimeoutMultiplier := 300;
        TimeoutBuffer.ReadTotalTimeoutConstant   := 300;
        SetCommTimeouts (hCommFile, TimeoutBuffer^);
        FreeMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));

        Timer1.Enabled := True;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  reg: TRegistry;
  st: Tstrings;
  i: Integer;
begin
    ComboBox1.Items.Clear;

    reg := TRegistry.Create;
    try
        reg.RootKey := HKEY_LOCAL_MACHINE;
        reg.OpenKeyReadOnly('hardware\devicemap\serialcomm');
        st := TstringList.Create;
        try
            reg.GetValueNames(st);
            for i := 0 to st.Count - 1 do begin
                ComboBox1.Items.Add(reg.Readstring(st.strings[i]));
            end;
        finally
            st.Free;
        end;
        reg.CloseKey;
    finally
        reg.Free;
    end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    PollSerialPort;
end;

procedure TForm1.PollSerialPort;
var
    i,NumberOfBytesRead: dword;
    Buffer : array[0..100] of Ansichar;
begin
    if hCommFile <> INVALID_HANDLE_VALUE then begin
        if ReadFile(hCommFile, Buffer, sizeof(Buffer), NumberOfBytesRead, nil) then begin
            for i := 0 to NumberOfBytesRead - 1 do begin
                if Buffer[i] = #13 then begin
                    ListBox1.ItemIndex := ListBox1.Items.Add(InputBuffer);
                    InputBuffer := '';
                end else if Buffer[i] <> #10 then begin
                    InputBuffer := InputBuffer + Buffer[i];
                end;
            end;
        end;
    end;
end;

end.
