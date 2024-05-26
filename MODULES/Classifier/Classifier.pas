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
    config,
    classifier_config;


procedure Classification(net: types.NETWORK;
                        flag: types.FLAGS;
                        t: types.TIME_DATA;
                        phi, dot_phi: types.ANGLE_DATA;
                        var classes: types.CLS);

procedure _Libration(flag: types.FLAGS;
                     increase, decrease, zeros: types.COUNTER;
                     var classes: types.CLS);

procedure _LibrationWithShiftingCenter(phi: types.ANGLE_DATA;
                                       time: types.TIME_DATA;
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
            else inc(decrease[res]);

            // Подсчёт возрастающих точек
            if service._isIncrease(phi[res, i], phi[res, i+1]) then
            else inc(increase[res]);

            // Подсчёт переходов частоты через 0
            if (dot_phi[res, i] * dot_phi[res, i+1]) < 0 then inc(transitions[res]);
        end; {for i}
    end; {for res}

    _Libration(flag, increase, decrease, zero_counter, classes);

    if classifier_config.LIBRATION_WITH_SHIFTING_CENTER then
        _LibrationWithShiftingCenter(phi, t, classes);

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

        for i := 1 to classifier_config.LIBRATION_ROWS do
            if (flag[res, i] = 0) then inc(libration);

        if (libration > 0) and (increase[res] <> 0) and (decrease[res] <> 0) then
            classes[res] := classifier_config.LIBRATION_MARKER
        else
            if  (increase[res] <= classifier_config.LIMIT) or
                (decrease[res] <= classifier_config.LIMIT) or
                (zeros[res] <= classifier_config.EMPTY_CELLS) then

                classes[res] := classifier_config.CIRCULATION_MARKER
            else
                classes[res] := classifier_config.MIXED_MARKER;
    end;
end; {_Libration}



procedure _LibrationWithShiftingCenter(phi: types.ANGLE_DATA;
                                       time: types.TIME_DATA;
                                       var classes: types.CLS);
var res: integer;
    diffs, time_diffs: types.EXTREMUM_DIFFS;
begin
    for res := config.RES_START to config.RES_FINISH do
    begin
        utils._GetDiffsArray(phi, time, res, diffs, time_diffs);

        if utils._isLibration(diffs, time_diffs) then
            classes[res] := classifier_config.LIBRATION_WITH_SHIFTING_CENTER_MARKER;
    end;
end;



begin {Main}
end.
