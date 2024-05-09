// Модуль с процедурами для работы с файлами

unit filetools;

interface
uses SysUtils,
    types,
    constants,
    config;

procedure Create_File(var f: text;
                    path: string);

procedure WriteToFile(var f: text;
                    time: extended;
                    angles, freq: types.ARR);

procedure WriteClassification(var f: text;
                            folder, number: integer;
                            a0, i0, megno: extended;
                            classes, classes2, classes3: types.CLS);

procedure WriteHeader(var f: text);

function FileNumberToFileName(file_number: integer): string;

implementation

procedure Create_File(var f: text;
                    path: string);
// Создание файла с данными об эволюции резонансных аргументов
// и запись в него заголовка
var i: integer;
begin
    assign(f, path);
    rewrite(f);
    write(f, 't', config.DELIMITER);
    if ORBITAL then
        for i := config.RES_START to config.RES_FINISH do
            write(f, 'F', i, config.DELIMITER);

    if SECONDARY then
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
                            a0, i0, megno: extended;
                            classes, classes2, classes3: types.CLS);
// Запись в файл с классификацией
var i: integer;
begin
    if config.INITIAL_ELEMENTS then
        write(f, folder, config.DELIMITER,
                number,  config.DELIMITER,
                a0:0:3,  config.DELIMITER,
                i0:0:0,  config.DELIMITER,
                megno:0:6, config.DELIMITER)
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



procedure WriteHeader(var f: text);
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
                'MEGNO',   config.DELIMITER)
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