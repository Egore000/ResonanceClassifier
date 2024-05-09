﻿// Модуль для вычисления резонансных аргументов

unit ResonanceUnit;

interface
uses SysUtils,
    types,
    constants,
    service,
    math,
    config,
    TwoBody;

procedure Resonance(res, znak, year, month: integer;
                    day: extended;
                    M, Omega, w, ecc, i, a: extended;
                    var angles, freq: types.ARR);

implementation

procedure Resonance(res, znak, year, month: integer;
                    day: extended;
                    M, Omega, w, ecc, i, a: extended; // Элементы орбиты
                    var angles, freq: types.ARR);
// Процедура для вычисления орбитальных резонансов
// res - порядок резонанса (1 - без учёта вторичных возмущений)
//                         (2 - с учётом вторичных возмущений)
// znak - знак lambda_s в формулах для вторичных возмущений
// angles - массив значений критического аргумента
// freq - массив частот резонанса
const
      mL = 1/81.3005690699;
      mS = 332946.048166;
      J2 = 1.0826359e-3;
      r0 = 6363.6726;
      i_L = 23.45 * toRad;
      i_S = 23.45 * toRad;
      a_L = 384748;
      a_S = 149597868;
      n_L = 2 * pi/(27.32166 * 86400);
      n_S = 2 * pi/(365.25 * 86400);
      d_theta = 7.292115e-5;

var jd, theta, n, d_OmegaJ2, d_wJ2, d_Omega_L, d_Omega_S, d_w_L, d_w_S, d_Omega, d_w: extended;
    xm_, xs_, vm_, vs_: types.MAS;
    b, ec, i_b, OmegaS, ws, M_s, lmd_s: extended;

begin
    jd := date_jd(year, month, day);
    theta := sid2000(jd);

    // Учёт влияния Солнца (при res = 2)
    lmd_s := 0;
    if (res = 2) then
    begin
        service.fond405(jd, xm_, xs_, vm_, vs_);
        TwoBody.CoordsToElements(xs_, vs_, Gmu, b, ec, i_b, OmegaS, ws, M_s);
        lmd_s := OmegaS + ws + M_s;
    end;

    angles[1] := math.Reduce(config.U * (M + Omega + w) - config.V * theta + znak * lmd_s);
    angles[2] := math.Reduce(config.U * (M + w) + config.V * (Omega - theta) + znak * lmd_s);
    angles[3] := math.Reduce(config.U * M + config.V * (Omega + w - theta) + znak * lmd_s);
    angles[4] := math.Reduce(angles[1] - config.V * Omega + znak * lmd_s);
    angles[5] := math.Reduce(angles[3] + config.V * Omega - 2 * config.V * w + znak * lmd_s);

    n := sqrt(mu/(a*sqr(a)));
    d_OmegaJ2 := -1.5*J2 * n * sqr(r0/a) * cos(i) / sqr(1 - sqr(ecc));
    d_wJ2 := 0.75*J2 * n * sqr(r0/a) * (5*sqr(cos(i)) - 1)/sqr(1 - sqr(ecc));

    d_Omega_L := -3/16 * n_L * mL * (a/a_L)*sqr(a/a_L) * (2 + 3*sqr(ecc))/sqrt(1 - sqr(ecc)) * (2 - 3*sqr(sin(i_L))) * cos(i);
    d_Omega_S := -3/16 * n_S * mS * (a/a_S)*sqr(a/a_S) * (2 + 3*sqr(ecc))/sqrt(1 - sqr(ecc)) * (2 - 3*sqr(sin(i_S))) * cos(i);

    d_w_L := 3/16 * n_L * mL * (a/a_L)*sqr(a/a_L) * (4 - 5*sqr(sin(i)) + sqr(ecc))/sqrt(1 - sqr(ecc)) * (2 - 3*sqr(sin(i_L)));
    d_w_S := 3/16 * n_S * mS * (a/a_S)*sqr(a/a_S) * (4 - 5*sqr(sin(i)) + sqr(ecc))/sqrt(1 - sqr(ecc)) * (2 - 3*sqr(sin(i_S)));

    d_Omega := d_OmegaJ2 + d_Omega_L + d_Omega_S;
    d_w := d_wJ2 + d_w_L + d_w_S;

    freq[1] := U * (n + d_Omega + d_w) - V * d_theta;
    freq[2] := U * (n + d_w) + V * (d_Omega - d_theta);
    freq[3] := U * n + V * (d_Omega + d_w - d_theta);
    freq[4] := freq[1] - V * d_Omega;
    freq[5] := freq[3] + V * d_Omega - 2 * V * d_w;

    // Вычисление частот вторичного резонанса (при res = 2)
    if (res = 2) then
    begin
        freq[1] := freq[1] + znak * ( d_Omega_S + d_w_S + n_S );
        freq[2] := freq[2] + znak * ( d_Omega_S + d_w_S + n_S );
        freq[3] := freq[3] + znak * ( d_Omega_S + d_w_S + n_S );
        freq[4] := freq[4] + znak * ( d_Omega_S + d_w_S + n_S );
        freq[5] := freq[5] + znak * ( d_Omega_S + d_w_S + n_S );
    end;
end; {Resonance}


begin {Main}
end.