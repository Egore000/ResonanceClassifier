// Модуль с классификатором резонансных аргументов

unit Classifier;

interface
uses SysUtils,
    utils,
    types,
    constants,
    service,
    math,
    filetools,
    logging,
    config;


procedure Classification(net: types.NETWORK;
                        flag: types.FLAGS;
                        t: types.TIME_DATA;
                        phi, dot_phi: types.ANGLE_DATA;
                        var classes: types.CLS);

procedure _Libration(flag: types.FLAGS;
                     increase, decrease, zeros: types.COUNTER;
                     var classes: types.CLS);

procedure _LibrationWithShiftingCenter(phi: types.ANGLE_DATA;
                                       var classes: types.CLS);

implementation


procedure Classification(net: types.NETWORK;
                        flag: types.FLAGS;
                        t: types.TIME_DATA;
                        phi, dot_phi: types.ANGLE_DATA;
                        var classes: types.CLS);
// Классификация резонанса
// Параметры:
// net - сетка графика
// flag - сетка полос для выявления либрации
// t - массив времени
// phi, dot_phi - массивы углов и частот
// classes - выходной массив классов резонанса

// 0 - циркуляция
// 1 - смешанный тип
// 2 - либрация
var
    res, i: integer;
    length: integer;
    transitions, zero_counter, increase, decrease: types.COUNTER;

begin
    increase := utils._FillCounterByZeros();
    decrease := utils._FillCounterByZeros();
    transitions := utils._FillCounterByZeros();

    // Цикл по компонентам резонанса
    for res := config.RES_START to config.RES_FINISH do
    begin
        zero_counter[res] := utils._CountZerosInNet(net, res);

        length := service._Length(phi, res);
        for i := 1 to length-1 do
        begin
            // Подсчёт убывющих точек
            if service._isDecrease(phi[res, i], phi[res, i+1]) then
                inc(decrease[res]);

            // Подсчёт возрастающих точек
            if service._isIncrease(phi[res, i], phi[res, i+1]) then
                inc(increase[res]);

            // Подсчёт переходов частоты через 0
            if (dot_phi[res, i] * dot_phi[res, i+1]) < 0 then inc(transitions[res]);
        end; {for i}
    end; {for res}

    _Libration(flag, increase, decrease, zero_counter, classes);

    if config.LIBRATION_WITH_SHIFTING_CENTER then
        _LibrationWithShiftingCenter(phi, classes);

    utils._DebugResonanceInfo(classes, length, zero_counter, transitions);
    utils._DebugArraysInfo(increase, decrease, net);

    logging.LogStats(logging.logger, classes, zero_counter, transitions);
    logging.LogIncDec(logging.logger, increase, decrease);
    logging.LogNet(logging.logger, net);
end; {Classification}



procedure _Libration(flag: types.FLAGS;
                     increase, decrease, zeros: types.COUNTER;
                     var classes: types.CLS);
var res, libration, i: integer;
begin
    for res := config.RES_START to config.RES_FINISH do
    begin
        libration := 0;

        for i := 1 to config.LIBRATION_ROWS do
            if (flag[res, i] = 0) then inc(libration);

        if (libration > 0) and (increase[res] <> 0) and (decrease[res] <> 0) then
            classes[res] := 2
        else
            if  (increase[res] <= config.LIMIT) or
                (decrease[res] <= config.LIMIT) or
                (zeros[res] <= config.EMPTY_CELLS) then

                classes[res] := 0
            else
                classes[res] := 1;
    end;
end; {_Libration}



procedure _LibrationWithShiftingCenter(phi: types.ANGLE_DATA;
                                       var classes: types.CLS);
var res: integer;
    diffs: types.EXTREMUM_DIFFS;
begin
    for res := config.RES_START to config.RES_FINISH do
    begin
        diffs := utils._GetDiffsArray(phi, res);

        if utils._isLibration(diffs) then
            classes[res] := 2;
    end;
end;



begin {Main}
end.
