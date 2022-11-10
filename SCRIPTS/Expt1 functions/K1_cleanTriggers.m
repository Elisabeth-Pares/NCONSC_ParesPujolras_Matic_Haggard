function [EEG, deleted_triggers, skipped_triggers] = K1_cleanTriggers(sub, exp, stuckIdxEEG, doubleStuckIdxEEG)

EEG = pop_loadset( [exp.preprdata '/P' num2str(sub) '/ldfrK1_P' num2str(sub) '.set'] );
stuck = sort([stuckIdxEEG doubleStuckIdxEEG]);
deleted_triggers = [];
skipped_triggers = [];

for i = 1:length(stuck)
    
    idx = stuck(i);
    
    if EEG.event(idx).type == EEG.event(idx + 1).type % If there is no other Trigger inbetween or other weird stuff going on
        
        if (EEG.event(idx + 1).latency - EEG.event(idx + 1).latency) < 125 % If they are less then 0.5s apart
            
            EEG.event(idx + 1).label = 'automatic delete';
            deleted_triggers = [deleted_triggers (idx + 1)];
            
        else
            
            skipped_triggers = [skipped_triggers idx];
            
        end
        
    else
        
        skipped_triggers = [skipped_triggers idx];
        
    end
    
end

[EEG.event(deleted_triggers'-1).label] = deal(''); % Delete the label that it's double-stuck
EEG.event(deleted_triggers) = []; % Delete the second trigger

disp(['Removed ' num2str(length(deleted_triggers)) ' doubled triggers. Investigate rmaining triggers ' num2str(skipped_triggers) ' manually before saving the dataset.'])

end


