// �������� ���� �������, � ������� �������������� ������ � �������, ������ � ���������
// ������, ������������� ����������, � ����� ������ � �����
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
    assign(outdata, config.PATH_CLASSIFICATION);

    rewrite(outdata);

    {���������� ��������� � ����� �������������}
    filetools.WriteHeader(variables.outdata);

    {���� �� ������}
    for folder := config.START_FOLDER to config.FINISH_FOLDER do
    { ���� �� ������ � ����� folder }
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


            {����� � �������, � ������, ���� �������������� ������}
            if (config.ORBITAL and config.WRITE_ORBIT) then
                filetools.Create_File(orbit_res, config.PATH_ORBITAL + inttostr(folder) + '\' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                filetools.Create_File(second_plus, config.PATH_SECOND_PLUS + inttostr(folder) + '\' + file_name + '.dat');

            if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                filetools.Create_File(second_minus, config.PATH_SECOND_MINUS + inttostr(folder) + '\' + file_name + '.dat');

            {���������� �������� ������}
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
                {���������� ������ �� �����}
                readln(data, tm, time, ss, year, month, day);
                readln(data, x, coords[1], coords[2], coords[3], megno);
                readln(data, velocities[1], velocities[2], velocities[3], mean_megno);

                mean := mean + mean_megno;

                {������ �������� ������}
                TwoBody.CoordsToElements(coords, velocities, mu, a, e, i, Omega, w, M);

                {���������� ��������� ������}
                if (time = 0) then
                begin
                    a0 := round(a * 10) / 10;
                    i0 := round(i * toDeg);
                    logging.LogElements(logging.logger, a0, i0);
                end;


                {���������� ���������� ������������ ���������}
                if config.ORBITAL then
                    ResonanceUnit.Resonance(1, 0, year, month, day, M, Omega, w, ecc, i, a, angles, freq);

                {���������� ���������� ���������� ���������}
                if config.SECONDARY then
                begin
                    ResonanceUnit.Resonance(2, -1, year, month, day, M, Omega, w, ecc, i, a, angles2, freq2);
                    ResonanceUnit.Resonance(2, 1, year, month, day, M, Omega, w, ecc, i, a, angles3, freq3);
                end; {if SECONDARY}

                t[idx] := time / (86400 * 365); {������� ������ � ����}
                time_idx := trunc(t[idx] / config.COL_STEP) + 1;
                for num := config.RES_START to config.RES_FINISH do
                begin
                    {���������� �������� ��� ������������ ���������}
                    service.FillNetsAndArrays(config.ORBITAL, num, idx, time_idx,
                                    angles, freq, net, flag, phi, dot_phi);

                    {���������� �������� ��� ��������� ���������� (���� -)}
                    service.FillNetsAndArrays(config.SECONDARY, num, idx, time_idx,
                                    angles2, freq2, net2, flag2, phi2, dot_phi2);

                    {���������� �������� ��� ��������� ���������� (���� +)}
                    service.FillNetsAndArrays(config.SECONDARY, num, idx, time_idx,
                                    angles3, freq3, net3, flag3, phi3, dot_phi3);
                end; {for num}

                {������ � �����}
                if (config.ORBITAL and config.WRITE_ORBIT) then
                    filetools.WriteToFile(orbit_res, time, angles, freq);

                if (config.SECONDARY and config.WRITE_SECOND_MINUS) then
                    filetools.WriteToFile(second_minus, time, angles2, freq2);

                if (config.SECONDARY and config.WRITE_SECOND_PLUS) then
                    filetools.WriteToFile(second_plus, time, angles3, freq3);

                inc(idx);
            end; {while not eof(data)}

            mean := mean / idx; // ������� �������� MEGNO �� �� ����� ������������ �������� �������

            {������������� ����������� ����������}
            if config.ORBITAL then
                Classifier.Classification(net, flag, t, phi, dot_phi, classes);

            {������������� ��������� ����������}
            if config.SECONDARY then
            begin
                Classifier.Classification(net2, flag2, t, phi2, dot_phi2, classes2);
                Classifier.Classification(net3, flag3, t, phi3, dot_phi3, classes3);
            end;

            {����� ��������� ��� �������� ��� �������}
            if config.DEBUG then
                service.OutFlag(flag);

            logging.LogFlags(logging.logger, flag);

            {������ ������������� � ����}
            filetools.WriteClassification(outdata, folder, number, a0, i0, mean, classes, classes2, classes3);

            {�������� ������, ���� ��� ���� ������� �� ������}
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

    if config.LOGS then close(logger);
    writeln('Finished!');
end.
