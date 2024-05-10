// Модуль с различными вспомогательными функциями и процедурами

unit service;

interface
uses SysUtils,
    readfond,
    config,
    types,
    constants;

procedure fond405(jd: extended; 
                var xm_, xs_, vm_, vs_: types.MAS);

function _InsertGaps(phi: types.ANGLE_DATA;
                    res, len: integer): types.ANGLE_DATA;

procedure OutNET(net: types.NETWORK);

procedure OutFlag(flag: types.FLAGS);

procedure FillZero(var net, net2, net3: types.NETWORK;
                    var flag, flag2, flag3: types.FLAGS;
                    var t: types.TIME_DATA;
                    var phi, phi2, phi3: types.ANGLE_DATA;
                    var dot_phi, dot_phi2, dot_phi3: types.ANGLE_DATA);

procedure FillNetsAndArrays(TYPE_: boolean;
                            num, idx, time_idx: integer;
                            var angles, freq: types.ARR;
                            var net: types.NETWORK;
                            var flag: types.FLAGS;
                            var phi, dot_phi: types.ANGLE_DATA);

procedure Warning(const path: string);

function _Length(phi: types.ANGLE_DATA;
                res: integer): integer;

function _isDecrease(current, next: extended): boolean;

function _isIncrease(current, next: extended): boolean;

function _isDecreaseBranch(current, next: extended): boolean;

function _isIncreaseBranch(current, next: extended): boolean;

implementation



procedure fond405(jd: extended;
                var xm_, xs_, vm_, vs_: types.MAS);
// Чтение координат и скоростей Луны и Солнца из фонда координат
var x_planet: readfond.masc;
begin
    read405(0, 1, jd, x_planet);
    // процедура выдает координаты и скорости Луны и Солнца в геоцентрической
    // экваториальной — км и км/с

    // переход в геоцентрическую экваториальную — в км

    // координаты Луны и Солнца
    xm_[1] := (x_planet[55] - x_planet[13]) * a_e;  //
    xm_[2] := (x_planet[56] - x_planet[14]) * a_e;  //
    xm_[3] := (x_planet[57] - x_planet[15]) * a_e;  //   {xle=xl-xe}

    xs_[1] := -x_planet[13] * a_e;  //
    xs_[2] := -x_planet[14] * a_e; //
    xs_[3]:= - x_planet[15] * a_e; //    {xs=-xe }

    //скорости Луны и Солнца
    vm_[1] := (x_planet[58] - x_planet[16]) * a_e/86400;
    vm_[2] := (x_planet[59] - x_planet[17]) * a_e/86400;
    vm_[3] := (x_planet[60] - x_planet[18])*a_e/86400;     {vle=vl-ve}

    vs_[1] := -x_planet[16] * a_e/86400;
    vs_[2] := -x_planet[17] * a_e/86400;
    vs_[3] := -x_planet[18] * a_e/86400;     {vs=-ve}
end; {fond405}



function _InsertGaps(phi: ANGLE_DATA; res, len: integer): ANGLE_DATA;
var i, j: integer;
    phi_with_gaps: types.ANGLE_DATA;
begin
    for i := 1 to 2000 do
        phi_with_gaps[res, i] := 0;

    i := 1;
    j := 1;
    while i < len do
    begin
        phi_with_gaps[res, j] := phi[res, i];

        if (abs(phi[res, i] - phi[res, i+1]) > 240) then
        begin
            phi_with_gaps[res, j+1] := 1e6;
            j := j + 2;
        end
        else
            inc(j);

        inc(i);
    end;

    phi_with_gaps[res, j] := phi[res, len];

    _InsertGaps := phi_with_gaps;
end;



procedure Warning(const path: string);
var input: string; // Ввод пользователя
begin
    if FileExists(path) then
    begin
        write('Файл ' + path + ' уже существует. Перезаписать? [y/n]: ');
        readln(input);
        if (input = 'n') then
            halt;
    end;
end;


function _Length(phi: types.ANGLE_DATA;
                res: integer): integer;
// Возвращает длину массива phi[res]
begin
    Result := 1;
    while not (phi[res, Result+1] < 1e-6) do
        inc(Result);
end; {_Length}



procedure OutNET(net: types.NETWORK);
// Вывод матриц
var
    num, row, col: integer;
begin
    for num := config.RES_START to config.RES_FINISH do
    begin
        writeln('num = ', num);
        for row := 1 to config.ROWS do
        begin
            for col := 1 to config.COLS do
            begin
                write(net[num, row, col], #9);
            end;
            writeln;
        end;
        writeln;
    end;
end; {OutNET}



procedure OutFlag(flag: types.FLAGS);
// Вывод в консоль массива флагов для либрации
var idx, time_idx: integer;
begin
    writeln('[FLAG]');
    for idx := config.RES_START to config.RES_FINISH do
    begin
        for time_idx := 1 to config.LIBRATION_ROWS do
            write(flag[idx, time_idx], config.DELIMITER);
        writeln;
    end;
end; {OutFlag}



procedure FillZero(var net, net2, net3: types.NETWORK;
                    var flag, flag2, flag3: types.FLAGS;
                    var t: types.TIME_DATA;
                    var phi, phi2, phi3: types.ANGLE_DATA;
                    var dot_phi, dot_phi2, dot_phi3: types.ANGLE_DATA);
// Заполнение массивов нулями
var num, row, col: integer;
begin
    for num := config.RES_START to config.RES_FINISH do
    begin
        for row := 1 to config.ROWS do
            for col := 1 to config.COLS do
            begin
            net[num, row, col] := 0;
            net2[num, row, col] := 0;
            net3[num, row, col] := 0;
            end;

        for row := 1 to 2000 do
        begin
            t[row] := 0;

            phi[num, row] := 0;
            phi2[num, row] := 0;
            phi3[num, row] := 0;

            dot_phi[num, row] := 0;
            dot_phi2[num, row] := 0;
            dot_phi3[num, row] := 0;
        end;

        for row := 1 to config.LIBRATION_ROWS do
        begin
            flag[num, row] := 0;
            flag2[num, row] := 0;
            flag3[num, row] := 0;
        end;
    end;
end; {FillZero}



procedure FillNetsAndArrays(TYPE_: boolean;
                            num, idx, time_idx: integer;
                            var angles, freq: types.ARR;
                            var net: types.NETWORK;
                            var flag: types.FLAGS;
                            var phi, dot_phi: types.ANGLE_DATA);
// Заполнение массивов компоненты num резонанса типа TYPE_
var angle_idx: integer;
begin
    if TYPE_ then
    begin
        angle_idx := trunc(angles[num] * constants.toDeg / config.ROW_STEP) + 1;

        inc(net[num, angle_idx, time_idx]); // Заполнение сетки
        inc(flag[num, trunc(angles[num] * constants.toDeg / config.LIBRATION_STEP) + 1]); // Заполнение полос

        phi[num, idx] := angles[num] * constants.toDeg;
        dot_phi[num, idx] := freq[num];
    end;
end; {FillNetsAndArrays}



function _isDecrease(current, next: extended): boolean;
begin
    _isDecrease := (current > next) or _isDecreaseBranch(current, next);
end;



function _isIncrease(current, next: extended): boolean;
begin
    _isIncrease := (current < next) or _isIncreaseBranch(current, next);
end;



function _isDecreaseBranch(current, next: extended): boolean;
begin
    _isDecreaseBranch := (current < next/2) and
                         (current < config.BRANCH_LIMIT);
end;



function _isIncreaseBranch(current, next: extended): boolean;
begin
    _isIncreaseBranch := (current/2 > next) and
                         (current > 360 - config.BRANCH_LIMIT);
end;



begin
end.