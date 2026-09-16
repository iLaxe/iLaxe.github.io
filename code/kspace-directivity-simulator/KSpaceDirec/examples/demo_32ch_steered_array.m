%% demo_32ch_steered_array.m
clear; clc; close all;

addpath(fileparts(fileparts(mfilename('fullpath'))));

Const = kspaceDirec.defaultConst();
f1 = 40e3;
f2 = 41e3;
theta0 = 30;
Wave = kspaceDirec.makeWave(f1, f2, Const);

Array = kspaceDirec.makeColumnArray32x6('radius', 0.005, 'velocity', Const.v0);
Array1 = kspaceDirec.applySteering(Array, Wave.ultra1.k, theta0);
Array2 = kspaceDirec.applySteering(Array, Wave.ultra2.k, theta0);

Grid = kspaceDirec.defaultGrid('Lx', 36, 'Ly', 0.96, 'Lz', 36, 'dz', 0.005);
theta = (-80:1:80).';

result = kspaceDirec.runXoz(Const, Wave, Array1, Array2, Grid, theta, ...
    'zChunk', 4, 'keepQxz', false);

figure('Color', 'w');
plot(result.theta_deg, result.dir_db, 'k-', 'LineWidth', 1.4);
box on;
set(gca, 'TickDir', 'in');
xlabel('\theta (deg)');
ylabel('Level (dB)');
ylim([-80 0]);
fprintf('Runtime: %.2f s\n', result.runtime_total_s);
