// Модуль с математическими функциями и процедурами

unit math;

interface
uses SysUtils,
    types;


function Sign(n: extended): shortint;

function ArcTg(x, y: extended) :extended;

function Arctg2(x, y: extended): extended;

function ArcSin(x: extended): extended;

function Reduce(angle: extended): extended;

function sid2000(jd: extended): extended; {v radianah}

function date_jd(year, month: integer; day: extended): extended;

procedure perehod(HH: extended; xx: types.MAS; var lambda, phi: extended);


implementation


function sid2000(jd: extended): extended; {v radianah}
// Вычисление звёздного времени по Юлианской дате
const jd2000 = 2451545;
      jdyear = 36525;
var m,mm,d,t,s,sr: extended;
begin
    m := frac(jd) - 0.5;
    d := jd - m - jd2000;

    t := (d + m)/jdyear;
    mm := m*86400;
    s := (24110.54841+mm+236.555367908*(d+m)+(0.093104*t-6.21E-6*sqr(t))*t)/86400*2*pi;
    sid2000 := s;
end; {sid2000}


function date_jd(year, month: integer;
                day: extended): extended;
// Определение Юлианской даты
label 1;
const han = 100;
var m1,d,date,jd: extended;
    i,me,ja,jb: integer;
begin
    date := year + month/100 + day/1e4;
    i := trunc(date);
    m1 := (date - i)*han;
    me := trunc(m1);
    d := (m1 - me)*han;
    if (me > 2) then goto 1;
    i := i - 1;
    me := me + 12;
1:  jd := trunc(365.25*i) + trunc(30.6001*(me+1)) + d + 1720994.5;
    if (date<1582.1015) then
    begin
        date_jd := jd;
        exit;
    end;
    ja := trunc(i/100.0);
    jb := 2 - ja + trunc(ja/4);
    jd := jd+jb;
    date_jd := jd;
end; {date_jd()}


function Reduce(angle: extended): extended;
// Приведение угла к интервалу [-pi; pi]
const PI2 = 2*pi;
begin
    Result := angle - trunc(angle/PI2) * PI2;

    if (angle < 0) then
        Result := Result + PI2;
end;


function Sign(n: extended): shortint;
// Знак числа n
begin
    if (n > 0) then Sign := 1
    else
        if (n < 0) then Sign := -1
        else Sign := 0;
end; {Sign}


function ArcTg(x, y: extended): extended;
// Арктангес числа x/y в радианах
var a: extended;
begin
    if (abs(y) < 1e-18) then ArcTg := sign(x)*0.5*Pi
    else
    begin
        a := ArcTan(x/y);
        if (y < 0) then a := a+Pi;
        if (a < 0) then a := a+2*Pi;
        ArcTg := a;
    end;
end; {ArcTg}


function Arctg2(x, y: extended): extended;
// Арктангенс числа x/y в радианах с учётом четвертей
var a: extended;
begin
    if (abs(y)<1e-18) then
        if (x>0) then
            Arctg2 := sign(x)*0.5*pi
        else
            Arctg2 := -sign(x)*0.5*pi
    else
    begin
        a := ArcTan(x/y);
        if (y>0) then

        else if (x>=0) then
                a := a + pi
            else
                a := a - pi;

        Arctg2 := a;
    end;
end; {Arctg2}


function ArcSin(x: extended): extended;
// Арксинус числа в пределах [-pi/2; pi/2] в радианах
begin
    if (x < 1.0) and (x > -1.0) then
        Arcsin := ArcTan(x/sqrt(1 - sqr(x)))
    else
        if ((abs(x) - 1.0) < 1e-18) then ArcSin := Sign(x)*Pi/2
        else
        begin
            Writeln('Error: Argument of ArcSin >1.0 or <-1.0', x);
            Halt;
        end;
end; {Arcsin}


procedure perehod(HH: extended;
                  xx: types.MAS;
                  var lambda, phi: extended);
// Переход во вращающуюся СК
var A: array[1..3,1..3] of extended;
    i, j: integer;
    s, r, argum: extended;
    yy: mas;
begin

    A[1,1] := cos(HH);     A[1,2] := sin(HH);    A[1,3] := 0;
    A[2,1] := -sin(HH);    A[2,2] := cos(HH);    A[2,3] := 0;
    A[3,1] := 0;           A[3,2] := 0;          A[3,3] := 1;

    for i:=1 to 3 do
    begin
        s := 0;
        for j:=1 to 3 do
            s := s + A[i,j]*xx[j];
        yy[i] := s;
    end;
    r := sqrt(yy[1]*yy[1] + yy[2]*yy[2] + yy[3]*yy[3]);

    lambda := arctg(yy[2], yy[1]);

    argum := yy[3]/r;
    phi := arcsin(argum);
end; {perehod}


begin
end.