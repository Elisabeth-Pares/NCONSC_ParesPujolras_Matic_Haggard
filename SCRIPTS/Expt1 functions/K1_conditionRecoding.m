function [EEG] = K1_conditionRecoding(EEG,recVector,trigger)   

% allTrigger1 = find(strcmp({EEG.event.type}, "Trigger 1"))';

    for i = 1:length(EEG.event) % Do manually for SUB 6 - i = 1:444
        
         if strcmp(trigger, EEG.event(i).type)
             
                 EEG.event(i).value = recVector{EEG.event(i).epoch};
            
         end
         
    end
    
end
