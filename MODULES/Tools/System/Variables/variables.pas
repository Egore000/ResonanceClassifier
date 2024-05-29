// Модуль с объявлением переменных для main-файла  

unit variables;

interface
uses
    types;

var coords, velocities: MAS; // Массивы координат и скоростей
    angles, angles2, angles3, w_angles: ARR; // Массивы резонансных углов Ф
    freq, freq2, freq3, w_freq: ARR; // Массивы резонансных частот Ф'

    net, net2, net3, net_w: NETWORK; // Сетки для разных наборов данных
    flag, flag2, flag3, flag_w: FLAGS; // Полосы либрации
    classes, classes2, classes3, classes_w: CLS; // Массивы с классификацией резонансов

    a, e, max_ecc, i, Omega, w, M, megno, mean_megno, mean: extended;
    a0, i0: extended; // Начальные параметры орбиты
    tm, time, day: extended;
    year, month, x: integer;
    idx, time_idx: integer; // Индексы

    data, outdata, orbit_res, second_plus,
    second_minus, trans, LK_data: text; // Файлы
                                                // data - файл с исходными данными
                                                // outdata - файл для записи элементов
                                                // orbit_res - выходной файл с орбитальными резонансами
                                                // second_plus - выходной файл с вторичными резонансами (+)
                                                // second_minus - выходной файл с вторичными резонансами (-)
                                                // trans - файл с количеством переходов частоты через 0
                                                // LK_data - файл с данными о резонансе Лидова-Козаи
    ss: string[7]; // Служебная строка

    phi, phi2, phi3: ANGLE_DATA; // Массивы с резонансными углами
    dot_phi, dot_phi2, dot_phi3: ANGLE_DATA; // Массивы с резонансными частотами
    w_array, dw_array: ANGLE_DATA; // Массив аргумента перицентра
    t: TIME_DATA; // Массив с моментами времени

    file_name: string; // Название файла
    mode: string; // Режим записи в файл

implementation
begin
end.