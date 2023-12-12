unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Radio, RadioBase,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Ani, FMX.Edit;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    Timer1: TTimer;
    Timer2: TTimer;
    Button1: TButton;
    Edit1: TEdit;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    RadioModule: TRadio;
    ID: Integer;
    OurCallsign, RemoteCallsign: String;
    procedure RadioCallback(Status: TRadioStatus; Source, Target, Content: String);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
    Inc(ID);
    RadioModule.SendMessage(ID, RemoteCallsign, Edit1.Text);
end;

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True;
   ListOfStrings.DelimitedText   := Str;
end;

procedure TForm1.RadioCallback(Status: TRadioStatus; Source, Target, Content: String);
var
    Position: Integer;
    Command, Parameters: String;
    MessageType: Char;
    Fields: TStringList;
begin
    Position := Pos('=', Content);
    if Position > 0 then begin
        Command := Copy(Content, 1,Position-1);
        Parameters := Copy(Content, Position+1, Length(Content));

        if Command = 'Message' then begin
            MessageType := Parameters[2];
            Parameters := Copy(Parameters, 3, Length(Parameters));
            Fields := TStringList.Create;
            Split(',', Parameters, Fields);

            if MessageType = 'H' then begin
                Memo1.Lines.Add('HEARTBEAT from ' + Parameters);
            end else if MessageType = 'A' then begin
                Memo1.Lines.Add('ACK of ID from ' + Fields[0] + ' from ' + Fields[1] + ' to ' + Fields[2]);
            end else if MessageType = 'T' then begin
                if Fields[2] = OurCallsign then begin
                    Memo1.Lines.Add('MSG ID ' + Fields[0] + ' from ' + Fields[1] + ' to ** ME ** = ' + Fields[3]);
                end else begin
                    Memo1.Lines.Add('MSG ID ' + Fields[0] + ' from ' + Fields[1] + ' to ' + Fields[2] + ' = ' + Fields[3]);
                end;
                RadioModule.SendAck(StrToIntDef(Fields[0], 0), Fields[1]);
            end else begin
                Memo1.Lines.Add(Content);
            end;
            Fields.Free;
        end;
    end else begin
        Memo1.Lines.Add(Content);
    end;

    Memo1.SelStart := Length(Memo1.text);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
    if CheckBox1.IsChecked then begin
        Timer1.Enabled := False;

        RadioModule.SendHeartbeat;

        Timer1.Interval := (Random(10) + 5) * 1000;
        Timer1.Enabled := True;
    end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
    DeviceName: String;
begin
    Timer2.Enabled := False;

{$IFDEF MSWINDOWS}
  DeviceName := 'COM16';
  OurCallsign := 'W';
  RemoteCallsign := 'A';
{$ENDIF}
{$IFDEF ANDROID}
  DeviceName := 'HAB BT';
  OurCallsign := 'A';
  RemoteCallsign := 'W';
{$ENDIF}

    if ParamCount >= 1 then begin
        DeviceName := ParamStr(1);
        if ParamCount >= 2 then begin
            OurCallsign := ParamStr(2);
            if ParamCount >= 3 then begin
                RemoteCallsign := ParamStr(3);
            end;
        end;
    end;

    Caption := Caption + ' - ' + DeviceName + ' - ' + OurCallsign;

    RadioModule := TRadio.Create(DeviceName, OurCallsign, 1, 2, RadioCallback);

    Randomize;
end;

end.
