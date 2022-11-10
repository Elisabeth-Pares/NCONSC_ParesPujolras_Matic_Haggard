function [expData, stuckIdxEEG, doubleStuckIdxEEG] = K1_checkDoublePresses(exp, expData, sub, events, eventsEEG)
% K1_CHECKDOUBLEPRESSES cleans the behavioural dataset of stuck
% keypresses and returns the cleaned expData behavioural dataset. It also
% identifies the indices of stuck keys in the EEG dataset and adds labels
% to a new 'labels' column in EEG.events. It returns the labels EEG dataset
% and saves it as '/l_dfrK1_P.
  
stuckIdx = [];
doubleStuckIdx = [];
action = 0;

%%  How many time there is a stuck key (Arrow - Arrow or Arrow - NaN - Arrow)

for i = 1:(length(expData.keyPressed) - 10) % Go through all the letters (but ignore added 10 empty fields)
    
    if ~strcmp(expData.keyPressed{i}, 'NaN') % If there is a key press at some letter 
        
        if strcmp(expData.keyPressed{i + 1}, expData.keyPressed{i}) % If the same key is still pressed on the next letter
             stuckIdx = [stuckIdx; i];
             expData.keyPressed{i+1} = 'NaN'; % Replace the stuck key with 'NaN' 
             expData.timeAction(i+1) = NaN;
             expData.RT(i+1) = NaN;
             
        end
        
         if strcmp(expData.keyPressed{i + 2}, expData.keyPressed{i})  % Check if there's a same key pressed two letters later
            doubleStuckIdx = [doubleStuckIdx; i];
            expData.keyPressed{i + 2} = 'NaN'; % Replace the stuck letter with 'NaN' 
            expData.timeAction(i + 2) = NaN;
            expData.RT(i + 2) = NaN;
           
         end
               
         action = action + 1;
         
    end
    
end

%% Find the indices of stuck keys in EEG data and label them
 % First check which indices in the list of all behavioural events
 % correspond to stuck keys, and then find the row indices in the list
 % of EEG triggers corresponding to these events
    
doubleStuckIdxEEG = [];
for i = 1:length(doubleStuckIdx)
   
    doubleStuckIdxEEG = [doubleStuckIdxEEG, eventsEEG(sub).allPresses(events(sub).allPresses == doubleStuckIdx(i))];
end

stuckIdxEEG = [];
for i = 1:length(stuckIdx)
    stuckIdxEEG = [stuckIdxEEG, eventsEEG(sub).allPresses(events(sub).allPresses == stuckIdx(i))];
end

% Load the EEG dataset and add the labels for doubled triggers to a new
% column EEG.type.label. Save this EEG structure as 'ldfrK1_P#'.
EEG = pop_loadset([exp.preprdata '/P' num2str(sub) '/dfrK1_P' num2str(sub) '.set']); 
[EEG.event(doubleStuckIdxEEG).label] = deal('double_stuck_trigger');
[EEG.event(stuckIdxEEG).label] = deal('stuck_trigger');
EEG = pop_saveset(EEG, ['ldfrK1_P' num2str(sub)], [exp.preprdata '/P' num2str(sub)]);

%% Display to command window
disp(['A total of ' num2str(length(stuckIdx)) ' stuck key presses identified.'])
disp(['A total of ' num2str(length(doubleStuckIdx)) 'double stuck key presses identified.'])
disp(['A total of ' num2str(action - length(stuckIdx) - length(doubleStuckIdx)) ' non-stuck key presses identified.'])
disp(['Doubled triggers identified - indices: ' num2str(stuckIdxEEG) num2str(doubleStuckIdxEEG)])

end
