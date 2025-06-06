unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, ExtDlgs, Types, process;

type

  { TForm1 }

  TForm1 = class(TForm)
    ResetItem: TMenuItem;
    OpenItem: TMenuItem;
    MM1_View_Reset: TMenuItem;
    MM1_View: TMenuItem;
    OpenD: TOpenPictureDialog;
    MM1_About_Credit: TMenuItem;
    MM1_About: TMenuItem;
    MM1_File_Exit: TMenuItem;
    MM1_File_SaveAs: TMenuItem;
    MM1_File_Open: TMenuItem;
    MM1_File: TMenuItem;
    MM1: TMainMenu;
    PB1: TPaintBox;
    PopM: TPopupMenu;
    SaveD: TSavePictureDialog;
    Separator3: TMenuItem;
    Timer1: TTimer;
    WholeP: TPanel;
    SBar: TStatusBar;
    Separator1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MD(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure ML(Sender: TObject);
    procedure MM(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MM1_About_CreditClick(Sender: TObject);
    procedure MM1_File_ExitClick(Sender: TObject);
    procedure MM1_File_OpenClick(Sender: TObject);
    procedure MM1_File_SaveAsClick(Sender: TObject);
    procedure MM1_View_ResetClick(Sender: TObject);
    procedure MU(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure MWD(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure MWU(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure OP(Sender: TObject);
    procedure ORSize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    procedure InitPBCv;
    procedure InitCanvas;
    procedure ResizeCanvas(const SetSize:Integer);
    procedure LoadImageAt(const FilePathName:String);
    function RR(const X:Real):Integer;
    function GetFileName:String;
  end;

var
  Form1: TForm1;
  FPN: String;
  Pic: TPicture;
  PBCv: TPortableNetworkGraphic;
  MDown: Boolean;
  MIx: Integer;
  MIy: Integer;
  DrawBool: Boolean;
  ScrollValue: Integer;
  MIxy: TPoint;
  MIwh: TPoint;
  StrParam: Boolean;
  FilePN: String;

implementation

uses
  Credits;

{$R *.lfm}

{ TForm1 }

procedure TForm1.MM1_File_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.MM1_File_OpenClick(Sender: TObject);
begin
  if(OpenD.Execute=False)then Exit;
  if(FileExists(OpenD.FileName)=True)then begin
    FPN:=OpenD.FileName;

    try
      Pic.LoadFromFile(OpenD.FileName);
    except
      Form1.Caption:='Vpic - Cannot load image';
      SBar.Panels.Items[1].Text:='Dimension: None';
      SBar.Panels.Items[0].Text:='Directory: None';
      Exit;
    end;
    Form1.Caption:='Vpic - '+self.GetFileName;

    SBar.Panels.Items[1].Text:='Dimension: '+
    IntToStr(Pic.Width)+'x'+IntToStr(Pic.Height);

    SBar.Panels.Items[0].Text:='Directory: '+FPN;

    InitCanvas;
    DrawBool:=True;
  end;
end;

procedure TForm1.MM1_File_SaveAsClick(Sender: TObject);
begin
  if(FPN='')then Exit;
  if(SaveD.Execute)then Pic.SaveToFile(SaveD.FileName);
end;

procedure TForm1.MM1_View_ResetClick(Sender: TObject);
begin
  if(FPN<>'')then InitCanvas;
  DrawBool:=True;
end;

procedure TForm1.MU(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  MDown:=False;
end;

procedure TForm1.MWD(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
var
  AWidth,AHeight:Integer;
  PosX,PosY:Integer;
begin
  if(MIwh.X<=100)or(MIwh.Y<=100)then begin
    While(ScrollValue<=5)do begin
      if(MIwh.X>=MIwh.Y)then begin
        ScrollValue:=RR(((MIwh.X*50)/MIwh.Y)*1.26);
      end else
      if(MIwh.X<MIwh.Y)then begin
        ScrollValue:=RR(((MIwh.Y*50)/MIwh.X)*1.26);
      end;
    end;
  end;

  AWidth:=MIwh.X;
  AHeight:=MIwh.Y;
  PosX:=MousePos.X;
  PosY:=MousePos.Y;

  ResizeCanvas(ScrollValue);
  if(MIwh.X>=MIwh.Y)then begin
    ScrollValue:=RR(((MIwh.X*50)/MIwh.Y)*1.26);
  end else
  if(MIwh.X<MIwh.Y)then begin
    ScrollValue:=RR(((MIwh.Y*50)/MIwh.X)*1.26);
  end;

  MIxy.X:=RR(PosX+((MIwh.X*(MIxy.X-PosX))/AWidth));
  MIxy.Y:=RR(PosY+((MIwh.Y*(MIxy.Y-PosY))/AHeight));

  InitPBCv;
  DrawBool:=True;
end;

procedure TForm1.MWU(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
var
  AWidth,AHeight:Integer;
  PosX,PosY:Integer;
begin
  if(MIwh.X<100)or(MIwh.Y<100)then Exit;

  AWidth:=MIwh.X;
  AHeight:=MIwh.Y;
  PosX:=MousePos.X;
  PosY:=MousePos.Y;

  ResizeCanvas(-ScrollValue);
  if(MIwh.X>=MIwh.Y)then begin
    ScrollValue:=RR(((MIwh.X*50)/MIwh.Y)/1.26);
  end else
  if(MIwh.X<MIwh.Y)then begin
    ScrollValue:=RR(((MIwh.Y*50)/MIwh.X)/1.26);
  end;

  MIxy.X:=RR(PosX+((MIwh.X*(MIxy.X-PosX))/AWidth));
  MIxy.Y:=RR(PosY+((MIwh.Y*(MIxy.Y-PosY))/AHeight));

  InitPBCv;
  DrawBool:=True;
end;

procedure TForm1.OP(Sender: TObject);
begin
  if(FPN<>'')then begin
    PB1.Canvas.Brush.Color:=$00A36E00;
    PB1.Canvas.FillRect(PB1.ClientRect);

    PB1.Canvas.Draw(0,0,PBCv);
  end;
end;

procedure TForm1.ORSize(Sender: TObject);
begin
  InitPBCv;
  DrawBool:=True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if(StrParam=True)then begin
    StrParam:=False;
    Form1.LoadImageAt(FilePN);
    self.MM1_View_ResetClick(Sender);
  end else
  if(DrawBool=True)then begin
    self.OP(Sender);
    DrawBool:=False;
  end;
end;

procedure TForm1.InitPBCv;
var
  AWidth,AHeight:Integer;
begin
  PBCv.SetSize(PB1.Width,PB1.Height);

  PBCv.Canvas.Brush.Color:=$00A36E00;
  PBCv.Canvas.FillRect(0,0,PB1.Width,PB1.Height);

  AWidth:=MIxy.X+MIwh.X;
  AHeight:=MIxy.Y+MIwh.Y;
  PBCv.Canvas.StretchDraw(Rect(MIxy.X,MIxy.Y,AWidth,AHeight),Pic.PNG);
end;

procedure TForm1.InitCanvas;
var
  AWidth:Integer;
  AHeight:Integer;
  Ixy:TPoint;
  TempX,TempY:Integer;
begin
  if(Pic.Width>=Pic.Height)then begin
    if(Pic.Width=0)then TempX:=1 else TempX:=Pic.Width;
    AWidth:=PB1.Height;
    AHeight:=RR((PB1.Height*Pic.Height)/TempX);
  end else
  if(Pic.Width<Pic.Height)then begin
    if(Pic.Height=0)then TempY:=1 else TempY:=Pic.Height;
    AWidth:=RR((PB1.Height*Pic.Width)/TempY);
    AHeight:=PB1.Height;
  end;
  Ixy.X:=(PB1.Width div 2)-(AWidth div 2);
  Ixy.Y:=(PB1.Height div 2)-(AHeight div 2);
  MIxy.SetLocation(Ixy);
  MIwh.SetLocation(AWidth,AHeight);
  if(MIwh.X>=MIwh.Y)then begin
    if(MIwh.Y=0)then TempY:=1 else TempY:=MIwh.Y;
    ScrollValue:=RR(((MIwh.X*10)/TempY)*1.26);
  end else
  if(MIwh.X<MIwh.Y)then begin
    if(MIwh.X=0)then TempX:=1 else TempX:=MIwh.X;
    ScrollValue:=RR(((MIwh.Y*10)/TempX)*1.26);
  end;
  ResizeCanvas(ScrollValue);
  InitPBCv;
end;

procedure TForm1.ResizeCanvas(const SetSize: Integer);
var
  AWidth:Integer;
  AHeight:Integer;
  TempX,TempY:Integer;
begin
  if(Pic.Width>=Pic.Height)then begin
    if(Pic.Width=0)then TempX:=1 else TempX:=Pic.Width;
    AWidth:=(MIwh.X+SetSize);
    AHeight:=RR(((MIwh.X+SetSize)*Pic.Height)/TempX);
  end else
  if(Pic.Width<Pic.Height)then begin
    if(Pic.Height=0)then TempY:=1 else TempY:=Pic.Height;
    AWidth:=RR(((MIwh.Y+SetSize)*Pic.Width)/TempY);
    AHeight:=(MIwh.Y+SetSize);
  end;
  MIwh.SetLocation(AWidth,AHeight);
end;

procedure TForm1.LoadImageAt(const FilePathName: String);
begin
  if(FileExists(FilePathName)=True)then begin
    FPN:=FilePathName;

    try
      Pic.LoadFromFile(FilePathName);
    except
      Form1.Caption:='Vpic - Cannot load image';
      SBar.Panels.Items[1].Text:='Dimension: None';
      SBar.Panels.Items[0].Text:='Directory: None';
      Exit;
    end;
    Form1.Caption:='Vpic - '+self.GetFileName;

    SBar.Panels.Items[1].Text:='Dimension: '+
    IntToStr(Pic.Width)+'x'+IntToStr(Pic.Height);

    SBar.Panels.Items[0].Text:='Directory: '+FPN;

    InitCanvas;
    DrawBool:=True;
  end;
end;

function TForm1.RR(const X: Real): Integer;
begin
  if(Round(X)>X)then Result:=Round(X)-1
  else Result:=Round(X);
end;

function TForm1.GetFileName: String;
var
  i:Integer;
begin
  Result:='';
  for i:=Length(FPN) downto 1 do begin
    if(FPN[i]='/')or(FPN[i]='\')then begin
      Result:=Copy(FPN,i+1,Length(FPN));
      Exit;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FPN:='';
  Pic:=TPicture.Create;
  PBCv:=TPortableNetworkGraphic.Create;
  ScrollValue:=10;
  if(ParamCount>0)then begin
    StrParam:=True;
    FilePN:=ParamStr(1);
  end else begin
    StrParam:=False;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Pic.Free;
  PBCv.Free;
end;

procedure TForm1.MD(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if(Button=mbMiddle)then begin
    MDown:=True;
    MIx:=X;
    MIy:=Y;
  end;
end;

procedure TForm1.ML(Sender: TObject);
begin
  MDown:=False;
end;

procedure TForm1.MM(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if(MDown=True)then begin
    MIxy.SetLocation(MIxy.X+(X-MIx),MIxy.Y+(Y-MIy));
    MIx:=X;
    MIy:=Y;
    InitPBCv;
    DrawBool:=True;
  end;
end;

procedure TForm1.MM1_About_CreditClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

end.

