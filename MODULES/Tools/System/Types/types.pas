// Файл с описанием типов, используемых модулями
// 
// Здесь описаны массивы для хранения данных, их обработки и классификации

unit types;

interface
uses SysUtils,
    config;

type 
    MATRIX = array[1..3,1..3] of extended; // Матрицы поворота в задаче двух тел (модуль TwoBody.pas)
    MAS = array[1..3] of extended; // Массив скоростей или координат
    CLS = array[1..5] of integer; // Массив для классификации компонент резонансного аргумента
    ARR = array[1..5] of extended; // Массив резонансных аргументов или частот
    ANGLE_DATA = array[RES_START..RES_FINISH, 1..2000] of extended; // Матрица с полным набором резонансных углов 
    TIME_DATA = array[1..2000] of extended; // Вектор с моментами времени
    NETWORK = array[RES_START..RES_FINISH, 1..ROWS + 1, 1..COLS + 1] of integer; // Сетка разбиения данных для классификации
    FLAGS = array[RES_START..RES_FINISH, 1..LIBRATION_ROWS] of integer; // Разбиение по полосам для выявления либрации
    COUNTER = array[RES_START..RES_FINISH] of integer; // Счётчики
    EXTREMUM_DIFFS = array[1..1000] of extended; // Разности между локальными минимумами и максимумами


implementation

begin
end.