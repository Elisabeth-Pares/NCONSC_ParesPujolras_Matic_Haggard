function [] = E3_preprocessing(exp,sub)
% INPUT: exp
% OUTPUT: preprocessed file labelled "ICA_bodfrE3_PX.set & .fdt file",
% where X is the participant number.

% Load file
EEG = pop_fileio(['E:/PhD - London/E3 - Gradual Awareness/converted data/E3_P' num2str(sub) '.set']);
EEG.setname=['E3_P' num2str(sub)];
EEG = eeg_checkset( EEG );
% Re-reference to average of mastoids
EEG = pop_reref( EEG, [27 28] );    % re-reference to average of mastoids
EEG = eeg_checkset( EEG );
filename = ['rE3_P' num2str(sub)];
% Filter
EEG  = pop_basicfilter( EEG,  1:30 , 'Boundary', 'boundary', 'Cutoff', [exp.filter.lowerbound  exp.filter.upperbound], 'Design', 'butter', 'Filter', 'bandpass', 'order',8);
EEG = eeg_checkset( EEG );
filename = ['frE3_P' num2str(sub)];
% Downsample
EEG = pop_resample( EEG, exp.downsampling_rate);
EEG = eeg_checkset( EEG );
filename = ['dfrE3_P' num2str(sub)];
% Change EOG channel labels
EEG = pop_chanedit(EEG, 'lookup','C:/Program Files/MATLAB/R2021a/plugins/eeglab/eeglab2021.0/functions/supportfiles/Standard-10-5-Cap385_witheog.elp','changefield',{30 'labels' 'HEOG'},'changefield',{29 'labels' 'HEOG'},'changefield',{28 'labels' 'VEOG'},'changefield',{27 'labels' 'VEOG'});
EEG = eeg_checkset( EEG ); % set right channel names before ICA
EEG = pop_saveset(EEG, ['dfrE3_P' num2str(sub)], exp.filepath);

for e = 1:length(exp.epochs)
    if e == 2, EEG = pop_loadset(['dfrE3_P' num2str(sub) '.set'], exp.filepath); end;
    % Epoch 
    EEG = pop_epoch( EEG, {exp.epochTriggers{e}}, [exp.epochBounds{e}], 'epochinfo', 'yes'); %-1.5 to 1 s around orange letter. For self-paced actions, epoch around 'Trigger 3' and from -2.5 to 1.
    EEG = eeg_checkset( EEG );
    % Baseline
    EEG = pop_rmbase( EEG, [exp.epochBaselines{e}]); %For self-paced actions, baseline at -2500 to -2000.
    EEG = eeg_checkset( EEG );
    % Run ICA
    EEG = eeg_checkset( EEG ); % set right channel names before ICA
    EEG = pop_runica(EEG, 'extended',0,'interupt','on', 'chanind', exp.icachanind);
    EEG = eeg_checkset( EEG ); % set right channel names before ICA
    EEG = pop_saveset(EEG, ['ICA_b' exp.epochLabel{e} 'dfrE3_P' num2str(sub)], exp.filepath);
end
clear EEG;
end
