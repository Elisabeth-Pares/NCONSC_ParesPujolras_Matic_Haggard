function [exp] = EEGAnalysisSetup(sub_id)
%UNTITLED Summary of this function goes here

% FILE PATHS
exp.sub_id = sub_id;
% Give paths to folders with your data
exp.mainpath = pwd;
parts = strsplit(exp.mainpath, '\');
exp.mainpath = [strjoin({parts{1:(end-1)}}, '/'),'/'];

addpath(genpath(exp.mainpath)); %Add all folders to path 

%For EEG preprocessing
exp.condata = fullfile(exp.mainpath, 'data/converted data'); % Path to data in .set format
exp.preprdata = fullfile(exp.mainpath, 'data/preprocessing'); % Path to which to save preprocessing steps data
exp.analysesdata = fullfile(exp.mainpath, 'data/analyses'); % Path to which to save preprocessing steps data

%For postprocessing 
exp.processedData = fullfile(exp.mainpath, 'DATA/')
exp.statsPath = fullfile(exp.mainpath, 'STATS/')
exp.figPath = fullfile(exp.mainpath, 'FIGURES/');

% EXPERIMENTAL PARAMETERS
exp.nsub = length(sub_id);
exp.chansidx = [1];
exp.actionChans = [3];
exp.actionChanLabels  = {'Cz'};

% FILTERING PARAMETERS
exp.filter.lowerbound = 0.01;   % high pass
exp.filter.upperbound = 30;     % low pass
exp.downsampling_rate = 200;    % downsampling rate

% EPOCHING
exp.stimulusEpoch = [-2500 500]; % Epoching around orange letter
exp.actionEpoch     = [-2500, 500]; % Epoching around SP action
exp.actionBaseline  = [-2500, -2000]; % Baseline epoch

% ARTEFACT REJECTION
exp.artefactmin     = -120;
exp.artefactmax     = 120;

% RECODING
exp.orangeLetterResponse = 8; % How many letters after orange letter to count as response (2s = 8 letters)
exp.orangeRejectRange = 12; %How many letters before orange letter to check for selfpaced actions and use to reject (3s = 12 letters)

% TFA
exp.morletCycles = 7;

end

