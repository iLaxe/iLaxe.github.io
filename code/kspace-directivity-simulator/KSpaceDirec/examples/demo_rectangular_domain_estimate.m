%% demo_rectangular_domain_estimate.m
clear; clc;

addpath(fileparts(fileparts(mfilename('fullpath'))));

dom = kspaceDirec.estimateDomain('rect', ...
    'W', 0.165, 'H', 0.109, 'f1', 40e3, 'fa', 1e3, 'steerDeg', 0);
disp(dom);

dom30 = kspaceDirec.estimateDomain('rect', ...
    'W', 0.165, 'H', 0.109, 'f1', 40e3, 'fa', 1e3, 'steerDeg', 30);
disp(dom30);
