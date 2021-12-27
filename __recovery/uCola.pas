UNIT uCola;


                             INTERFACE
uses Graphics;
CONST
  NAVE  = 0;
  BALAU = 1;
  BALAN = 2;
  NAVEU = 3;


TYPE
  PCB = RECORD
          PID  : Integer;
          Dir  : Integer;
          Tipo : Integer;    //NAVE, BALAU, BALAN.
          x, y, Ancho, Alto : Integer;
          img : TGraphic;
          traslacion : boolean;
          Limite : Integer;
          Hora, Retardo             : Cardinal;
        END;


CONST
  MAX = 200;

TYPE
  Cola = class
    private
      V : Array[1..MAX] of PCB;   //Implementacion: Cola Circular
      F, A : Integer;

      function next(n : Integer) : Integer;

    public
      constructor Create;
        //Construye una cola vacía.

      procedure Init;
        //Inicializa la cola.  Es decir, pone a la cola vacía.

       function Vacia : Boolean;
        //Devuelve true si y solo si la cola está vacía.

      function Llena : Boolean;
        //Devuelve true si y solo si la cola está llena (ya no se pueden insertar más PCB's).

      function Length : Integer;
       //Devuelve la cantidad de elementos de la cola.

      procedure Meter(P : PCB);
       //Inserta P a la cola.

      function Sacar : PCB;
       //Saca un PCB de la cola.

     function Cant(Tipo : Integer) : Integer;
       //Devuelve la cantidad de elementos encolados, que tienen el Tipo especificado.
       //e.g. Cant(BALAU) devuelve la cantidad de PCB's encolados, cuyo Tipo=BALAU
  end;


  
                          IMPLEMENTATION
uses SysUtils;

constructor Cola.Create;
begin
  Init();
end;

procedure Cola.Init;
begin
  A := 0;
end;


function Cola.Vacia: Boolean;
begin
  Result := (A = 0);
end;

function Cola.Llena: Boolean;
begin
  Result := (Length() = MAX);
end;

function Cola.Length: Integer;
begin
  if (A=0) then
     RESULT := 0
  else
    if (F <= A) then
       RESULT := A-F+1
    else
      RESULT := A + (MAX-F+1);
end;

procedure Cola.Meter(P: PCB);
begin
  if Llena() then
     raise Exception.Create('Cola.Meter: Cola llena.');

  if (A = 0) then
     begin  //Primera inserción.
       A:=1;  F:=1;
     end
  else
    A := next(A);

  V[A] := P;
end;


function Cola.Sacar: PCB;
begin
  if Vacia() then
     raise Exception.Create('Cola.Sacar: Cola vacía.');

  RESULT := V[F];

  if (F=A) then   //Se está quitando el único elemento...
     Init()       //...dar condición de vacío.
  else
    F := next(F);
end;


function Cola.Cant(Tipo: Integer): Integer;
  var
    i, pos, c : integer;

begin  //Devuelve la cantidad de elementos encolados, que tienen el Tipo especificado.
  c := 0;
  pos := F;

  for i:=0 to Length() do
  begin
    if V[pos].Tipo = Tipo then
       Inc(c);

    pos := next(pos);
  end;

  Result := c;
end;


function Cola.next(n: Integer): Integer;
begin  //Índice siguiente, circularmente hablando.
  Result := (n mod MAX) + 1;
end;

END.
