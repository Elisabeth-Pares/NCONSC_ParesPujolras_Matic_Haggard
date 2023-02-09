%% ======================================================================
%% Feeling ready: neural bases of prospective motor readiness judgements
% Authors: Parés-Pujolràs, Matic & Haggard
% Neuroscience of Consiousness, XXXX, 
% DOI: 

% This script contains the whole EEG processing pipeline used for
% Experiment 2 analysis reported in the paper. 
% Script author: Elisabeth Parés-Pujolràs
%% ======================================================================

%% Set up analysis parameters 
exp = E3_setup()

%% Preprocess behaviour & get recoding vectors to annotate EEG data 
E3_trialRecoding(exp)

% =======================================================================
%% EEG - PREPROCESSING 
% =======================================================================
% Pre-ICA pipeline - preprocessing 
% Re-reference to mastoid average, filter, downsample, epoch, baseline
%correct, run ICA.

for sub = exp.sub_id(1:end)
  E3_preprocessing(exp,sub)
end

% Manual eyeblink ICA correction - identify & emove vertical and horizontal eye movements

%% Post-ICA correction pipeline - TESTED, OK
for sub = exp.sub_id(1:end) 
   E3_postICA_processing(exp,sub)
end

% PREPROCESSED FILE = ['rec_kprej' num2str(exp.kpe) '_acICA' exp.epochLabel{e} 'odfrE3_P' num2str(sub).set]
% This will be loaded hereforth for postprocessing. 

% =======================================================================
%% EEG - BETA BAND ANALYSIS 
% ========================================================================
%% Morlet wavelet transform  

for e = 1:length(exp.epochs) % epoch (1 orange letter, 2 selfpaced action);

    for thisChan = exp.chanlabels(1:end) %Run for Ch CZ (main manuscript) and C3 (supplementary figure)
        exp.thisChan = thisChan{1};
        [dat] = E3_morletWavelet(exp,1,e); %Exp, plot (0 no, 1 yes), epoch (1 orange letter, 2 selfpaced action);
        save([exp.procPath,'E3_betaWavelets_morletCycles_' num2str(exp.morletCycles) '_' num2str(exp.thisChan) '_' exp.epochLabel{e} '.mat'], 'dat'); 
        %Quantify beta bursts 
        [dat] = E3_betaBursts(exp, e);%Exp, epoch (1-orange letter, 2-selfpaced action)
        if e == 2 & strcmp(thisChan, 'CZ') %Plot Figure S1b
            E3_burstDescription(exp, e)
        end
    end
end


%% EXPORT DATA for R analysis 
%=========================================================================
% Extract RP amplitude & produce file for R 
% Output: 'E3_R_allP_behData_ICA_betaBursts_morletCycles_7_CZ.csv']
E3_extractAmplitudes(exp)


%% PLOTTING 
%=========================================================================
%% Plot RP grand average by rating 
% Plot & save Figure 3a
thisChan = 'CZ';
colormap = 'hot';
E3_plot_GA_RP(exp, thisChan);

%% Plot single subject RPs 
% Set up to run from preprocessed files 
% Plot & save Figure S5 
colormap = 'jet'
E3_getGA_plotSP_RPs(exp)

%% Plot topography  - Figure S6 
% Plot & save Figure S6
EEG = E3_getAverages(exp)

%% Plot pre-orange power sorted by high/low readiness ratings
% the EEG for averaging & ERD obtention 
E3_plotPower(exp,newDat)

%% Additional analysis    
% ========================================================================
%% Demographics
i = 0
for sub = exp.sub_id(1:end)
    i = i +1;
    load([exp.behPath, 'E3_results_' num2str(sub) '.mat'])
    age(i)= results.age;
    sex(i) = results.sex;
end

mean_age = mean(age)
std_age = std(age)

%% Get experimental duration 
expDur = E3_expDuration(exp)

%% Count percentage of rejections due to post-probe press
id = 0;
for sub = exp.sub_id(1:end)
    id = id+1;
    load(['E:\PhD - London\E3 - Gradual Awareness\april2019\E3_P' num2str(sub) '_behavioural_results_kpe2rejected.mat']);
    postOrangePress(id,1) = sum(strcmp([all_recoding_all(:)], {'postProbePress'})); %Count
    postOrangePress(id,2) = sum(strcmp([all_recoding_all(:)], {'postProbePress'}))/288*100; %Percentage
end
mean(postOrangePress(:,2)) %mean % rejections
std(postOrangePress(:,1))
