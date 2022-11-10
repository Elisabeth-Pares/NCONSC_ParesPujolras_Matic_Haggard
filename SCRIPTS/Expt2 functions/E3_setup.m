function [exp] = E3_setup()

%Experimental parameters 
exp.sub_id = [4 5 6 7 8 10 11 12 13 14 15 16 17 18 19 20 21];

exp.nblocks = 8;
exp.ntrials = 36; %36 trials per block

% Give paths to folders with your data
exp.mainpath = pwd;
parts = strsplit(exp.mainpath, '\');
exp.mainpath = [strjoin({parts{1:(end-1)}}, '/'),'/'];

exp.procPath          = [exp.mainpath, 'DATA/']; %Path to processed data 
exp.figPath           = [exp.mainpath, 'FIGURES/']; 
% Set experimental analysis parameters 
exp.nsub              = length(exp.sub_id);
exp.filepath          = ['E:/PhD - London/E3 - Gradual Awareness/april2019/']; %Set to local path to save  EEG processed data 
exp.behPath           = ['E:/PhD - London/E3 - Gradual Awareness/results/']; %Path to raw behavioural data folder


exp.chans             = [3]; 
exp.chansidx          = [3,15];
exp.chanlabels        = {'CZ', 'C3'}; %Main paper reports Cz results; Supplementary analysis reports C3 (contralateral to movement). 

exp.epochs            = {'orangeLetter', 'selfPaced'};
exp.epochLabel        = {'OL', 'SP'};
exp.epochTriggers      = {'Trigger 1', 'Trigger 3'}; 
exp.epochBounds       = {[-1.5,1], [-2.5,1]};
exp.epochBaselines    = {[-1500 -1000],[-2500,-2000]};

exp.filter.lowerbound = 0;   % high pass
exp.filter.upperbound = 30;     % low pass
exp.downsampling_rate = 200;    % downsampling rate 

exp.icachanind = [1 2 3 4 6 7 8 9 12 15 16 17 18 19 20 22 23 24 25 26 27 29]; % index of channels to run the ICA 

exp.kpe      = 2 %Time window (in sec) for trial exclusion based on preceding keypress. 

%Threshold for artefact rejection
exp.artefactmin = -120;
exp.artefactmax = 120;

%Beta band analysis 
exp.min_freq =  13; %Minimum frequency
exp.max_freq = 30; %Max frequency
exp.num_freq = 34; %Freq resolution
exp.frex = linspace(exp.min_freq,exp.max_freq,exp.num_freq); %Resolved frequencies

exp.morletCycles = 7; %Morlet wavelet cycles. 
