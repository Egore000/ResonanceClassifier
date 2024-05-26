// Логгер для вывода сообщений в лог файлы

unit logging;

interface
uses SysUtils,
    config,
    logging_config,
    classifier_config,
    types;

var
    logger: text;
    libration_logger: text;
    nets_logger: text;


procedure LogFlags(var logfile: text;
                flag: types.FLAGS);

procedure LogNet(var logfile: text;
                net: types.NETWORK);

procedure Log(var logfile: text;
            folder, filenum: integer);

procedure LogStats(var logfile: text;
                class_: types.CLS;
                zeros, transitions: types.COUNTER);

procedure LogClasses(var logfile: text;
                    class_: types.CLS);

procedure LogCounter(var logfile: text;
                    const msg: string;
                    counter_: types.COUNTER);

procedure LogIncDec(var logfile: text;
                    increase, decrease: types.COUNTER);

procedure LogElements(var logfile: text;
                    a0, i0: extended);

procedure LogDiffs(var logfile: text;
                    diffs, time_diffs: types.EXTREMUM_DIFFS;
                    len: integer;
                    const msg: string);

procedure LogShiftingLibrationInfo(var logfile: text;
                                mean, time_mean: extended;
                                len, libration: integer;
                                libration_percent: extended);

procedure Space(var logfile: text);


implementation


procedure LogFlags( var logfile: text;
                    flag: types.FLAGS);
// Логирование массива флагов для либрации
var i, j: integer;
begin
    if config.LOGS then
    begin
        writeln(logfile, '[FLAGS]');
        for i := config.RES_START to config.RES_FINISH do
        begin
            for j := 1 to classifier_config.LIBRATION_ROWS do
                write(logfile, flag[i, j], config.DELIMITER);
            writeln(logfile);
        end;
    end;
end; {FlagLogs}



procedure LogNet( var logfile: text;
                    net: types.NETWORK);
// Логирование сетки
var
    num, row, col: integer;
begin
    if config.LOGS then
    begin
        writeln(logfile, '[NET]');
        for num := config.RES_START to config.RES_FINISH do
        begin
            writeln(logfile, 'NUM = ', num);

            for row := 1 to classifier_config.ROWS do
            begin
                for col := 1 to classifier_config.COLS do
                    write(logfile, net[num, row, col], config.DELIMITER);
                writeln(logfile);
            end;
            writeln(logfile);
        end;
    end;
end; {NetLogs}



procedure LogIncDec(var logfile: text;
                increase, decrease: types.COUNTER);
// Логирование счётчиков возрастания и убывания
begin
    if config.LOGS then
    begin
        LogCounter(logfile, '[INC]', increase);
        LogCounter(logfile, '[DEC]', decrease);
    end;
end;



procedure LogStats(var logfile: text;
                class_: types.CLS;
                zeros, transitions: types.COUNTER);
// Логирование статистики о резонансе
begin
    if config.LOGS then
    begin
        LogClasses(logfile, class_);
        LogCounter(logfile, '[ZEROS]', zeros);
        LogCounter(logfile, '[ZERO FREQUENCE TRANSITION]', transitions);
    end;
end;



procedure LogClasses(var logfile: text;
                    class_: types.CLS);
var res: integer;
begin
    write(logfile, '[CLASSES]', DELIMITER);
    for res := config.RES_START to config.RES_FINISH do
        write(logfile, class_[res], DELIMITER);
    writeln(logfile);
end;



procedure LogCounter(var logfile: text;
                    const msg: string;
                    counter_: types.COUNTER);
var res: integer;
begin
    write(logfile, msg, config.DELIMITER);
    for res := config.RES_START to config.RES_FINISH do
        write(logfile, counter_[res], config.DELIMITER);
    writeln(logfile);
end;



procedure Log(var logfile: text;
            folder, filenum: integer);
// Запись в лог файл данных о папке и файле
begin
    if config.LOGS then
        writeln(logfile, '[FOLDER]    ', folder,
                config.DELIMITER, '[FILE]    ', filenum);
end;



procedure LogElements(var logfile: text;
                a0, i0: extended);
begin
    if config.LOGS then
        writeln(logfile,
                '[a]    ', a0:0:1, ' km', config.DELIMITER,
                '[i]    ', i0:0:0, ' deg');
end;


procedure LogDiffs(var logfile: text;
                    diffs, time_diffs: types.EXTREMUM_DIFFS;
                    len: integer;
                    const msg: string);
var i: integer;
begin
    if config.LOGS then
    begin
        writeln(logfile, msg);
        for i := 1 to len do
            writeln(logfile, diffs[i], config.DELIMITER, time_diffs[i]);
        writeln(logfile);
    end;
end;



procedure LogShiftingLibrationInfo(var logfile: text;
                                mean, time_mean: extended;
                                len, libration: integer;
                                libration_percent: extended);
begin
    if config.LOGS then
    begin
        writeln(logfile, '[MEAN]    ', mean);
        writeln(logfile, '[TIME_MEAN]    ', time_mean);
        writeln(logfile, '[LEN]     ', len);
        writeln(logfile, '[LIBRATONS]    ', libration);
        writeln(logfile, '[%]   ', round(libration_percent));
        writeln(logfile);
    end;
end;

procedure Space(var logfile: text);
// Отступ в лог файле
begin
    if config.LOGS then
    begin
        writeln(logfile);
        writeln(logfile, '==============================================================================================================');
        writeln(logfile);
    end;
end;



begin
    if config.LOGS then
    begin
        assign(logger, config.BASE_DIR + BASE_LOGGER_PATH);
        rewrite(logger);

        assign(libration_logger, config.BASE_DIR + LIBRATION_LOGGER_PATH);
        rewrite(libration_logger);

        assign(nets_logger, config.BASE_DIR + NETS_LOGGER_PATH);
        rewrite(nets_logger);
    end;
end.