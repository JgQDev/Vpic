unit Credits;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    OkB: TButton;
    Image1: TImage;
    procedure OkBClick(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.OkBClick(Sender: TObject);
begin
  Close;
end;

end.

