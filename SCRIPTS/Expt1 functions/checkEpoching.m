function [out]  = checkEpoching(sub,exp) 

% Load continuous data
EEGcont = pop_loadset([exp.filepath '/dfrK1_P' num2str(sub) '.set']); 
OL_original = sum(strcmp({EEGcont.event.type}, "Trigger 1"));

% Load epoched + corrected data
EEGep8 = pop_loadset([exp.filepath '/K1_epochOL8_P' num2str(sub) '.set']); 
OL_epoched8 = sum(strcmp({EEGep8.event.type}, "Trigger 1"));

EEGep12 = pop_loadset([exp.filepath '/K1_epochOL12_P' num2str(sub) '.set']); 
OL_epoched12 = sum(strcmp({EEGep12.event.type}, "Trigger 1"));

if (OL_original ~= OL_epoched8) || (OL_original ~= OL_epoched12)
    
    % Compare UR events and find the missing epoch

    allURevents = [EEGcont.event.urevent];
    UR_cont= allURevents(strcmp({EEGcont.event.type}, "Trigger 1"));

    allUreventsEp8 = [EEGep8.event.urevent];
    UR_ep8 = allUreventsEp8(strcmp({EEGep8.event.type}, "Trigger 1"));
    
    allUreventsEp12 = [EEGep12.event.urevent];
    UR_ep12 = allUreventsEp12(strcmp({EEGep12.event.type}, "Trigger 1"));
   
    diff_ep8 = setdiff(UR_cont', UR_ep8');
    diff_ep12 = setdiff(UR_cont', UR_ep12');
    
else
    
    diff_ep8 = NaN;
    diff_ep12 = NaN;
    
    
end
    
    out = [{diff_ep8}, {diff_ep12}];

end
    


% % Numberof orange letters
% sum(strcmp({EEG.event.type}, "Trigger 1"))
% 
% % How many unique urevent numbers?
% allUrevents = [EEG.event.urevent];
% length(unique(allUrevents(strcmp({EEG.event.type}, "Trigger 1"))))
% 
% 
% % Compare two UR events
% 
% allUrevents = [EEG.event.urevent];
% UR_end = allUrevents(strcmp({EEG.event.type}, "Trigger 1"));
% 
% allUreventsICA = [EEGica.event.urevent];
% UR_ica = allUreventsICA(strcmp({EEGica.event.type}, "Trigger 1"));
% length(unique(allUreventsICA(strcmp({EEGica.event.type}, "Trigger 1"))))
% 
% length(unique(allUreventsICA(strcmp({EEGica.event.type}, "Trigger 1"))))
