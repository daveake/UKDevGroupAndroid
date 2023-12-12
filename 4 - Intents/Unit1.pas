unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
{$IFDEF ANDROID}
  Androidapi.JNIBridge, AndroidApi.JNI.Media, AndroidAPI.jni.OS,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText, Androidapi.Helpers, Androidapi.JNI.Net,
  FMX.Helpers.Android, FMX.Platform.Android, AndroidApi.Jni.App,
{$ENDIF}
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

{$IFDEF ANDROID}
procedure OpenURL(const URL: string);
var
    Intent: JIntent;
begin
    Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW, TJnet_Uri.JavaClass.parse(StringToJString(URL)));
    try
        SharedActivity.startActivity(Intent);
    except
        ShowMessage('Intent receiver not found');
    end;
end;
{$ENDIF}

procedure TForm1.Button1Click(Sender: TObject);
begin
    {$IFDEF ANDROID}
        OpenURL('google.navigation:q=' + Edit1.Text);
    {$ENDIF}
end;

end.
