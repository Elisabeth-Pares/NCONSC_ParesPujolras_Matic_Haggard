%% ======================================================================
%% Feeling ready: neural bases of prospective motor readiness judgements
% Authors: Parés-Pujolràs, Matic & Haggard
% Neuroscience of Consiousness 
% DOI: 

% This script contains the whole EEG processing pipeline used for
% Experiment 1 analysis reported in the paper. 
% Script authors: Karla Matic & Elisabeth Parés-Pujolràs

%% EEGLAB preprocessing pipeline
% Includes 5 steps: 
%   1) Simple preprocessing (rereferencing, filtering, downsampling); 
%   2) Preprocessing based on behavioural data (comparison of number of events, identification of doubled keypresses and triggers,
%       recoding of events in behavioural dataset and creating recoding vectors to later add to EEG dataset;
%   3) MANUAL - Deleting doubled triggers based on labels added in previous step, running ICA on epoched data (involves all epochs of interest), 
%       removing eye-blink component from the dataset;
%   4) EEG recoding (Re-epoching only stimulus/event-locked epochs separately, baselining, adding a column to EEG dataset with
%       stimulus/event-locked labels.
%   5) Artefact rejection (automatic)
%   6) Extract/restructure data for group analysis (put data of all participants in simple file, restructure for plotting, restructure for
%       FieldTrip input)
%% Initial setup
eeglab % Start up EEGLAB

sub_id  = [1 2 3 4 5 6 7 8 9 12 15 16 17 18 19 20 21 22 23]; % Excluding subjects [10, 11, 13 & 14] because they produced too few awareness responses (< 15)
exp = EEGAnalysisSetup(sub_id);
exp.sub_id = sub_id;

cfg = CFGfieldTripSetup();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART 1: ROUGH PREPROCESSING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 1: SIMPLE PREPROCESSING
for sub = sub_id
    exp.filepath = fullfile(exp.condata,[ 'P' num2str(sub) ]);
    K1_preprocessing(sub, exp)
end
            
% STEP 2: BEHAVIOURAL DATA RECODING
for sub = sub_id
    expData = K1_importBehavioural(exp,sub);
    %expData = compareOLrecoding(exp, expData, sub); 
        % Can be uncommented and the rest can be commented to run a comparison
        % of how many trials survive if the orange letter trials are rejected
        % when action precedes for different number of letters.Creates a
        % separate behavioural file with labels column for each rejection
        % range. Only use to decide the rejection range - unnecessary for the final pipeline.
    [events(sub), eventsEEG(sub)] = K1_compareEvents(expData, exp, sub);
    [expData, stuckIdxEEG, doubleStuckIdxEEG]  = K1_checkDoublePresses(exp,expData, sub, events, eventsEEG);
    expData = K1_Recoding(expData, exp, sub, 12); % Add an OL recoding column for orangeRejectRange = 12 letters
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 2: MANUAL PREPROCESSING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 3 (MANUAL): Triggers mismatch, ICA, eye blink component rejection
% First check which Triggers are labeled as doubled (based on stuck keys analysis), and delete them manually after checking they are correctly
% labelled. Save this file to cdfrK1_P.set.
% Then epoch around all SP and OL triggers, and run ICA.

% DELETING TRIGGERS
% Automatic deletion of stuck triggers. Uncomment and use only for subjects with many stuck keys. It will only delete the second of the two triggers if 
% a) they are of the same type, and b) they are less than 0.5 seconds apart. 
% It will report which triggers are left to be manually inspected - those will still be marked with a label in the EEG.event structure. 
% Only run EEG pop_saveset after manually confirming that all triggers are deleted.
% 
%  sub = #;
%  expData = K1_importBehavioural(exp,sub);
%  [expData, stuckIdxEEG, doubleStuckIdxEEG]  = K1_checkDoublePresses(exp,expData, sub, events, eventsEEG);
%  [EEG, deleted_triggers, skipped_triggers] = K1_cleanTriggers(sub, exp, stuckIdxEEG, doubleStuckIdxEEG);
%  EEG = pop_saveset(EEG, ['cdfrK1_P' num2str(sub)], [exp.preprdata '/P' num2str(sub)]);

% If there are only a couple of doubled triggers labeled, you can delete them manually.
% Don't forget to make sure that a 'cdfrK1_P.set' file exists for every participant, even if there were no triggers to correct!

% RUN ICA
% Check function and choose to either run ICA automatically (all channels)
% or have a pop-up window to define channel for each subject.
for sub = sub_id
    exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
    EEG = K1_runICA(sub,exp);
end

% EYE-BLINK COMPONENT REMOVAL
% Find eye blinks components in the ICA dataset and remove them manually.
% Save new file as eICA_cdrfk1_P.set.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART 3: RECODING & EPOCHING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 4: EPOCHING & BASELINING
% Take out only orange-letter epochs, baseline, produce epochs around
% orange letters and around self-paced movements.
% Compare the behavioural matrix with triggers, and add a new column in
% epoched EEG file with a label for trial type recoding.

% Epoching + baselining
missingEpochs = {'subject', 'doubledEpochs12', 'missingEpochs12'};

for sub =  sub_id % Epoching 
    exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
    missingEpochs(sub + 1, 1) = {sub};
    [~, missingEpochs(sub + 1, [3, 5])] = K1_Epoching(sub,exp, 1, 12); % sub, exp, trigger, rejectRange
    [~, ~] = K1_Epoching(sub, exp, 2, 8);% sub, exp, trigger, rejectRange
end

%% Manually inspect the datasets and delete problematic doubled epochs where needed

%%% Useful commands for manual inspection
% Saving the dataset
% sub = 1;
% rejectRange = 12;
% exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
% EEG = pop_saveset( EEG, ['K1_epochOL' num2str(rejectRange) '_P' num2str(sub)],  exp.filepath);    
%%% Comparing the number of triggers to original continuous dataset
% EEG2 = pop_loadset([exp.filepath '/dfrK1_P' num2str(sub) '.set']); 
% EEG2 = pop_epoch(EEG2, {'Trigger 1'}, [-2.0, 0.5] , 'newname', ['K1_P' num2str(sub) '_stimLockEpochs'], 'epochinfo', 'yes'); 
% sum(strcmp({EEG.event.type}, "Trigger 1"))
% sum(strcmp({EEG2.event.type}, "Trigger 1"))
%%% Comparing by UR numbers
% allURevents = [EEG.event.urevent];
% UR= allURevents(strcmp({EEG.event.type}, "Trigger 1"));
% length(UR)
% length(unique(UR))
% setdiff(unique(UR)', UR')

% STEP 5: RECODING
for sub = 1% sub_id(sub_id~= 6) % Do manually for sub 6
    exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
    EEG = K1_EEGRecoding(sub,exp, 12);
end

% STEP 6: ARTEFACT REJECTION

for sub = sub_id
    exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
    EEG = K1_rejectArtefacts(sub,exp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 5: RESTRUCTURING FOR STATISTICS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STEP 7: EXTRACT DATA
% Extract different trials into separate datasets: awareness response (AW),
% self-paced response (SP), no response (NoR), and self-paced action
% (SPaction). 

exp.nsub = length(sub_id);

for sub = sub_id
    % Extract stimulus-locked trials
    exp.filepath = fullfile(exp.preprdata, [ 'P' num2str(sub) '/']);
    filename = ['K1_aRepochOL12_P' num2str(sub) '.set'];
    EEG = K1_extractData(exp, filename, 'AW'); % exp, sub, filename, trialType
    EEG = K1_extractData(exp, filename, 'SP'); % exp, sub, filename, trialType
    EEG = K1_extractData(exp, filename, 'NoR'); % exp, sub, filename, trialType
    
    % Save action-locked trials in the same way
    EEG = K1_extractData(exp, ['K1_aepochSP_P' num2str(sub) '.set'], 'SPaction');
end

% This pipeline produces the epoched files provided at OSF. 
% Those can be loaded to run the steps below. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART 6: GROUP ANALYSIS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 6.1 STIMULUS-LOCKED DATA (ORANGE LETTER)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract data and put in one single file for all participants
% Requires manually loading all files to eeglab
% OUTPUT: K1_allP_averagedData.mat
K1_SaveDataSeparately 

%% ORANGE LETTER
% ===================================================================================
%% READINESS POTENTIAL ANALYSIS 
% ===================================================================================
%Participants with RPs (IDs from 1:19, excluding 6)
exp.sub_selection =  [1:5,7:19]; %Exclude ID 6 because no RP 

% Average data & plot RP with SEM 
% Output: K1_allP_averagedData_all.mat, Fig2c
K1_plotGA(exp) 

%Statistical cluster analysis of RP data
%Output: K1_FT_stats.mat
K1_RP_clusterAnalysis(exp) %Performs cluster analysis on individual averaged data. 

%% Extract single trial RP data for statistical analysis in R 
% Output: K1_RPamp_12_forR.mat
K1_extractRPAmp(exp,3)

%% BETA POWER ANALYSIS 
% ===================================================================================
exp.sub_selection = [1:19]; %Include all participants (IDs from 1 to 19) for beta band analysis

exp.wd = 'E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/orange_letter_longer/' %Set path to preprocessed data 

% Morlet wavelet transform 
% Output: 
    %K1_betaWavelets_OSF_morletCycles_7_orangeLetter_CZ.mat --> input for
    %K1_betabursts function
dat = K1_morletWavelet(exp,1, 'orangeLetter')

% Quantify beta bursts and generate output for analysis in R
% Outputs: 
    %Exp1_R_burstData_orangeLetter_Cz.csv --> for R analysis 
    %Exp1_R_burstData_fullDetails_orangeLetter.mat' --> for S1 plotting 
[dat] = K1_betaBursts(exp, 'orangeLetter');

% Plot grand-averaged beta power for NR, SP and AW - Figure 2g 
K1_plotGA_power(exp)

%% ACTION-LOCKED DATA (SELF-PACED ACTION, W/O ORANGE LETTER)
% ===================================================================================
%% READINESS POTENTIAL ANALYSIS 
% ===================================================================================
%% Plot all single-participant self-paced action averaged RP 
% Reproduces Figure S4 
K1_getGA_selfpacedActions(exp) 

%% Plot RP topography 
% Reproduces Figure S6a
EEG = K1_getAverages(exp)

%% BETA POWER ANALYSIS 
% ===================================================================================
%% Extract beta amplitude & bursts to plot 
dat = K1_morletWavelet(exp,1, 'selfPaced') % run for several channels 

% Quantify beta bursts  
% Quantify beta bursts and generate output for analysis in R
% Outputs: 
    %Exp1_R_burstData_selfPaced_Cz.csv --> for R analysis 
    %Exp1_R_burstData_fullDetails_selfPaced.mat' --> for S1 plotting 
    [dat] = K1_betaBursts(exp, 'selfPaced');

%% Plot P(burst) over mean beta amplitude 
% Reproduces & saves Fig S1a
K1_burstDescription(exp, 'selfPaced');


%% ADDITIONAL ANALYSIS 
% ===================================================================================
% Experimental duration
expDuration = K1_expDuration(exp);