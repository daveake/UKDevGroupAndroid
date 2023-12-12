unit RadioWindows;

interface

{$IFDEF MSWINDOWS}

uses Winapi.Windows, RadioBase;

type
  TRadioWindows = class(TRadioBase)
  private
    { Private declarations }
    Line: String;
  protected
    { Protected declarations }
    procedure Execute; override;
  public
    { Public declarations }
  end;

{$ENDIF}
implementation

{$IFDEF MSWINDOWS}

function FixSerialPortName(ComPort: String): String;
begin
    Result := ComPort;

    if Copy(ComPort, 1, 3) = 'COM' then begin
        if Length(ComPort) > 4 then begin
            Result := '\\.\' + ComPort;
        end;
    end;
end;

procedure TRadioWindows.Execute;
var
    CommPort, Command: String;
    hCommFile : THandle;
    TimeoutBuffer: PCOMMTIMEOUTS;
    DCB : TDCB;
    NumberOfBytesRead, NumberOfBytesWritten: dword;
    Buffer: array[0..300] of Ansichar;
    TxBuffer: Array[0..254] of Ansichar;
    i, j: Integer;
begin
    inherited;

    while not Terminated do begin
        CommPort := FixSerialPortName(RadioSettings.DeviceName);

        hCommFile := CreateFile(PChar(CommPort),
                              GENERIC_READ or GENERIC_WRITE,
                              0,
                              nil,
                              OPEN_EXISTING,
                              FILE_ATTRIBUTE_NORMAL,
                              0);

         if hCommFile = INVALID_HANDLE_VALUE then begin
            SyncCallback(rsConnectionFailure, '', '', 'Cannot open serial port ' + CommPort);
            Sleep(1000);
         end else begin
            // Set baud rate etc
            GetCommState(hCommFile, DCB);
            DCB.BaudRate := CBR_57600;

            DCB.ByteSize := 8;
            DCB.StopBits := ONESTOPBIT;
            DCB.Parity := NOPARITY;
            if SetCommState(hCommFile, DCB) then begin
                // Set timeouts
                GetMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));
                GetCommTimeouts (hCommFile, TimeoutBuffer^);
                TimeoutBuffer.ReadIntervalTimeout        := 300;
                TimeoutBuffer.ReadTotalTimeoutMultiplier := 300;
                TimeoutBuffer.ReadTotalTimeoutConstant   := 300;
                SetCommTimeouts (hCommFile, TimeoutBuffer^);
                FreeMem(TimeoutBuffer, sizeof(COMMTIMEOUTS));

                SyncCallback(rsConnected, '', '', 'Connected to ' + CommPort);

                while not Terminated do begin
                    if ReadFile(hCommFile, Buffer, sizeof(Buffer), NumberOfBytesRead, nil) then begin
                        for i := 0 to NumberOfBytesRead - 1 do begin
                            if Buffer[i] = #13 then begin
                                ProcessLine(Line);
                                Line := '';
                            end else if Buffer[i] <> #10 then begin
                                Line := Line + Buffer[i];
                            end;
                        end;
                    end;

                    Command := GetCommand;

                    if Command <> '' then begin
                        for j := 1 to Length(Command) do begin
                            TxBuffer[j-1] := AnsiChar(Command[j]);
                        end;
                        WriteFile(hCommFile, TxBuffer, Length(Command), NumberOfBytesWritten, nil);
                        Sleep(200);
                    end;
                end;
            end;
            CloseHandle(hCommFile);

            Sleep(100);
        end;
    end;
end;


{$ENDIF}

end.


