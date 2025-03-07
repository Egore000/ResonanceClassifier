﻿unit constants;

interface
const 
    a_e = 149597870.691; //[km]
    pi = 3.1415926535897932;
    mu = 3.986004418e+5; // Гравитационная постоянная для спутника
    Gmu = 1.32712442099e+11; // Гравитационная постоянная для Солнца
    toRad = pi/180; // Перевод в радианы
    toDeg = 180/pi; // Перевод в градусы

    coef = 0.05; // Коэффициент переходов частоты через 0

    eps = 1e-12; // Точность вычисления аномалии в задаче двух тел
    t0 = 0; // Начальная эпоха

    ecc = 1e-3; // Эксцентриситет орбиты

    SecondInYear = 86400 * 365; // Количество секунд в году
implementation
begin
end.