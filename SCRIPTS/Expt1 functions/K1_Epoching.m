function [EEG, out]  = K1_Epoching(sub,exp, trigger, rejectRange) 
% Take the after-eye-movements-rejection data and epoch separately around the trigger of interest. 

if trigger == 2 % Epoching around self-paced
    
    % Import a file that's rereferenced, filtered, downsampled, corrected for doubled triggers, and corrected for eye blink artefacts
    EEG = pop_loadset( [exp.filepath 'eICA_cdfrK1_P' num2str(sub) '.set'] );
    
    EEG = pop_epoch(EEG, {'Trigger 2'}, [-2.5, 0.5] , 'newname', ['K1_P' num2str(sub) '_actionLockEpochs'], 'epochinfo', 'yes'); 
    EEG = pop_rmbase(EEG, [-2500, -2000]); % Take the baseline
    EEG = pop_saveset(EEG, ['bSP_eICA_cdfrK1_P' num2str(sub)], exp.filepath);
    out = NaN;
    
elseif trigger == 1 % Epoching around orange letter
        
    % Import a file that's rereferenced, filtered, downsampled, corrected for doubled triggers, and corrected for eye blink artefacts
    EEG = pop_loadset( [exp.filepath 'eICA_cdfrK1_P' num2str(sub) '.set'] );
     
    if rejectRange == 8 % Epoch around orange letters - 2s before because rejectRange = 8
    
        EEG = pop_epoch(EEG, {'Trigger 1'}, [-2.0, 0.5] , 'newname', ['K1_P' num2str(sub) '_stimLockEpochs'], 'epochinfo', 'yes'); 
        EEG = pop_rmbase(EEG, [-2000, -1500]); % Take the baseline
        EEG = pop_saveset(EEG, ['bOL8_eICA_cdfrK1_P' num2str(sub)], exp.filepath);
        
    elseif rejectRange == 12     % Epoch around orange letters - 2.5s before because rejectRange = 12
        
        EEG = pop_epoch(EEG, {'Trigger 1'}, [-2.5, 0.5] , 'newname', ['K1_P' num2str(sub) '_stimLockEpochs'], 'epochinfo', 'yes');
        EEG = pop_rmbase(EEG, [-2500, -2000]); % Take the baseline
        EEG = pop_saveset(EEG, ['bOL12_eICA_cdfrK1_P' num2str(sub)], exp.filepath);
        
    end
    
% Check whether some epochs are repeated twice - this happens if the same Trigger 1 (orange letter) was included in both an orange letter
% epoch and a self-paced epoch when epoching together for ICA. When this happens, take only the first epoch (they are exactly the same). 
    
    EEG = eeg_checkset(EEG);
    olIdx = find(strcmp({EEG.event.type}, "Trigger 1")); % Indices of all orange letter triggers
    epochsToDel = [];

    for i = 1:(length(olIdx) - 1) % Go through all orange letters
        this = olIdx(i); 
        next = olIdx(i + 1);
       if (EEG.event(this).urevent == EEG.event(next).urevent) % If the urevent is the same as that of the next orange letter
            EEG.event(this).label = "deleteEpoch"; % Mark to delete epoch
            epochsToDel = [epochsToDel EEG.event(this).epoch]; % Note down epochs to be deleted
       end
    end  
    
EEG = pop_select(EEG, 'notrial', epochsToDel); % Delete the epochs marked for deletion

% Compare if the number of triggers is same as in continuous data after
% deleting doubled epochs

 % Load continuous data
EEGcont = pop_loadset([exp.filepath '/dfrK1_P' num2str(sub) '.set']); 

% List all UR events of Trigger 1 from continuous data
allUReventsCont = [EEGcont.event.urevent];
UR_cont= allUReventsCont(strcmp({EEGcont.event.type}, "Trigger 1"));
    
% List all UR events of Trigger 1 from epoched and corrected data    
allURevents = [EEG.event.urevent];
UR_epoched = allURevents(strcmp({EEG.event.type}, "Trigger 1")); 

% Compare the UR numbers
diff_ep = setdiff(UR_cont', UR_epoched');

if ~isempty(diff_ep) % If there are any triggers missing compared to continuous data
    
    % Load the epoched but not corrected for doubled epochs dataset
    EEG = pop_loadset( [exp.filepath 'bOL' num2str(rejectRange) '_eICA_cdfrK1_P' num2str(sub) '.set'] );
    % Find the epoch number of the epoch(s) missing in the corrected dataset
    missingEpoch = [];
    
    for UR = diff_ep' % find the epoch numbers of all identified URs
            
        findEpoch = [EEG.event([EEG.event.urevent]' == UR).epoch];
        missingEpoch = [missingEpoch findEpoch];
        
    end
    
    % Don't delete the epoch(s) that were missing from the continuous dataset
    % epochsToDelCorr = setdiff(epochsToDel, unique(missingEpoch));
    % EEG = pop_select(EEG, 'notrial', epochsToDelCorr); % Delete the epochs marked for deletion
    
    out = [{epochsToDel}, {missingEpoch}];
    
    % disp(['A total of ' num2str(length(epochsToDelCorr)) ' doubled epochs deleted: ' num2str(epochsToDelCorr) '. Inspect visually epoch ' num2str(missingEpoch)])
    EEG = pop_saveset( EEG, ['K1_manuallyRejectEpochs_OL' num2str(rejectRange) '_P' num2str(sub)],  exp.filepath);    

else
    
    EEG = pop_saveset( EEG, ['K1_epochOL' num2str(rejectRange) '_P' num2str(sub)],  exp.filepath);    
    out = [{NaN}, {NaN}];
end

        
end


end
