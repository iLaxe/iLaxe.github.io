function Wave = makeWave(f1, f2, Const)
%MAKEWAVE Build the carrier, sideband, and audio wave parameters.

Wave.ultra.f = f1 + f2 / 2;
Wave.audio.f = f2 - f1;
Wave.ultra1.f = f1;
Wave.ultra2.f = f2;

names = {'ultra1', 'ultra2', 'audio'};
for idx = 1:numel(names)
    name = names{idx};
    Wave.(name).omega = 2 * pi * Wave.(name).f;
    Wave.(name).k = Wave.(name).omega / Const.c0;
    Wave.(name).alpha = kspaceDirec.absorptionCoefficient( ...
        Wave.(name).f, 'temperature', Const.temp, 'humidity', Const.humi);
    Wave.(name).k_alpha = Wave.(name).k + 1i * Wave.(name).alpha;
end
end
