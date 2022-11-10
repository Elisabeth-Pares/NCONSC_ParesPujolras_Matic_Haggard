function [] = K1_preprocessing(sub, exp)  
% Load, re-reference to mastoid average, filter, downsample
% INPUT: K1_PX.set, raw converted files 
% OUTPUT: saves downsampled, filtered file claled ´dfrK1_PX.set'

% Load file
    EEG = pop_loadset([exp.filepath '/K1_P' num2str(sub) '.set']); 
    EEG.setname=['K1_P' num2str(sub)]; % Name of the dataset (P for pilot)
    EEG = eeg_checkset( EEG );
    % Re-reference to average of mastoids
    EEG = pop_reref( EEG, [27 28] );    % re-reference to average of mastoids
    EEG = eeg_checkset( EEG );
    filename = ['rK1_P' num2str(sub)]; 
%     EEG = pop_saveset( EEG, filename, [exp.preprdata '/P' num2str(sub)]);  % FIRST SAVED FILE - REREFERENCED
    % Filter 
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:30 , 'Boundary', 'boundary', 'Cutoff', [exp.filter.lowerbound  exp.filter.upperbound], 'Design', 'butter', 'Filter', 'bandpass', 'order',8);
    EEG = eeg_checkset( EEG );
    filename = ['frK1_P' num2str(sub)];
%     EEG = pop_saveset( EEG, filename, [exp.preprdata '/P' num2str(sub)]);  % SECOND SAVED FILE - FILTERED
    % Downsample
    EEG = pop_resample( EEG, exp.downsampling_rate);
    EEG = eeg_checkset( EEG );
    filename = ['dfrK1_P' num2str(sub)];
    EEG = pop_saveset( EEG, filename, [exp.preprdata '/P' num2str(sub)]); % THIRD SAVED FILE - RESAMPLED
end