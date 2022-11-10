%% Add values to EEG datafile
% Source: http://www.mikexcohen.com/lecturelets/manytrials/manytrials.html
% Input:
%   -EXPER: structure with experimental parameters for wavelet transformation 
% Output: 
%   -DAT: structure with 3 sub-structures: 
        
function [dat] = E3_addBinaryCoding(exper, newDat)

id = 0;
for sub = exper.sub_id(1:end)
    disp(num2str(sub)); %display participant ID
    id = id +1;
       
    EEG.meanRating = unique(newDat(newDat.sub == sub,:).meanRating)
    thissub.meanrating = EEG.meanRating
    EEG = pop_loadset(['F:/PhD - London/E3 - Gradual Awareness/april2019/rec_kprej' num2str(exper.kpe) '_acICAabodfrE3_P' num2str(sub) '.set']);
    % Load behavioural data
    load(['F:/PhD - London/E3 - Gradual Awareness/april2019/E3_P' num2str(sub) '_behavioural_results_kpe' num2str(exper.kpe) 'rejected']);
   
    j = 0;
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'Trigger 1')
            if (strcmp(EEG.event(i).value, 'reject') == 0 && strcmp(EEG.event(i).value, 'postProbePress') == 0)
                j = j+1;
                if str2num(EEG.event(i).value) > thissub.meanrating
                    EEG.event(i).binrating = 'High';
                    EEG.event(i).index = j;
                elseif str2num(EEG.event(i).value) < thissub.meanrating
                    EEG.event(i).binrating = 'Low';
                    EEG.event(i).index = j;
                                      
                end

            end
        end
    end
    
    EEG = pop_saveset( EEG, ['E3_highLow_rec_kprej' num2str(exper.kpe) '_acICAabodfrE3_P' num2str(sub) '.set'], exper.filepath);
    o = 0;
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'Trigger 1')
            o = o+1;
            EEG.event(i).isorange = o;
        end
    end
        
   %%% CONTINUE HERE!
    idx = find(~cellfun(@isempty,{EEG.event(:).binrating}));
    binvectors{id} = [{EEG.event(idx).binrating}'];
    binindices{id} =  [EEG.event(idx).isorange]';
    %Get indices of included trials
    %evidx = find(~cellfun(@isempty,{EEG.event(:).index}));
    %eventindex{id} = {EEG.event(idx).binrating}
    
    save('E3_OL_HighLow_binvectors.mat', 'binvectors', 'binindices')
    clear thissub.meanrating;  clear idx; clear o; 
    clear EEG; 
end


%% Append to beta burst dataset 
load('E3_betaBursts.mat');

betatable = array2table(betaBursts)
betatable.Properties.VariableNames(1:8) = {'id', 'cond', 'burstcount', 'betamean', 'startlast', 'endlast','amplast','durlast'}
%%
betatable.binary_rating = repmat(0, length(betaBursts),1);
betatable.binary_rating = num2cell(betatable.binary_rating);

 for sub = 1:17
    idx = (betatable.id == sub);
    emptyvector = repmat(0, length(betatable.id),1);
    thisSub_idx = binindices{1,sub} + (find(idx, 1,'first')-1);
    betatable(thisSub_idx,:).binary_rating = binvectors{sub};
    clear idx; clear emptyvector; clear thisSub_idx;
end

save('E3_betaBursts_HighLow.mat', 'betatable')












