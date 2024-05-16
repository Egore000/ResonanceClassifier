// Основной файл проекта, в котором осуществляется работа с файлами, чтение и обработка
// данных, классификация резонансов, а также запись в файлы
program ResonanceClassifier;

{$APPTYPE CONSOLE}

{$R *.res}

uses SysUtils,
    Classifier in 'MODULES\Classifier\Classifier.pas',
    utils in 'MODULES\Classifier\Utils\utils.pas',

    ResonanceUnit in 'MODULES\Resonance\ResonanceUnit.pas',
    readfond in 'MODULES\Tools\ReadFond\readfond.pas',
    TwoBody in 'MODULES\TwoBody\TwoBody.pas',

    types in 'MODULES\Tools\System\Types\types.pas',
    variables in 'MODULES\Tools\System\Variables\variables.pas',
    constants in 'MODULES\Tools\System\Constants\constants.pas',
    service in 'MODULES\Tools\Service\service.pas',
    math in 'MODULES\Tools\Math\math.pas',
    filetools in 'MODULES\Tools\Filetools\filetools.pas',
    logging in 'MODULES\Tools\Logging\logging.pas',

    config in 'Config\config.pas';

var folder, num, number: integer;

begin {Main}
//    {$WARNINGS-}
    {Проверка существования файла и предупреждение о перезаписи}
    service.Warning(config.PATH_CLASSIFICATION);

    assign(outdata, config.PATH_CLASSIFICATION);
    rewrite(outdata);

    assign(trans, config.PATH_TRANS);
    rewrite(trans);

    {Заполнение заголовка в файле классификации}
    filetools.WriteHeader(outdata);

    write(trans, 'folder', config.DELIMITER,
                   'file', config.DELIMITER,
                   'a', config.DELIMITER,
                   'i', config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(trans, 'dF' + inttostr(num), config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(trans, 'dF' + inttostr(num) + '_max', config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(trans, 'dF' + inttostr(num) + '_min', config.DELIMITER);
    for num := config.RES_START to config.RES_FINISH do
        write(trans, 'dF' + inttostr(num) + '_max_abs', config.DELIMITER);
    writeln(trans);

    {Цикл по папкам}
    for folder := config.START_FOLDER to config.FINISH_FOLDER do
        { Цикл по файлам в папке folder }
        for number := config.START_FILE to config.FINISH_FILE do
        begin
            file_name := filetools.FileNumberToFileName(number);

            if FileExists(config.PATH_DATA + inttostr(folder) + '\EPH_' + file_name + '.DAT') then
            begin
                assign(data, config.PATH_DATA + inttostr(folder) + '\EPH_' + file_name + '.DAT');
                reset(data);
                if (number mod 100 = 0) then
                    writeln('[FOLDER]', #9, folder, #9, '[FILE]', #9, number);
                logging.Log(logging.logger, folder, number);
            end
            else
                break;

            {Связь с файлами, в случае, если осуществляется запись}
            if (config.ORBITAL and config.WRITE_ORBIT) then
                filetools.Create_File(orbit_res, config.PATH_ORBITAL + inttostr(folder) + '\' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                filetools.Create_File(second_plus, config.PATH_SECOND_PLUS + inttostr(folder) + '\' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                filetools.Create_File(second_minus, config.PATH_SECOND_MINUS + inttostr(folder) + '\' + file_name + '.dat');

            {Заполнение массивов нулями}
            service.FillZero(
                    net, net2, net3,
                    flag, flag2, flag3,
                    t,
                    phi, phi2, phi3,
                    dot_phi, dot_phi2, dot_phi3);

            idx := 1;
            mean := 0;
            while not eof(data) do
            begin
                {Считывание данных из файла}
                readln(data, tm, time, ss, year, month, day);
                readln(data, x, coords[1], coords[2], coords[3], megno);
                readln(data, velocities[1], velocities[2], velocities[3], mean_megno);

                mean := mean + mean_megno;

                {Расчёт элментов орбиты}
                TwoBody.CoordsToElements(coords, velocities, mu, a, e, i, Omega, w, M);

                {Сохранение начальных данных}
                if (time = 0) then
                begin
                    a0 := round(a * 10) / 10;
                    i0 := round(i * toDeg);
                    logging.LogElements(logging.logger, a0, i0);
                end;

                {Вычисление аргументов орбитального резонанса}
                if config.ORBITAL then
                    ResonanceUnit.Resonance(1, 0, year, month, day, M, Omega, w, ecc, i, a, angles, freq);

                {Вычисление аргументов вторичного резонанса}
                if config.SECONDARY then
                begin
                    ResonanceUnit.Resonance(2, -1, year, month, day, M, Omega, w, ecc, i, a, angles2, freq2);
                    ResonanceUnit.Resonance(2, 1, year, month, day, M, Omega, w, ecc, i, a, angles3, freq3);
                end; {if SECONDARY}

                t[idx] := time / (86400 * 365); {Перевод секунд в года}
                time_idx := trunc(t[idx] / config.COL_STEP) + 1;
                for num := config.RES_START to config.RES_FINISH do
                begin
                    {Заполнение массивов для орбитального резонанса}
                    service.FillNetsAndArrays(config.ORBITAL, num, idx, time_idx,
                                    angles, freq, net, flag, phi, dot_phi);

                    {Заполнение массивов для вторичных резонансов (знак -)}
                    service.FillNetsAndArrays(config.SECONDARY, num, idx, time_idx,
                                    angles2, freq2, net2, flag2, phi2, dot_phi2);

                    {Заполнение массивов для вторичных резонансов (знак +)}
                    service.FillNetsAndArrays(config.SECONDARY, num, idx, time_idx,
                                    angles3, freq3, net3, flag3, phi3, dot_phi3);
                end; {for num}

                {Запись в файлы}
                if (config.ORBITAL and config.WRITE_ORBIT) then
                    filetools.WriteToFile(orbit_res, time, angles, freq);

                if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                    filetools.WriteToFile(second_minus, time, angles2, freq2);

                if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                    filetools.WriteToFile(second_plus, time, angles3, freq3);

                inc(idx);
            end; {while not eof(data)}

            mean := mean / idx; // Среднее значение MEGNO за всё время исследования динаимки объекта

            {Классификация орбитальных резонансов}
            if config.ORBITAL then
                Classifier.Classification(net, flag, t, phi, dot_phi, classes);

            {Классификация вторичных резонансов}
            if config.SECONDARY then
            begin
                Classifier.Classification(net2, flag2, t, phi2, dot_phi2, classes2);
                Classifier.Classification(net3, flag3, t, phi3, dot_phi3, classes3);
            end;

            for num := config.RES_START to config.RES_FINISH do
            begin
                transitions[num] := service.CountTransitions(dot_phi, num);
                transitions2[num] := service.CountTransitions(dot_phi2, num);
                transitions3[num] := service.CountTransitions(dot_phi3, num);

                max_dphi[num] := service.GetMaximumDotPhi(dot_phi, num);
                min_dphi[num] := service.GetMinimumDotPhi(dot_phi, num);
                max_abs_dphi[num] := service.GetMaximumABSDotPhi(dot_phi, num);
            end;

            {Вывод разбиения для либрации при отладке}
            if config.DEBUG then
                service.OutFlag(flag);

            logging.LogFlags(logging.logger, flag);

            {Запись классификации в файл}
            filetools.WriteClassification(outdata, folder, number, a0, i0, mean, classes, classes2, classes3);

            write(trans, folder, config.DELIMITER,
                        number, config.DELIMITER,
                        a0, config.DELIMITER,
                        i0, config.DELIMITER);
            for num := config.RES_START to config.RES_FINISH do
                write(trans, transitions[num], config.DELIMITER);
            for num := config.RES_START to config.RES_FINISH do
                write(trans, max_dphi[num], config.DELIMITER);
            for num := config.RES_START to config.RES_FINISH do
                write(trans, min_dphi[num], config.DELIMITER);
            for num := config.RES_START to config.RES_FINISH do
                write(trans, max_abs_dphi[num], config.DELIMITER);
            writeln(trans);

            {Закрытие файлов, если они были открыты на запись}
            if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                close(second_plus);

            if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                close(second_minus);

            if (config.ORBITAL and config.WRITE_ORBIT) then
                close(orbit_res);

            logging.Space(logging.logger);

            close(data);
        end; {for number}
    close(outdata);
    close(trans);

    if config.LOGS then close(logger);
    writeln('Finished!');
    readln;
end.
