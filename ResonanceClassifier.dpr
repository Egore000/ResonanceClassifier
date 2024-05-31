// Основной файл проекта, в котором осуществляется работа с файлами, чтение и обработка
// данных, классификация резонансов, а также запись в файлы
program ResonanceClassifier;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Classifier in 'MODULES\Classifier\Classifier.pas',
  utils in 'MODULES\Classifier\Utils\utils.pas',

  ResonanceUnit in 'MODULES\Resonance\ResonanceUnit.pas',

  readfond in 'MODULES\Tools\ReadFond\readfond.pas',
  TwoBody in 'MODULES\TwoBody\TwoBody.pas',
  FreqUnit in 'MODULES\FrequencyResearch\FreqUnit.pas',

  types in 'MODULES\Tools\System\Types\types.pas',
  variables in 'MODULES\Tools\System\Variables\variables.pas',
  constants in 'MODULES\Tools\System\Constants\constants.pas',

  service in 'MODULES\Tools\Service\service.pas',
  math in 'MODULES\Tools\Math\math.pas',
  filetools in 'MODULES\Tools\Filetools\filetools.pas',
  logging in 'MODULES\Tools\Logging\logging.pas',

  config in 'Config\config.pas',
  classifier_config in 'Config\classifier_config.pas',
  logging_config in 'Config\logging_config.pas';

var folder, num, number: integer;

begin {Main}
//    {$WARNINGS-}
    mode := service.WriteMode(config.PATH_CLASSIFICATION);

    assign(outdata, config.PATH_CLASSIFICATION);
    if mode = 'rewrite' then
    begin
        rewrite(outdata);

        {Заполнение заголовка в файле классификации}
        filetools.WriteClassificationHeader(outdata);
    end;
    if mode = 'append' then
        append(outdata);



    if config.FREQUENCY then
    begin
        mode := service.WriteMode(config.PATH_TRANS);

        assign(trans, config.PATH_TRANS);
        if mode = 'rewrite' then
        begin
            rewrite(trans);

            {Заполнение заголовка в файле с данными о частотах}
            filetools.WriteTransitionHeader(trans);
        end;
        if mode = 'append' then
            append(trans);
    end;



    if config.LIDOV_KOZAI then
    begin
        mode := service.WriteMode(config.PATH_LK_RESONANCE);

        assign(LK_data, config.PATH_LK_RESONANCE);
        if mode = 'rewrite' then
        begin
            rewrite(LK_data);

            {Заполнение заголовка в файле с данными о резонансе ЛК}
            filetools.WriteLidovKozaiHeader(LK_data);
        end;
        if mode = 'append' then
            append(LK_data);
    end;

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
                logging.Log(logging.libration_logger, folder, number);
                logging.Log(logging.nets_logger, folder, number);
            end
            else
                break;


            {Связь с файлами, в случае, если осуществляется запись}
            if (config.ORBITAL and config.WRITE_ORBIT) then
                filetools.CreateFile(orbit_res, config.PATH_ORBITAL + inttostr(folder) + '\EPH_' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                filetools.CreateFile(second_plus, config.PATH_SECOND_PLUS + inttostr(folder) + '\EPH_' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                filetools.CreateFile(second_minus, config.PATH_SECOND_MINUS + inttostr(folder) + '\EPH_' + file_name + '.dat');

            {Заполнение массивов нулями}
            service.FillZero(
                    net, net2, net3, net_w,
                    flag, flag2, flag3, flag_w,
                    t,
                    phi, phi2, phi3, w_array,
                    dot_phi, dot_phi2, dot_phi3, dw_array);

            idx := 1;
            mean := 0;
            max_ecc := 0;
            while not eof(data) do
            begin
                {Считывание данных из файла}
                readln(data, tm, time, ss, year, month, day);
                readln(data, x, coords[1], coords[2], coords[3], megno);
                readln(data, velocities[1], velocities[2], velocities[3], mean_megno);

                mean := mean + mean_megno;

                {Расчёт элментов орбиты}
                TwoBody.CoordsToElements(coords, velocities, mu, a, e, i, Omega, w, M);
                if (e > max_ecc) then max_ecc := e;

                {Сохранение начальных данных}
                if (time = 0) then
                begin
                    a0 := round(a * 10) / 10;
                    i0 := round(i * toDeg);
                    logging.LogElements(logging.logger, a0, i0);
                    logging.LogElements(logging.libration_logger, a0, i0);
                    logging.LogElements(logging.nets_logger, a0, i0);
                end;

                {Вычисление аргументов орбитального резонанса}
                if config.ORBITAL then
                    ResonanceUnit.Resonance(1, 0, year, month, day, M, Omega, w, ecc, i, a, angles, freq);

                {Вычисление аргументов вторичного резонанса}
                if config.SECONDARY then
                begin
                    ResonanceUnit.Resonance(2, -1, year, month, day, M, Omega, w, ecc, i, a, angles2, freq2);
                    ResonanceUnit.Resonance(2,  1, year, month, day, M, Omega, w, ecc, i, a, angles3, freq3);
                end; {if SECONDARY}

                {Заполнение массивов аргументов перицентра}
                if config.LIDOV_KOZAI then
                    for num := config.RES_START to config.RES_FINISH do
                    begin
                        w_angles[num] := w + PI;
                        w_freq[num] := 0;
                    end;

                t[idx] := time / constants.SecondInYear; {Перевод секунд в года}
                time_idx := trunc(t[idx] / classifier_config.COL_STEP) + 1;
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

                    {Заполнение массивов для аргумента перицентра w}
                    service.FillNetsAndArrays(config.LIDOV_KOZAI, num, idx, time_idx,
                                    w_angles, w_freq, net_w, flag_w, w_array, dw_array);
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

            {Классификация аргумента перицентра для резонанса Лидова-Козаи}
            if config.LIDOV_KOZAI then
                Classifier.Classification(net_w, flag_w, t, w_array, dw_array, classes_w);

            {Изучение частот}
            if config.FREQUENCY then
            begin
                write(trans, folder, config.DELIMITER,
                             number, config.DELIMITER,
                             a0, config.DELIMITER,
                             i0, config.DELIMITER);
                FreqUnit.FrequencyResearch(trans, dot_phi, dot_phi2, dot_phi3);
            end;

            {Вывод разбиения для либрации при отладке}
            if config.DEBUG then
                service.OutFlag(flag);

            logging.LogFlags(logging.nets_logger, flag);

            {Запись классификации в файл}
            filetools.WriteClassification(outdata, folder, number, a0, i0, mean, max_ecc, classes, classes2, classes3);

            {Запись резонансов Лидова-Козаи в файл}
            if config.LIDOV_KOZAI then
                filetools.WriteLidovKozai(LK_data, folder, number, a0, i0, classes_w);

            {Закрытие файлов, если они были открыты на запись}
            if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                close(second_plus);

            if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                close(second_minus);

            if (config.ORBITAL and config.WRITE_ORBIT) then
                close(orbit_res);

            logging.Space(logging.logger);
            logging.Space(logging.libration_logger);
            logging.Space(logging.nets_logger);

            close(data);
        end; {for number}
    close(outdata);

    if config.FREQUENCY then
        close(trans);

    if config.LIDOV_KOZAI then
        close(LK_data);

    if config.LOGS then
    begin
        close(logger);
        close(libration_logger);
        close(nets_logger);
    end;

    writeln('Finished!');
    readln;
end.
