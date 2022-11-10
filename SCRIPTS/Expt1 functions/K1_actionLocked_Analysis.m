function []  = K1_actionLocked_Analysis(sub,exp) 
%K1_actionLocked_Analysis - FOR EPOCHING AROUND SELF-PACED KEYPRESSES
    
    % Epoch around Trigger 2
    EEG = pop_loadset( [exp.filepath 'dfrK1_P' num2str(sub) '.set'] );
    EEG = pop_epoch( EEG, {  'Trigger 2'  }, exp.actionEpoch , 'newname', ['K1_P' num2str(sub) '_actionLockEpochs'], 'epochinfo', 'yes');
    EEG = pop_saveset( EEG, ['SP_dfrK1_P' num2str(sub)], exp.filepath);
    
    % Baseline
    EEG = eeg_checkset(EEG);
    EEG = pop_rmbase(EEG, exp.actionBaseline);
    EEG = pop_saveset(EEG, ['bSP_dfrK1_P' num2str(sub)], exp.filepath);
   
end