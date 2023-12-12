unit RadioBase;

interface

uses Classes, SysUtils;

type
  TRadioStatus = (rsInfo, rsConnecting, rsConnected, rsConnectionFailure, rsDisconnected, rsHeartbeat, rsMessage, rsAck);

type
  TRadioCallback = procedure(Status: TRadioStatus; Source, Target, Content: String) of object;

type TRadioSettings = record
    DeviceName:     String;
    Callsign:       String;
end;

type
  TRadioBase = class(TThread)
  private
    { Private declarations }
  protected
    { Protected declarations }
    RadioSettings: TRadioSettings;
    procedure SyncCallback(Status: TRadioStatus; Source, Target, Content: String);
    procedure ProcessLine(Line: String);
    procedure AddCommand(Command: String);
    function GetCommand: String;
    procedure Execute; override;
  public
    { Public declarations }
    Commands: TStringList;
    RadioCallback: TRadioCallback;
    constructor Create(Device, Callsign: String; Channel, Mode: Integer; Callback: TRadioCallback);
    procedure SetMode(Mode: Integer);
    procedure SetFrequency(Frequency: Double);
    procedure SetChannel(Channel: Integer);
    procedure SendHeartbeat;
    procedure SendMessage(ID: Integer; RemoteCallsign, Message: String);
    procedure SendAck(ID: Integer; RemoteCallsign: String);
    destructor Destroy; override;
  end;

implementation

constructor TRadioBase.Create(Device, Callsign: String; Channel, Mode: Integer; Callback: TRadioCallback);
begin
    Commands := TStringList.Create;

    RadioSettings.DeviceName := Device;
    RadioSettings.Callsign := Callsign;

    RadioCallback := Callback;

    SetMode(Mode);

    SetChannel(Channel);

    inherited Create(False);
end;

procedure TRadioBase.Execute;
begin
    SyncCallback(rsInfo, '', '', 'Thread started');
end;

destructor TRadioBase.Destroy;
begin
    Commands.Free;
    inherited;
end;

procedure TRadioBase.SyncCallback(Status: TRadioStatus; Source, Target, Content: String);
begin
    Synchronize(
        procedure begin
            RadioCallback(Status, Source, Target, Content);
        end
    );
end;

procedure TRadioBase.AddCommand(Command: String);
begin
    Commands.Add(Command);
end;

function TRadioBase.GetCommand: String;
begin
    if Commands.Count > 0 then begin
        Result := '~' + Commands[0] + #13;
        Commands.Delete(0);
    end else begin
        Result := '';
    end;
end;

procedure TRadioBase.SetFrequency(Frequency: Double);
begin
    AddCommand('F' + FormatFloat('0.0000', Frequency));
end;

procedure TRadioBase.SetChannel(Channel: Integer);
begin
    SetFrequency(434.500 + Channel * 0.025);
end;

procedure TRadioBase.SetMode(Mode: Integer);
begin
    AddCommand('M' + IntToStr(Mode));
end;

procedure TRadioBase.SendHeartbeat;
begin
    AddCommand('T$H' + RadioSettings.Callsign + ' ');
end;

procedure TRadioBase.SendMessage(ID: Integer; RemoteCallsign, Message: String);
begin
    AddCommand('T$T' + IntToStr(ID) + ',' + RadioSettings.Callsign + ',' + RemoteCallsign + ',' + Message + ' ');
end;

procedure TRadioBase.SendAck(ID: Integer; RemoteCallsign: String);
begin
    AddCommand('T$A' + IntToStr(ID) + ',' + RadioSettings.Callsign + ',' + RemoteCallsign + ' ');
end;

procedure TRadioBase.ProcessLine(Line: String);
var
    Position: Integer;
    Command, Parameters: String;
begin
    Position := Pos('=', Line);
    if Position > 0 then begin
        Command := Copy(Line, 1,Position-1);
        Parameters := Copy(Line, Position+1, Length(Line));

        if Command = 'Message' then begin
            SyncCallback(rsMessage, '', '', Line);
        end else if Command = 'GPS' then begin
        end else if Command = 'Mode' then begin
        end else if Command = 'Frequency' then begin
        end else if Command = 'CurrentRSSI' then begin
        end else if Command = 'FreqErr' then begin
        end else if Command = 'PacketRSSI' then begin
        end else if Command = 'PacketSNR' then begin
        end else if Command = 'Tx' then begin
        end else begin
            SyncCallback(rsMessage, '', '', 'UNKNOWN COMMAND ' + Command);
        end;
    end;
end;

end.
