﻿// Файл с конфигурационными настройками проекта

// Здесь собраны основные параметры для проводимого исследования,
// такие, как порядок резонанса, папки и файлы для проверки,
// резонансные аргументы и прочее (см. комментарии к константам ниже).


unit config;

interface
const
    ORBITAL = true; // Исследование орбитального резонанса
    SECONDARY = false; // Исследование вторичных резонансов
    FREQUENCY = true; // Исследование частот
//    PERICENTER = true; // Исследование долготы перицентра

    // Порядок резонанса (U:V)
    U = 1;
    V = 2;

    DEBUG = false; // Отладка
    LOGS = true; // Запись в логфайл

    START_FOLDER = 2; // Начальная папка
    FINISH_FOLDER = 3; // Конечная папка

    START_FILE = 1; // Начальный файл
    FINISH_FILE = 9000; // Конечный файл

    RES_START = 1; // Начальная компонента резонанса
    RES_FINISH = 5; // Конечная компонента резонанса

    ROWS = 12; // Количество строк в сетке
    COLS = 20; // Количество столбцов в сетке
    ROW_STEP = 360 / rows; // Шаг по строкам
    COL_STEP = 100 / cols; // Шаг по столбцам

    LIBRATION_ROWS = 24; // Количество строк в разбиении для определения либрации
    LIBRATION_STEP = 360 / LIBRATION_ROWS; // Шаг по строкам при определении либрации

    DELIMITER = #9; // Разделитель в выходных файлах

    LIMIT = 20; // Максимально допустимое количество скачков для циркуляции

    INITIAL_ELEMENTS = true; // Записывать ли начальные параметры в файл с классификацией

    EMPTY_CELLS = 20; // Допустимое количество пустых клеток при выявлении циркуляции

    BRANCH_LIMIT = 100; // Ширина полосы, попадение в которую считать началом новой ветви

    EXTREMUM_LIMIT = 10; // Допустимое отклонение между разницами экстремумов в градусах

    LIBRATION_PERCENT_LIMIT = 80; // Процент одинаковых разностей между экстремумами

    // Запись в файлы
    WRITE_ORBIT = false;
    WRITE_SECOND_PLUS = false;
    WRITE_SECOND_MINUS = false;

    BASE_DIR = 'C:\Users\egorp\Desktop\диплом\файлы\'; // Директория проекта

    // Пути к файлам и директориям
    TARGET_FOLDER = 'Без светового давления';
    // TARGET_FOLDER = 'Со световым давлением';

    OMEGA_VALUE = 'Omega_240';
//     OMEGA_VALUE = 'Omega_120';
//     OMEGA_VALUE = 'Omega_0';

    PATH_DATA = BASE_DIR + 'Исходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\'; // Путь к папке с исходными данными

    PATH_CLASSIFICATION = BASE_DIR + 'Выходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\Классификация.DAT'; // Путь к файлу с классификацией
    PATH_TRANS = BASE_DIR + 'Выходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\Переходы.DAT'; // Путь к файлу с переходами частоты через 0

    PATH_ORBITAL = BASE_DIR + 'Выходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\Орбитальные\'; // Путь к папке с данными об орбитальных резонансах
    PATH_SECOND_PLUS = BASE_DIR + 'Выходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\Вторичные\плюс\'; // Путь к папке с данными о вторичных резонансах (+)
    PATH_SECOND_MINUS = BASE_DIR + 'Выходные данные\' + TARGET_FOLDER + '\' + OMEGA_VALUE + '\Вторичные\минус\'; // Путь к папке с данными о вторичных резонансах (-)

    LIBRATION_WITH_SHIFTING_CENTER = true; // Классификация либрации со смещающимся центром (вкл/выкл)
implementation
begin
end.