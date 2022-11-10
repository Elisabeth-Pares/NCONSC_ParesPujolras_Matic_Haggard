function [events, eventsEEG] = K1_compareEvents(expData, exp,  sub)
% COMPARE EVENTS function lists all events from the behavioural dataset
% given in expData, and then lists all EEG Triggers. It compares the length
% of EEG events with all behavioural events, and gives output in the command
% line - if there's any mismatch it reports it, if the mismatch is not due
% to action triggers (1-4) it reports that the mismatch is due to triggers
% that are not of interest (wQ and trial start), and if there is a mismatch
% in action triggers it gives a table with all counts. 
% It returns two structures: events(sub) and eventsEEG(sub), each listing events in
% behavioural and EEG datasets respectively. These are later used to
% cross-match the EEG and behavioural dataset indices.

% Trigger 1 - orange letter
% Trigger 2 - SP press
% Trigger 3 - OL - AW key
% Trigger 4 - OL - SP key
% Trigger 5 - w-question
% Trigger 6 - trial start

%% Assign keys depending on which hand was used
if strcmp(expData.hand(1), 'RIGHT')
    SP_response = 'RightArrow';
    AW_response = 'LeftArrow';
else
    SP_response = 'LeftArrow';
    AW_response = 'RightArrow';
end

%% Find events in the behavioural dataset

% Find action events
events.OL  = find(expData.blackOrange);
events.SP   = find(strcmp(expData.keyPressed, SP_response));
events.AW = find(strcmp(expData.keyPressed, AW_response));
% Find other events
events.wQ = length(find(expData.endTrial));
events.trialStart = length(find(expData.letIdx == 1)) - 6; % Because there's 6 practice trials in EEG triggers that are not in behavioural dataset
% Find all events
events.Total = length(events.OL) + length(events.SP) + length(events.AW) + events.wQ + events.trialStart;
% List only keypresses - relevant for later double keypresses
events.allPresses = sort([events.SP; events.AW]);

%% Find events in the corresponding EEG dataset

% Import EEG dataset
EEG = pop_loadset([exp.preprdata '/P' num2str(sub) '/dfrK1_P' num2str(sub) '.set']); 

% Find all events
eventsEEG.Total = length(EEG.event);
% Find action events
eventsEEG.OL = find(strcmp({EEG.event(:).type}, {'Trigger 1'}))';
eventsEEG.SP = sort([find(strcmp({EEG.event(:).type}, {'Trigger 2'})), find(strcmp({EEG.event(:).type}, {'Trigger 4'}))])';
eventsEEG.AW = find(strcmp({EEG.event(:).type}, {'Trigger 3'}))';
% Find other events
eventsEEG.wQ = sum(strcmp({EEG.event(:).type}, {'Trigger 5'})); 
eventsEEG.trialStart = sum(strcmp({EEG.event(:).type}, {'Trigger 6'}));
% List only keypresses - relevant for later double keypresses
eventsEEG.allPresses = sort([eventsEEG.SP; eventsEEG.AW]);


%% Display in the command line

disp(['Total number of behavioural events: ' num2str(events.Total)])
disp(['Total number of EEG events: ' num2str(eventsEEG.Total)])

if events.Total ~= eventsEEG.Total % If there's a difference between behavioural and EEG events
        
    disp(['SUBJECT ' num2str(sub) ': Events mismatch identified.'])
    
    if (length(events.OL) == length(eventsEEG.OL)) && (length(events.SP) == length(eventsEEG.SP)) && (length(events.AW) == length(eventsEEG.AW))
        % Identify if the difference is because of keypresses or Triggers
        % 5/6 (less important if it's those triggers)
        disp('All keypresses match. Mismatch caused by Trigger 5 or Trigger 6.')
        
    else
        
        disp('Mismatch in keypresses. Explore further.')
        
    comparisonTable = table('Size', [6 2], 'VariableTypes', ["double", "double"], 'VariableNames', {'Behavioural', 'TriggersEEG'}, 'RowNames', {'Orange', 'SelfPaced', 'AWreport', 'wQuest', 'trialStart', 'Total'});
    comparisonTable.Behavioural = [length(events.OL); length(events.SP); length(events.AW); events.wQ; events.trialStart; events.Total];
    comparisonTable.TriggersEEG = [length(eventsEEG.OL); length(eventsEEG.SP); length(eventsEEG.AW); eventsEEG.wQ; eventsEEG.trialStart; eventsEEG.Total];

    disp(comparisonTable)
    
    end
    
end    

end

