%RUN_ALL  Digital Communications Lab - Experiment 1: digital modulations.
%   Runs every part and writes the figures to ./results.
%   Requires the Communications Toolbox.

clear; close all; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), 'src'));
rng(1405);

q1_1_orthogonal_ber;   clearvars
q1_2_noise_effect;     clearvars
q1_3_raised_cosine;    clearvars
q1_4_phase_noise;      clearvars
q1_5_ber_comparison;   clearvars
close all;
disp('All figures written to ./results');
