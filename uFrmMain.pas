UNIT uFrmMain;

interface

uses
  uCola,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Vcl.Imaging.pngimage, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    MainMenu : TMainMenu;
    Juego1 : TMenuItem;
    Jugar  : TMenuItem;
    N1     : TMenuItem;
    Salir  : TMenuItem;
    Label1: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure JugarClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  private
    User   : PCB;       //Para almacenar al personaje del usuario.  Este PCB no se encolará, y por tanto no lo manipulará el PlanificadorRR.
    Q      : Cola;      //Cola del Planificador RR.
    Estado : Integer;   //0=No pasa nada, 1=Murió el User, 2=Murió la Nave, 3 = Gana el user
    Turno : string;     // turno de movimiento para la nave en traslacion
    Limite : Integer;   // limite de pixeles para las naves que se mueven en su propio lugar


    procedure InitJuego();
    procedure CicloJuego;
    procedure Dibujar(P:PCB);
    procedure cls;

    procedure Borrar(P:PCB);
    procedure Rectangulo(x,y, Ancho, Alto, color: Integer);
    function MaxX : Integer;
    function MaxY : Integer;

    procedure PlanificadorRR;
    procedure MoverNave(PRUN : PCB);
    procedure MoverBalaUser(PRUN : PCB);
    procedure MoverBalaNave(PRUN : PCB);

    procedure CrearNave(anchoNave, altoNave, posX, posY:integer);
    procedure CrearBalaNave(anchoBala, altoBala:integer; PRUN:PCB);
    function colisionNave(PRUNBALA, PRUNNAVE:PCB):bool;
    function colisionUser(PRUNBALA:PCB):bool;
    procedure RectanguloImagen(x, y : Integer; Imagen : TGraphic);
    function cargarImg(dir: string):TPngImage;
  public

  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
begin
  Q := Cola.Create;    //Construir (new) la cola del PlanificadorRR.
end;

procedure TForm1.JugarClick(Sender: TObject);
begin
  InitJuego();

end;

procedure TForm1.SalirClick(Sender: TObject);
begin
  Estado := 100;   //Para salir del ciclo del Juego
  Application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SalirClick(Sender);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
 var
   P : PCB;

begin
   case Key of
     VK_RIGHT : begin  //El user pulsó la tecla Flecha-Derecha
                   Borrar(User);
                   User.x := User.x + 10;
                   if User.x > MaxX - User.Ancho then
                      User.x := MaxX - User.Ancho;
                   Dibujar(User);
                end;

      VK_LEFT : begin   //El user pulsó la tecla Flecha-Izquierda
                   Borrar(User);
                   User.x := User.x - 10;
                   if (user.x < 0) then
                       user.x := 0;

                   Dibujar(User);
                 end;

      VK_UP : begin
                Borrar(User);
                User.y := User.y - 10;
                if User.y < 60 then
                  User.y := 60;
                Dibujar(User);
              end;

      VK_DOWN : begin
                Borrar(User);
                User.y := User.y + 10;
                if User.y > MaxY - User.Alto then
                  User.y := MaxY - User.Alto;
                Dibujar(User);
              end;

      VK_SPACE : begin   //Crear un proceso BALAU
                   P.Tipo  := BALAU;
                   P.Ancho := 16;
                   P.Alto  := 16;

                   P.x     := (User.Ancho-P.Ancho) div 2 + User.x;
                   P.y     :=  User.y - P.Alto;

                   P.Retardo := 50;
                   P.Hora    := GetTickCount;
                   P.img := cargarImg('balaU.png');
                   Dibujar(P);

                   Q.Meter(P);
                 end;
   end;
end;

procedure TForm1.InitJuego;
  var
    N : PCB;
    i, j : integer;
begin
  cls();      //Borrar el formulario
  Q.Init();   //Vaciar la cola

  //Posicionar, dibujar y meter la nave a la cola Q.
  for i := 0 to 7 do
  begin
    for j := 0 to 2 do
    begin
      CrearNave(32, 32, 200 + i * 100, 5 + j * 60);
    end;
  end;

  // damos opcion de moverse a una nave
  N := Q.Sacar;
  N.traslacion := true;
  Q.Meter(N);
  Turno := 'DER-ABA';
  Limite := 0;

    //Posicionar y dibujar el cañon (personaje del user).
  User.Tipo := NAVEU;
  User.Ancho := 32;
  User.Alto   := 32;
  User.x := (ClientWidth - User.Ancho) DIV 2;
  User.y := MaxY - User.Alto - 1;
  User.img := cargarImg('nave.png');
  Dibujar(User);

  CicloJuego();

end;

procedure TForm1.CicloJuego;
begin
    Estado := 0;
    while (Estado = 0) do
      begin
        PlanificadorRR();
        Application.ProcessMessages();   //Para que se procesen eventos (click, teclas, etc)
      end;
end;


procedure TForm1.PlanificadorRR;
var
  PRUN: PCB;

begin
  PRUN := Q.Sacar();

  if PRUN.Hora + PRUN.Retardo > GetTickCount then
    Q.Meter(PRUN)
  else
  begin
    if Q.Cant(NAVE) = 0 then // si ya no hay naves el proceso finaliza
    begin
      ShowMessage('Ganaste!!!');
      Estado := 100;
    end
    else if Estado = 1 then
      ShowMessage('Game Over...')
    else
    case PRUN.Tipo of
      NAVE:
        MoverNave(PRUN);
      BALAU:
        MoverBalaUser(PRUN);
      BALAN:
        MoverBalaNave(PRUN);
    end;
  end;
end;

procedure TForm1.crearNave(anchoNave, altoNave, posX, posY: INTEGER);
var
  NAV : PCB;
begin
  NAV.Tipo := NAVE;
  NAV.Ancho := anchoNave;
  NAV.Alto := altoNave;
  NAV.x := (posX - NAV.Ancho) div 2;
  NAV.y := posY;
  NAV.Hora := GetTickCount;
  NAV.Retardo := 100;
  Nav.img :=  cargarImg('alien.png');
  NAV.traslacion := false;
  Dibujar(NAV);
  Q.Meter(NAV);
end;

procedure TForm1.CrearBalaNave(anchoBala, altoBala:integer; PRUN:PCB);
var
  BALA : PCB;
begin
  BALA.Tipo := BALAN;
  BALA.Ancho := anchoBala;
  BALA.Alto := altoBala;
  BALA.x := (PRUN.Ancho - BALA.Ancho) div 2 + PRUN.x;
  BALA.y := PRUN.y + PRUN.Alto + BALA.Alto;
  BALA.Retardo := 50;
  BALA.Hora := GetTickCount;
  BALA.img := cargarImg('balaN.png');
  Dibujar(BALA);

  Q.Meter(BALA);
end;

function TForm1.cargarImg(dir: string):TPngImage;
var
  imagen : TPngImage;
begin
  imagen := TPngImage.Create;
  imagen.LoadFromFile(dir);
  Result := imagen;
end;

procedure TForm1.MoverNave(PRUN: PCB);
var
  P : PCB;
begin
  Borrar(PRUN);

  //mover la nave por todo el canvas
  if PRUN.traslacion then
  begin
    Label1.Caption := Turno;
    if (Turno = 'DER-ABA') then
    begin
      PRUN.x := PRUN.x + 5;
      PRUN.y := PRUN.y + 5;
      if PRUN.y + PRUN.Alto >= ClientHeight then
        Turno := 'DER-ARR';
      if PRUN.x + PRUN.Ancho >= ClientWidth then
        Turno := 'IZQ-ABA';


    end;

    if (Turno = 'DER-ARR') then
    begin
       PRUN.x := PRUN.x + 5;
       PRUN.y := PRUN.y - 5;
       if PRUN.x + PRUN.Ancho >= ClientWidth then
        Turno := 'IZQ-ARR';
       if PRUN.y <= 0 then
        Turno := 'DER-ABA';

    end;

    if (Turno = 'IZQ-ARR') then
    begin
      PRUN.x := PRUN.x - 5;
      PRUN.y := PRUN.y - 5;

      if PRUN.y <= 0 then
        Turno := 'IZQ-ABA';
      if PRUN.x <= 0 then
        Turno := 'DER-ARR';
    end;

    if Turno = 'IZQ-ABA' then
    begin
      PRUN.x := PRUN.x - 5;
      PRUN.y := PRUN.y + 5;
      if PRUN.x <= 0 then
        Turno := 'DER-ABA';
      if PRUN.y + PRUN.Alto >= ClientHeight then
        Turno := 'IZQ-ARR';
    end;

    //colision: puede chocar con la parte de arriba o izq del usuario
      if (PRUN.x + PRUN.Ancho = User.x) and
       ((PRUN.y >= User.y) and (PRUN.y <= User.y + User.Alto) or
       (PRUN.y + PRUN.Alto >= User.y) and (PRUN.y + PRUN.Alto <= User.y + User.Alto)) or  //choca izq

       (PRUN.y + PRUN.Alto = User.y - 1) and
       ((PRUN.x >= User.x) and (PRUN.x <= User.x + User.Ancho) or
       (PRUN.x + PRUN.Ancho >= User.x) and (PRUN.x + PRUN.Ancho <= User.x + User.Ancho)) or  //choca arriba

       (PRUN.x -2 = User.x + User.Ancho) and
       ((PRUN.y >= User.y) and (PRUN.y <= User.y + User.Alto) or
       (PRUN.y + PRUN.Alto >= User.y) and (PRUN.y + PRUN.Alto <= User.y + User.Alto)) then   //choca der
      begin
        ShowMessage('Choco la nave');
        Estado := 100;
      end;

  end
  else begin

  end;

  Dibujar(PRUN);
  PRUN.Hora := GetTickCount;
  Q.Meter(PRUN);

    //Disparar
  if Random(200)= 0 then
  begin  //Crear un proceso BALAN
    CrearBalaNave(17, 16, PRUN);
  end;

end;


procedure TForm1.MoverBalaNave(PRUN: PCB);
var
  h : bool;
  explosion : TPngImage;
begin  // Algoritmo para mover la bala de la nave (BALAN)
  Borrar(PRUN);
  PRUN.y := PRUN.y + 5;

    h := false;
    if colisionUser(PRUN) then
    begin
      explosion := TPngImage.Create;
      explosion.LoadFromFile('explosion.png');
      Canvas.Draw(User.x, User.y, explosion);
      ShowMessage('Game over...');
      Estado := 1;
      h := true;
    end;

  PRUN.Hora := GetTickCount;
  if not(h) then
  begin
    Dibujar(PRUN);
    Q.Meter(PRUN);
  end;
end;

procedure TForm1.MoverBalaUser(PRUN: PCB);
var
  Qaux : Cola;
  PRUNNAVE : PCB;
  h : bool;
begin
  Borrar(PRUN);
  PRUN.y := PRUN.y - 5;


    Qaux := Cola.Create;
    Qaux.Init;

    while not(Q.Vacia) do
    begin
      h := false;
      PRUNNAVE := Q.Sacar;
      if PRUNNAVE.Tipo = NAVE then
      begin
        //preguntar si choca
          if colisionNave(PRUN, PRUNNAVE) then
          begin
            Borrar(PRUNNAVE);
            Borrar(PRUN);
            h := true;
            break;
          end
          else begin
            Qaux.Meter(PRUNNAVE);
          end;
      end
      else
         Qaux.Meter(PRUNNAVE);
    end;

    //metemos los que faltan a la cola
    while not(Q.Vacia) do
    begin
      PRUNNAVE := Q.Sacar;
      Qaux.Meter(PRUNNAVE);
    end;
    Q := Qaux;
    PRUN.Hora := GetTickCount;
    if not(h) then
    begin
      Dibujar(PRUN);
      Q.Meter(PRUN);
    end;

end;

function TForm1.colisionNave(PRUNBALA, PRUNNAVE:PCB):bool;
begin
   if (PRUNBALA.x >= PRUNNAVE.x) and (PRUNBALA.x < PRUNNAVE.x + PRUNNAVE.Ancho - 5)
          and (PRUNBALA.y = PRUNNAVE.y + PRUNNAVE.Alto - 5) then
      Result := true
   else
      Result:= false;
end;

function TForm1.colisionUser(PRUNBALA:PCB):bool;
begin
   if (PRUNBALA.y + PRUNBALA.Alto - 1 = User.y) and (PRUNBALA.x > User.x)
   and (PRUNBALA.x < User.x + User.Ancho) then
      Result := true
   else
      Result := false;

end;







// ***** Funciones para Manipular los "Gráficos".
procedure TForm1.cls;
begin  //Borra el Canvas del Form
  Rectangulo(0,0,ClientWidth, ClientHeight, SELF.Color);
end;


procedure TForm1.Dibujar(P: PCB);
begin  //Dibuja al PCB P como un rectangulo en la pantalla.
  RectanguloImagen(P.x, P.y, P.img);
end;


procedure TForm1.Borrar(P: PCB);
begin //Dibuja al PCB P como un rectangulo en la pantalla, del mismo color del Form.
  Rectangulo(P.x, P.y, P.Ancho, P.Alto + 1, SELF.Color);
end;


procedure TForm1.Rectangulo(x, y, Ancho, Alto, Color: Integer);
begin   //Dibuja un rectangulo con esquina superior Izq en (x,y).
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(x, y, x+Ancho-1, y+Alto-1);
end;

procedure TForm1.RectanguloImagen(x, y : Integer; Imagen : TGraphic);
begin
  Canvas.Draw(x, y, Imagen);
end;



function TForm1.MaxX: Integer;
begin
  RESULT := ClientWidth-1;
end;


function TForm1.MaxY: Integer;
begin
  RESULT := ClientHeight-1;
end;

END.
