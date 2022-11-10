function [expData] = K1_Recoding(expData, exp, sub, orangeRejectRange)

% Define here how long the orange letter response range is (8 = 2 seconds to respond to OL)
exp.orangeLetterResponse = 8; 

% Find all orange letters in the dataset
orangeIdx = find(expData.blackOrange == 1); % Find indices of orange letters within whole experiment 
 
% Assign keys depending on which hand was used
if strcmp(expData.hand(1), 'RIGHT')
    SP_response = 'RightArrow';
    AW_response = 'LeftArrow';
else
    SP_response = 'LeftArrow';
    AW_response = 'RightArrow';
end

%% Find indices of all things

% Name all SP keypresses in RecodingSP column
SPresponseIdx = find(strcmp(expData.keyPressed, SP_response));
label = strcat('SP_keypress');
expData.RecodingSP(SPresponseIdx)  = {label};

% First rename just the practice trials
label = strcat('orangePracticeRound');
expData.RecodingOL( orangeIdx(~strcmp(expData.nameOfBlock(orangeIdx), 'experiment'))  ) = {label};
label = strcat('SP_PracticeRound');
expData.RecodingSP( SPresponseIdx(~strcmp(expData.nameOfBlock(SPresponseIdx), 'experiment')) )  = {label};

% Then rename other trials
for i = (length(orangeIdx(~strcmp(expData.nameOfBlock(orangeIdx), 'experiment'))) + 1): length(orangeIdx) % For every orange letter that's not in practice trials
       
    % Find if there was a response to orange letter within the response interval and where exactly
    responseIdx = find(~isnan( expData.timeAction(orangeIdx(i):(orangeIdx(i) + exp.orangeLetterResponse)) ));
    
    % Find if there was any SP keypress before the orange letters - relevant for trial exclusion
    exclusionIdx = find(~isnan( expData.timeAction( (orangeIdx(i) - orangeRejectRange):(orangeIdx(i) - 1) )));
    
    if exclusionIdx > 0 % If there was any press within the pre-letter reject range
        
         label = strcat('orange_reject'); 
    
    elseif isempty(responseIdx) % If there was nothing after the post-letter response range
        
        label = strcat('orange_noResponse'); 
        
    elseif length(responseIdx) == 1 
        
        if strcmp(expData.keyPressed(orangeIdx(i) + (responseIdx - 1)), SP_response) % If there was a SP press in response range
            
            label = strcat('orangeResponse_SPkey');
            expData.RecodingSP((orangeIdx(i) + (responseIdx - 1)))  = {'SP_orange'};
             
        elseif strcmp(expData.keyPressed(orangeIdx(i) + (responseIdx-1)), AW_response) % If there was a AW press in response range
            
            label = strcat('orangeResponse_AWkey');
            expData.RecodingSP((orangeIdx(i) + (responseIdx - 1)))  = {'AW_orange'};
            
        end
        
    elseif length(responseIdx) >= 2 % If there was more than one press in response range
        
        label = strcat('orangeResponse_both');

    end
    
    expData.RecodingOL(orangeIdx(i)) = {label}; % Add the label to the RecodingOL column
    
end % End the i for-loop  

% Rename the columns depending on the reject range
expData.Properties.VariableNames{strcmp(expData.Properties.VariableNames, 'RecodingOL')} = ['RecodingOL' num2str(orangeRejectRange)]; 
expData.Properties.VariableNames{strcmp(expData.Properties.VariableNames, 'RecodingSP')} = ['RecodingSP' num2str(orangeRejectRange)]; 
%% Write the file with recoding column as a new file
writetable(expData, fullfile(exp.mainpath, '/data/behavioural',['P' num2str(sub)], ['K1_P' num2str(sub) '_rOL.csv']));
disp(['Dataset with added ''RecodingOL' num2str(orangeRejectRange) ''' column written to: ' exp.mainpath, 'data/behavioural/P' num2str(sub) '/K1_P' num2str(sub) '_rOL.csv']) 

end
