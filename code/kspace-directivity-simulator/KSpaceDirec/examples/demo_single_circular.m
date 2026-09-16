%% demo_single_circular.m
clear; clc; close all;

addpath(fileparts(fileparts(mfilename('fullpath'))));

Const = kspaceDirec.defaultConst();
Wave = kspaceDirec.makeWave(40e3, 41e3, Const);
Array = kspaceDirec.makeCircularArray(0.005, Const.v0);
Grid = kspaceDirec.defaultGrid('Lx', 0.32, 'Ly', 0.32, 'Lz', 24, 'dz', 0.005);
theta = (-80:1:80).';

result = kspaceDirec.runXoz(Const, Wave, Array, Array, Grid, theta, ...
    'zChunk', 64, 'keepQxz', false);

figure('Color', 'w');
plot(result.theta_deg, result.dir_db, 'k-', 'LineWidth', 1.4);
box on;
set(gca, 'TickDir', 'in');
xlabel('\theta (deg)');
ylabel('Level (dB)');
ylim([-40 0]);
fprintf('Runtime: %.2f s\n', result.runtime_total_s);
