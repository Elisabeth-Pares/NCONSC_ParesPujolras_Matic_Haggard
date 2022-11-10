function [expData] = K1_importBehavioural(exp,sub)


% Import the data file
expData = readtable(fullfile(exp.mainpath, '/data/behavioural/',['P' num2str(sub)], ['K1_P' num2str(sub) '.csv']));

% Only take the real "experiment" part
% rows = (strcmp(data.nameOfBlock,'experiment'));
% expData = data(rows,:);     

% Prolong the data file, otherwise all code that checks things after the
% last keypress gets buggy
expData.ID(end + 10) = NaN;


% Display to command window
disp(['Dataset imported from ' fullfile(exp.mainpath, '/data/behavioural/',['P' num2str(sub)], ['K1_P' num2str(sub) '.csv'])])

end
