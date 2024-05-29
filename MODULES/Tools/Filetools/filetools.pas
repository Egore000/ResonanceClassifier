// Модуль с процедурами для работы с файлами

unit filetools;

interface
uses SysUtils,
    types,
    constants,
    config;

procedure CreateFile(var f: text;
                    path: string);

procedure WriteToFile(var f: text;
                    time: extended;
                    angles, freq: types.ARR);

procedure WriteClassification(var f: text;
                            folder, number: integer;
                            a0, i0, megno, ecc: extended;
                            classes, classes2, classes3: types.CLS);

procedure WriteClassificationHeader(var f: text);

procedure WriteTransitions(var f: text;
                            transitions: types.COUNTER;
                            max_dphi, min_dphi, max_abs_dphi: types.ARR);

procedure WriteTransitionHeader(var f: text);

procedure WriteLidovKozai(var f: text;
                            folder, number: integer;
                            a0, i0: extended;
                            classes_w: types.CLS);

procedure WriteLidovKozaiHeader(var f: text);

function FileNumberToFileName(file_number: integer): string;

implementation

procedure CreateFile(var f: text;
                    path: string);
// Создание файла с данными об эволюции резонансных аргументов
// и запись в него заголовка
var i: integer;
begin
    assign(f, path);
    rewrite(f);
    write(f, 't', config.DELIMITER);

    for i := config.RES_START to config.RES_FINISH do
        write(f, 'F', i, config.DELIMITER);
    for i := config.RES_START to config.RES_FINISH do
        write(f, 'dF', i, config.DELIMITER);

    writeln(f);
end; {Create_File}


procedure WriteToFile(var f: text;
                      time: extended;
                      angles, freq: types.ARR);
// Запись данных о резонансах в файл f
var i: integer;
begin
    write(f, time/(86400 * 365), config.DELIMITER);
    for i := config.RES_START to config.RES_FINISH do
        write(f, angles[i] * toDeg, config.DELIMITER);

    for i := config.RES_START to config.RES_FINISH do
        write(f, freq[i], config.DELIMITER);
    writeln(f);
end; {WriteToFile}


procedure WriteClassification(var f: text;
                            folder, number: integer;
                            a0, i0, megno, ecc: extended;
                            classes, classes2, classes3: types.CLS);
// Запись в файл с классификацией
var i: integer;
begin
    if config.INITIAL_ELEMENTS then
        write(f, folder, config.DELIMITER,
                number,  config.DELIMITER,
                a0:0:3,  config.DELIMITER,
                i0:0:0,  config.DELIMITER,
                megno:0:6, config.DELIMITER,
                ecc, config.DELIMITER)
    else
        write(f, folder, config.DELIMITER, number, config.DELIMITER);


    if config.ORBITAL then
        for i := config.RES_START to config.RES_FINISH do
            write(f, classes[i], config.DELIMITER);

    if config.SECONDARY then
    begin
        for i := config.RES_START to config.RES_FINISH do
            write(f, classes2[i], config.DELIMITER);

        for i := config.RES_START to config.RES_FINISH do
            write(f, classes3[i], config.DELIMITER);
    end;
    writeln(f);
end; {WriteClassification}


procedure WriteClassificationHeader(var f: text);
// Заполнение заголовка файла классификации для Ф и Ф'

// Заголовок заполняется автоматически для тех резонансных аргументов,
// которые указаны в файле config [RES_START, RES_FINISH].
var i: integer;
begin
    if config.INITIAL_ELEMENTS then
        write(f, 'folder', config.DELIMITER,
                'file',    config.DELIMITER,
                'a, km',   config.DELIMITER,
                'i, grad', config.DELIMITER,
                'MEGNO',   config.DELIMITER,
                'e', config.DELIMITER)
    else
        write(f, 'folder', config.DELIMITER,
                'file',    config.DELIMITER);

    if config.ORBITAL then
        for i := config.RES_START to config.RES_FINISH do
            write(f, 'F', i, config.DELIMITER);

    if config.SECONDARY then
    begin
        for i := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(i) + '(+)', config.DELIMITER);

        for i := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(i) + '(-)', config.DELIMITER);
    end;
    writeln(f);
end; {WriteHeader}


procedure WriteTransitions(var f: text;
                            transitions: types.COUNTER;
                            max_dphi, min_dphi, max_abs_dphi: types.ARR);
var
    num: integer;
begin
    for num := config.RES_START to config.RES_FINISH do
        write(f, transitions[num], config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(f, max_dphi[num], config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(f, min_dphi[num], config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(f, max_abs_dphi[num], config.DELIMITER);
end;


procedure WriteTransitionHeader(var f: text);
// Запись заголовка в файл для данных о переходах частоты через 0
// и её максимальных значениях.
var num: integer;
begin
    write(f, 'folder', config.DELIMITER,
                   'file', config.DELIMITER,
                   'a', config.DELIMITER,
                   'i', config.DELIMITER);
    if config.ORBITAL then
    begin
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(num), config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(num) + '_max', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(num) + '_min', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'dF' + inttostr(num) + '_max_abs', config.DELIMITER);
    end;

    if config.SECONDARY then
    begin
        // Вторичные резонансы с плюсом
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '+', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '+_max', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '+_min', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '+_max_abs', config.DELIMITER);

        // Вторичные резонансы с минусом
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '-', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '-_max', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '-_min', config.DELIMITER);
        for num := config.RES_START to config.RES_FINISH do
            write(f, 'sec_dF' + inttostr(num) + '-_max_abs', config.DELIMITER);
    end;

    writeln(f);
end; {WriteTransitionHeader}



procedure WriteLidovKozai(var f: text;
                            folder, number: integer;
                            a0, i0: extended;
                            classes_w: types.CLS);
begin
    writeln(f, folder, config.DELIMITER,
               number, config.DELIMITER,
               a0,     config.DELIMITER,
               i0,     config.DELIMITER,
               classes_w[1]);
end; {WriteLidovKozai}



procedure WriteLidovKozaiHeader(var f: text);
var num: integer;
begin
    writeln(f, 'folder', config.DELIMITER,
               'file', config.DELIMITER,
               'a, km', config.DELIMITER,
               'i, grad', config.DELIMITER,
               'w res');
end; {WriteLidovKozaiHeader}



function FileNumberToFileName(file_number: integer): string;
// Преобразование номера файла к названию в формате "0104"
var file_name: string;
begin
    case file_number of
        0..9:       file_name := '000' + inttostr(file_number);
        10..99:     file_name := '00' + inttostr(file_number);
        100..999:   file_name := '0' + inttostr(file_number);
        1000..9999: file_name := inttostr(file_number)
    end;

    FileNumberToFileName := file_name;
end;


begin
end.