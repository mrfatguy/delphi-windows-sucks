unit frmInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, ComCtrls;

type
  TInfoForm = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    Image1: TImage;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    pnlHistory: TPanel;
    reHistory: TRichEdit;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoForm: TInfoForm;

implementation

{$R *.dfm}

procedure TInfoForm.FormShow(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + 'WindowsSucks.rtf') then reHistory.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'WindowsSucks.rtf');
end;

procedure TInfoForm.btnCancelClick(Sender: TObject);
begin
  Close();
end;

end.
