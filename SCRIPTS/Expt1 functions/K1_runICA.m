function [EEG]  = K1_runICA(sub,exp) 

% Take out all epochs of interest - both around orange letter and SP
% keypresses
    
    % Epoch around Trigger 1 and 2 together
    EEG = pop_loadset( [exp.filepath 'cdfrK1_P' num2str(sub) '.set'] );
    EEG = pop_epoch( EEG, [{'Trigger 1'}, {'Trigger 2'}], [-2.5, 0.5] , 'newname', ['K1_P' num2str(sub) '_stimLockEpochs'], 'epochinfo', 'yes');
    
     % Run ICA
     EEG = eeg_checkset(EEG);
     %EEG = pop_runica(EEG); % For manually running without certain channels
     EEG = pop_runica(EEG, 'extended', 1); % For running the whole thing automatically
     EEG = pop_saveset(EEG, ['ICA_cdfrK1_P' num2str(sub)], exp.filepath);

end