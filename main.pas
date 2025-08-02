unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, ExtDlgs, Types, process;

type

  { TForm1 }

  TForm1 = class(TForm)
    MaxImageSizeItem: TMenuItem;
    WrapAroundModeItem: TMenuItem;
    MM1_View_WrapAroundMode: TMenuItem;
    MinImageSize: TMenuItem;
    MM1_View_MinImageSize: TMenuItem;
    MM1_View_MaxImageSize: TMenuItem;
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
    procedure MM1_View_MaxImageSizeClick(Sender: TObject);
    procedure MM1_View_MinImageSizeClick(Sender: TObject);
    procedure MM1_View_ResetClick(Sender: TObject);
    procedure MM1_View_WrapAroundModeClick(Sender: TObject);
    procedure MU(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure MWD(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure MWU(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
      var Handled: Boolean);
    procedure OP(Sender: TObject);
    procedure ORSize(Sender: TObject);
    procedure PB1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    procedure InitPBCv;
    procedure InitCanvas;
    procedure ResizeCanvas(const SetSize:Integer);
    procedure LoadImageAt(const FilePathName:String);
    procedure ResizePBView;
    procedure LoadPNGxy;
    procedure LoadPNGxyHD;
    procedure MWDown(var AScrollValue,MouseX,MouseY:Integer;const ASpeed:Single);
    procedure MWUp(var AScrollValue,MouseX,MouseY:Integer;const ASpeed:Single);
    procedure DrawAll(const Ix,Iy,AWidth,AHeight:Integer);
    function RR(const X:Real):Integer;
    function GetFileName:String;
  end;

var
  Form1:TForm1;
  FPN:String;
  Pic:TPicture;
  PBView:TPortableNetworkGraphic;
  PNGxy:TPortableNetworkGraphic;
  PBCv:TPortableNetworkGraphic;
  MDown:Boolean;
  MIx:Integer;
  MIy:Integer;
  DrawBool:Boolean;
  ScrollValue:Integer;
  ScrollValueP:Integer;
  MIxy:TPoint;
  MIwh:TPoint;
  StrParam:Boolean;
  FilePN:String;
  boolHD:Boolean;
  boolDAll:Boolean;
  DoubleClickBool:Boolean;
  ADataxy:Integer;
  BDataxy:Integer;
  MDIx:Integer;
  MDIy:Integer;

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

    if(boolHD=False)then LoadPNGxy
    else LoadPNGxyHD;
    InitCanvas;
    DrawBool:=True;
  end;
end;

procedure TForm1.MM1_File_SaveAsClick(Sender: TObject);
begin
  if(FPN='')then Exit;
  if(SaveD.Execute)then Pic.SaveToFile(SaveD.FileName);
end;

procedure TForm1.MM1_View_MaxImageSizeClick(Sender: TObject);
begin
  if(FPN<>'')then begin
    boolHD:=True;
    LoadPNGxyHD;
  end;
  DrawBool:=True;
end;

procedure TForm1.MM1_View_MinImageSizeClick(Sender: TObject);
begin
  if(FPN<>'')then begin
    boolHD:=False;
    LoadPNGxy;
  end;
  DrawBool:=True;
end;

procedure TForm1.MM1_View_ResetClick(Sender: TObject);
begin
  if(FPN<>'')then InitCanvas;
  DrawBool:=True;
end;

procedure TForm1.MM1_View_WrapAroundModeClick(Sender: TObject);
begin
  if(boolDAll=False)then boolDAll:=True
  else boolDAll:=False;
end;

procedure TForm1.MU(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  MDown:=False;
  DoubleClickBool:=False;
end;

procedure TForm1.MWD(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin
  MWDown(ScrollValue,MousePos.X,MousePos.Y,1.26);
end;

procedure TForm1.MWU(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin
  MWUp(ScrollValue,MousePos.X,MousePos.Y,1.26);
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

procedure TForm1.PB1DblClick(Sender: TObject);
begin
  DoubleClickBool:=True;
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
  ResizePBView;
  AWidth:=MIxy.X+MIwh.X;
  AHeight:=MIxy.Y+MIwh.Y;

  if(boolDAll=False)then
    PBView.Canvas.StretchDraw(Rect(MIxy.X,MIxy.Y,AWidth,AHeight),PNGxy)
  else
    DrawAll(MIxy.X,MIxy.Y,MIwh.X,MIwh.Y);

  PBCv.SetSize(PB1.Width,PB1.Height);

  PBCv.Canvas.Brush.Color:=$00A36E00;
  PBCv.Canvas.FillRect(0,0,PB1.Width,PB1.Height);

  PBCv.Canvas.StretchDraw(Rect(0,0,PBCv.Width,PBCv.Height),PBView);
end;

procedure TForm1.InitCanvas;
var
  AWidth:Integer;
  AHeight:Integer;
  Ixy:TPoint;
  TempX,TempY:Integer;
begin
  ResizePBView;
  if(Pic.Width>=Pic.Height)then begin
    if(Pic.Width=0)then TempX:=1 else TempX:=Pic.Width;
    AWidth:=PBView.Height;
    AHeight:=RR((PBView.Height*Pic.Height)/TempX);
  end else
  if(Pic.Width<Pic.Height)then begin
    if(Pic.Height=0)then TempY:=1 else TempY:=Pic.Height;
    AWidth:=RR((PBView.Height*Pic.Width)/TempY);
    AHeight:=PBView.Height;
  end;
  Ixy.X:=(PBView.Width div 2)-(AWidth div 2);
  Ixy.Y:=(PBView.Height div 2)-(AHeight div 2);
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

    if(boolHD=False)then LoadPNGxy
    else LoadPNGxyHD;
    InitCanvas;
    DrawBool:=True;
  end;
end;

procedure TForm1.ResizePBView;
begin
  PBView.SetSize(RR(PB1.Width/2),RR(PB1.Height/2));

  PBView.Canvas.Brush.Color:=$00A36E00;
  PBView.Canvas.FillRect(0,0,PBView.Width,PBView.Height);
end;

procedure TForm1.LoadPNGxy;
var
  AWidth,AHeight:Integer;
begin
  if(Pic.Width>=Pic.Height)then begin
    AWidth:=RR(((Pic.Width/2)*Pic.Width)/Pic.Width);
    AHeight:=RR(((Pic.Height/2)*Pic.Height)/Pic.Width);
  end else begin
    AWidth:=RR(((Pic.Width/2)*Pic.Width)/Pic.Height);
    AHeight:=RR(((Pic.Height/2)*Pic.Height)/Pic.Height);
  end;
  PNGxy.SetSize(AWidth,AHeight);
  PNGxy.Canvas.Brush.Color:=$00A36E00;
  PNGxy.Canvas.FillRect(0,0,AWidth,AHeight);
  PNGxy.Canvas.StretchDraw(Rect(0,0,AWidth,AHeight),Pic.PNG);
end;

procedure TForm1.LoadPNGxyHD;
begin
  PNGxy.SetSize(Pic.Width,Pic.Height);
  PNGxy.Canvas.Brush.Color:=$00A36E00;
  PNGxy.Canvas.FillRect(0,0,Pic.Width,Pic.Height);
  PNGxy.Canvas.StretchDraw(Rect(0,0,Pic.Width,Pic.Height),Pic.PNG);
end;

procedure TForm1.MWDown(var AScrollValue, MouseX, MouseY: Integer;
  const ASpeed: Single);
var
  AWidth,AHeight:Integer;
  PosX,PosY:Integer;
begin
  if(MIwh.X<=100)or(MIwh.Y<=100)then begin
    While(AScrollValue<=5)do begin
      if(MIwh.X>=MIwh.Y)then begin
        AScrollValue:=RR(((MIwh.X*50)/MIwh.Y)*ASpeed);
      end else
      if(MIwh.X<MIwh.Y)then begin
        AScrollValue:=RR(((MIwh.Y*50)/MIwh.X)*ASpeed);
      end;
    end;
  end;

  AWidth:=MIwh.X;
  AHeight:=MIwh.Y;
  PosX:=RR(((PB1.Width/2)*MouseX)/PB1.Width);
  PosY:=RR(((PB1.Height/2)*MouseY)/PB1.Height);

  ResizeCanvas(AScrollValue);
  if(MIwh.X>=MIwh.Y)then begin
    AScrollValue:=RR(((MIwh.X*50)/MIwh.Y)*ASpeed);
  end else
  if(MIwh.X<MIwh.Y)then begin
    AScrollValue:=RR(((MIwh.Y*50)/MIwh.X)*ASpeed);
  end;

  MIxy.X:=RR(PosX+((MIwh.X*(MIxy.X-PosX))/AWidth));
  MIxy.Y:=RR(PosY+((MIwh.Y*(MIxy.Y-PosY))/AHeight));

  InitPBCv;
  DrawBool:=True;
end;

procedure TForm1.MWUp(var AScrollValue, MouseX, MouseY: Integer;
  const ASpeed: Single);
var
  AWidth,AHeight:Integer;
  PosX,PosY:Integer;
begin
  if(MIwh.X<100)or(MIwh.Y<100)then Exit;

  AWidth:=MIwh.X;
  AHeight:=MIwh.Y;
  PosX:=RR(((PB1.Width/2)*MouseX)/PB1.Width);
  PosY:=RR(((PB1.Height/2)*MouseY)/PB1.Height);

  ResizeCanvas(-AScrollValue);
  if(MIwh.X>=MIwh.Y)then begin
    AScrollValue:=RR(((MIwh.X*50)/MIwh.Y)/ASpeed);
  end else
  if(MIwh.X<MIwh.Y)then begin
    AScrollValue:=RR(((MIwh.Y*50)/MIwh.X)/ASpeed);
  end;

  MIxy.X:=RR(PosX+((MIwh.X*(MIxy.X-PosX))/AWidth));
  MIxy.Y:=RR(PosY+((MIwh.Y*(MIxy.Y-PosY))/AHeight));

  InitPBCv;
  DrawBool:=True;
end;

procedure TForm1.DrawAll(const Ix, Iy, AWidth, AHeight: Integer);
var
  AIx,AIy,RecX,RecY:Integer;
begin
  AIx:=Ix;
  AIy:=Iy;
  While(True)do begin
    if(AIx<=0)and(AIy<=0)then Break;
    if(AIx>0)then AIx:=AIx-AWidth;
    if(AIy>0)then AIy:=AIy-AHeight;
  end;
  RecX:=AIx;
  RecY:=AIy;
  While(True)do begin
    if(RecX>PBView.Width)then begin
      RecY:=RecY+AHeight;
      RecX:=AIx;
    end;
    if(RecY>PBView.Height)then Break;
    PBView.Canvas.StretchDraw(Rect(RecX,RecY,RecX+AWidth,RecY+AHeight),PNGxy);
    RecX:=RecX+AWidth;
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
  PBView:=TPortableNetworkGraphic.Create;
  PNGxy:=TPortableNetworkGraphic.Create;
  PBCv:=TPortableNetworkGraphic.Create;
  ScrollValue:=10;
  ScrollValueP:=10;
  ADataxy:=0;
  BDataxy:=0;
  if(ParamCount>0)then begin
    StrParam:=True;
    FilePN:=ParamStr(1);
  end else begin
    StrParam:=False;
  end;
  boolHD:=False;
  boolDAll:=False;
  DoubleClickBool:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Pic.Free;
  PBView.Free;
  PNGxy.Free;
  PBCv.Free;
end;

procedure TForm1.MD(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if(Button=mbMiddle)or(Button=mbLeft)or(DoubleClickBool=True)then begin
    MDown:=True;
    MIx:=RR(((PB1.Width/2)*X)/PB1.Width);
    MIy:=RR(((PB1.Height/2)*Y)/PB1.Height);
    MDIx:=RR(((PB1.Width/2)*X)/PB1.Width);
    MDIy:=RR(((PB1.Height/2)*Y)/PB1.Height);
  end;
end;

procedure TForm1.ML(Sender: TObject);
begin
  MDown:=False;
  DoubleClickBool:=False;
end;

procedure TForm1.MM(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  AIx,AIy:Integer;
begin
  if(DoubleClickBool=True)then begin
    BDataxy:=ADataxy;
    ADataxy:=RR(((100*(X+Y))/(PB1.Width+PB1.Height))-50);
    if(ADataxy>0)and(ADataxy=BDataxy)then MWDown(ScrollValue,MDIx,MDIy,0.5) else
    if(ADataxy<0)and(ADataxy=BDataxy)then MWUp(ScrollValue,MDIx,MDIy,3.5);
  end else
  if(MDown=True)then begin
    AIx:=RR(((PB1.Width/2)*X)/PB1.Width);
    AIy:=RR(((PB1.Height/2)*Y)/PB1.Height);
    MIxy.SetLocation(MIxy.X+(AIx-MIx),MIxy.Y+(AIy-MIy));
    MIx:=AIx;
    MIy:=AIy;
    InitPBCv;
    DrawBool:=True;
  end;
end;

procedure TForm1.MM1_About_CreditClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

end.

