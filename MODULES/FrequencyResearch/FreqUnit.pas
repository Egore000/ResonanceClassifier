unit FreqUnit;

interface
uses
    SysUtils,
    types,
    config,
    service,
    filetools;

procedure FrequencyResearch(var f: text;
                            df1, df2, df3: types.ANGLE_DATA);

function CountTransitions(dphi: types.ANGLE_DATA; res: integer): integer;

function GetMaximumDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;

function GetMinimumDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;

function GetMaximumABSDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;


implementation

procedure FrequencyResearch(var f: text;
                            df1, df2, df3: types.ANGLE_DATA);
var
    num: integer;
    max_dphi, max_dphi2, max_dphi3: ARR; // Максимальные значения частот
    min_dphi, min_dphi2, min_dphi3: ARR; // Минимальные значения частот
    max_abs_dphi, max_abs_dphi2, max_abs_dphi3: ARR; // Максимальные значения модулей частот
    transitions, transitions2, transitions3: COUNTER; // Счётчики переходов частоты через 0

begin
    for num := config.RES_START to config.RES_FINISH do
    begin
        if config.ORBITAL then
        begin
            transitions[num] := CountTransitions(df1, num);
            max_dphi[num] := GetMaximumDotPhi(df1, num);
            min_dphi[num] := GetMinimumDotPhi(df1, num);
            max_abs_dphi[num] := GetMaximumABSDotPhi(df1, num);
        end;

        if config.SECONDARY then
        begin
            transitions2[num] := CountTransitions(df2, num);
            max_dphi2[num] := GetMaximumDotPhi(df2, num);
            min_dphi2[num] := GetMinimumDotPhi(df2, num);
            max_abs_dphi2[num] := GetMaximumABSDotPhi(df2, num);

            transitions3[num] := CountTransitions(df3, num);
            max_dphi3[num] := GetMaximumDotPhi(df3, num);
            min_dphi3[num] := GetMinimumDotPhi(df3, num);
            max_abs_dphi3[num] := GetMaximumABSDotPhi(df3, num);
        end;
    end;

    if config.ORBITAL then
        filetools.WriteTransitions(f, transitions, max_dphi, min_dphi, max_abs_dphi);

    if config.SECONDARY then
    begin
        filetools.WriteTransitions(f, transitions2, max_dphi2, min_dphi2, max_abs_dphi2);
        filetools.WriteTransitions(f, transitions3, max_dphi3, min_dphi3, max_abs_dphi3);
    end;

    writeln(f);
end; {FrequencyResearch}


function CountTransitions(dphi: types.ANGLE_DATA; res: integer): integer;
var i, len: integer;
begin
    Result := 0;
    len := service._Length(dphi, res);
    for i := 1 to len-1 do
        if (dphi[res, i] * dphi[res, i+1] < 0) then
            inc(Result);
end; {CountTransitions}


function GetMaximumDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;
var i, len: integer;
begin
    Result := dphi[res, 1];
    len := service._Length(dphi, res);
    for i := 1 to len do
        if (dphi[res, i] < Result) then
            Result := dphi[res, i];
end; {GetMaximumDotPhi}


function GetMinimumDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;
var i, len: integer;
begin
    Result := dphi[res, 1];
    len := service._Length(dphi, res);
    for i := 1 to len do
        if (dphi[res, i] > Result) then
            Result := dphi[res, i];
end; {GetMinimumDotPhi}


function GetMaximumABSDotPhi(dphi: types.ANGLE_DATA; res: integer): extended;
var i, len: integer;
begin
    Result := abs(dphi[res, 1]);
    len := service._Length(dphi, res);
    for i := 1 to len do
        if (abs(dphi[res, i]) < Result) then
            Result := abs(dphi[res, i]);
end; {GetMaximumABSDotPhi}

begin
end.
