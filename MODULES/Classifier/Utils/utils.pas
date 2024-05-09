// Процедуры для классификатора

unit utils;

interface
uses SysUtils,
    types,
    constants,
    service,
    math,
    filetools,
    logging,
    config;

function _CountZerosInNet(net: types.NETWORK; res: integer): integer;

function _FillCounterByZeros(): types.COUNTER;

procedure _DebugResonanceInfo(class_: types.CLS;
                            length: integer;
                            zeros, transitions: types.COUNTER);

procedure _DebugArraysInfo(increase, decrease: types.COUNTER;
                            net: types.NETWORK);

function _GetDiffsArray(phi: types.ANGLE_DATA;
                        res: integer): types.EXTREMUM_DIFFS;

function _isLibration(diffs: types.EXTREMUM_DIFFS): boolean;

function _isInAcceptebleInterval(diff, mean: extended): boolean;

function _isMinimum(phi: types.ANGLE_DATA;
                    res, idx: integer): boolean;

function _isMaximum(phi: types.ANGLE_DATA;
                    res, idx: integer): boolean;

function _Len(diffs: types.EXTREMUM_DIFFS): integer;

function _Mean(diffs: types.EXTREMUM_DIFFS): extended;

implementation



function _CountZerosInNet(net: types.NETWORK; res: integer): integer;
// Подсчёт общего количества точек и нулевых ячеек в сетке
var row, col, zeros: integer;
begin
    zeros := 0;
    // Цикл по строчкам сетки
    for row := 1 to config.ROWS do
        // Цикл по столбцам
        for col := 1 to config.COLS do
            if (net[res, row, col] = 0) then inc(zeros);

    Result := zeros;
end; {_CountZerosInNet}



function _FillCounterByZeros(): types.COUNTER;
var res: integer;
begin
    for res := config.RES_START to config.RES_FINISH do
        _FillCounterByZeros[res] := 0;
end;



procedure _DebugResonanceInfo(class_: types.CLS;
                            length: integer;
                            zeros, transitions: types.COUNTER);
// Отладочная информация о резонансной компоненте res
var res: integer;
begin
    if config.DEBUG then
    begin
        for res := config.RES_START to config.RES_FINISH do
        begin
            writeln('[CLASSES]', config.DELIMITER, class_[res]);
            writeln('[ZEROS]',   config.DELIMITER, zeros[res]);
            writeln('[ZERO FREQUENCE TRANSITION]', config.DELIMITER, transitions[res]);
            writeln;
        end;
        writeln('[LENGTH]  ', length);
    end;
end; {_DebugResonanceInfo}



procedure _DebugArraysInfo(increase, decrease: types.COUNTER;
                            net: types.NETWORK);
// Отладочная информация о счётчиках возрастания и убывания, а также вывод
// в консоль сетки разбиения net
var res: integer;
begin
    if config.DEBUG then
    begin
        writeln('[INC]', #9, '[DEC]');
        for res := config.RES_START to config.RES_FINISH do
            writeln(increase[res], #9, #9, decrease[res]);

        service.OutNET(net);
    end;
end; {_DebugArraysInfo}



function _isLibration(diffs: types.EXTREMUM_DIFFS): boolean;
var idx, len: integer;
    mean: extended;
    libration_percent: extended;
    libration: integer;
begin
    len := _Len(diffs);

    mean := _Mean(diffs);
    libration := 0;
    for idx := 1 to len-1 do
        if _isInAcceptebleInterval(diffs[idx], mean) then
            inc(libration);

    if len <> 0 then
        libration_percent := libration / len * 100
    else
        libration_percent := 0;

    if libration_percent >= config.LIBRATION_PERCENT_LIMIT then
        _isLibration := True
    else
        _isLibration := False;

    // LogShiftingLibrationInfo(logger, mean, len, libration, libration_percent);
end;



function _isInAcceptebleInterval(diff, mean: extended): boolean;
begin
    _isInAcceptebleInterval := (diff >= mean - config.EXTREMUM_LIMIT) and
                               (diff <= mean + config.EXTREMUM_LIMIT);
end;



function _GetDiffsArray(phi: types.ANGLE_DATA;
                        res: integer): types.EXTREMUM_DIFFS;
var
    idx, diffNumber, len: integer;
    localMin, localMax, MinMaxDiff: extended;
    diffs: types.EXTREMUM_DIFFS;
    phi_: types.ANGLE_DATA;
begin
    len := service._Length(phi, res);
    phi_ := service._InsertGaps(phi, res, len);

    localMin := 1e10;
    localMax := 1e10;
    MinMaxDiff := 0;
    diffNumber := 0;

    for idx := 1 to 1000 do
        diffs[idx] := 0;

    for idx := 2 to len-1 do
    begin
        if phi_[res, idx] > 1e5 then
            continue;

        if _isMaximum(phi_, res, idx) then
        begin
            localMax := phi_[res, idx];

            if (localMin = 1e10) then
                continue;

            if localMax < localMin then
                localMax := localMax + 360;

            MinMaxDiff := abs(localMax - localMin);

            inc(diffNumber);
            diffs[diffNumber] := MinMaxDiff;
        end;

        if _isMinimum(phi_, res, idx) then
            localMin := phi_[res, idx];
    end;

    _GetDiffsArray := diffs;
end;



function _Len(diffs: types.EXTREMUM_DIFFS): integer;
var len: integer;
begin
    len := 1;
    while diffs[len+1] <> 0 do
        inc(len);

    _Len := len;
end;



function _Mean(diffs: types.EXTREMUM_DIFFS): extended;
var sum: extended;
    idx, len: integer;
begin
    sum := 0;
    len := _Len(diffs);
    for idx := 1 to len do
        sum := sum + diffs[idx];

    if len <> 0 then
        _Mean := sum / len
    else
        _Mean := 0;
end;



function _isMinimum(phi: types.ANGLE_DATA;
                    res, idx: integer): boolean;
begin
    _isMinimum := (phi[res, idx] <= phi[res, idx-1]) and
                  (phi[res, idx] <= phi[res, idx+1]) and
                  (phi[res, idx-1] <> 1e6) and
                  (phi[res, idx+1] <> 1e6);
end;



function _isMaximum(phi: types.ANGLE_DATA;
                    res, idx: integer): boolean;
begin
    _isMaximum := (phi[res, idx] >= phi[res, idx-1]) and
                  (phi[res, idx] >= phi[res, idx+1]) and
                  (phi[res, idx-1] <> 1e6) and
                  (phi[res, idx+1] <> 1e6);
end;



begin
end.