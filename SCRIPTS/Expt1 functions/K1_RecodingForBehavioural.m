function [expData] = K1_RecodingForBehavioural(expData, exp, sub)

% Find all orange letters in the dataset
orangeIdx = find(expData.blackOrange == 1); % Find indices of orange letters within whole experiment 

% Get rid of the last orange letter if the last response interval is too
% short to answer
if (height(expData) - orangeIdx(end)) < exp.orangeLetterResponse
    expData.ID(end + 8) = NaN;
end
  
SP_response = 'RightArrow';
AW_response = 'LeftArrow';


%% If there was an orange letter

% First rename just the practice trials
label = strcat('orangePracticeRound');
expData.RecodingOL( orangeIdx(~strcmp(expData.nameOfBlock(orangeIdx), 'experiment'))  ) = {label};

% Then rename other trials
for i = (length(orangeIdx(~strcmp(expData.nameOfBlock(orangeIdx), 'experiment'))) + 1): length(orangeIdx) % For every orange letter that's not in practice trials
       
    % Find if there was a response to orange letter within the response
    % interval and where exactly
    responseIdx = find(~isnan( expData.timeAction(orangeIdx(i):(orangeIdx(i) + exp.orangeLetterResponse)) ));
    
    if isempty(responseIdx)
        
        label = strcat('orange_noResponse'); 
        
    elseif length(responseIdx) == 1 
        
        if strcmp(expData.keyPressed(orangeIdx(i) + (responseIdx - 1)), SP_response)
            
            label = strcat('orangeResponse_SPkey');
             
        elseif strcmp(expData.keyPressed(orangeIdx(i) + (responseIdx-1)), AW_response)
            
            label = strcat('orangeResponse_AWkey');
            
        end
        
    elseif length(responseIdx) >= 2
        
        label = strcat('orangeResponse_both');
        
    end
    
    expData.RecodingOL(orangeIdx(i) + responseIdx - 1) = {label};
        
end % End the i for-loop 

% Write the file with recoding column as a new file
writetable(expData, fullfile(exp.mainpath, '/data/behavioural',['P' num2str(sub)], ['K1_P' num2str(sub) '_RecodingForBeh.csv']));
disp(['Dataset with ''Recoding (OL)'' column added written to: ' fullfile(exp.mainpath, '/data/behavioural',['P' num2str(sub)], ['K1_P' num2str(sub) '_RecodingForBeh.csv'])]) 

end

