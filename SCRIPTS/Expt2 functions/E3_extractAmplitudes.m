function [] = E3_extractAmplitudes(exp)
%% Extract data & average
% Single trial data for each subject, each interest channel

i = 0;
for channels= exp.chanlabels(1:end) %Loop through channels of interest 
    thisChan = channels{1};
    i = 0;
    n = length(exp.sub_id);
    allP_behData = [];
    
     for sub = exp.sub_id(1:end)
         idxnoPostP = [];
         EEG.arindx = [];
         i = i+1;
         % Load EEG data 
         EEG = pop_loadset(['E:/PhD - London/E3 - Gradual Awareness/april2019/rec_kprej' num2str(exp.kpe) '_acICAabodfrE3_P' num2str(sub) '.set']) %NEWrec_kprej
         % Load behavioural data 
         load([exp.behPath, 'E3_P' num2str(sub) '_recoding_rej' num2str(exp.kpe)]);     
         % Load burst data          
         load([exp.procPath, 'E3_betaBursts_morletCycles_' num2str(exp.morletCycles) 'orangeLetter_' thisChan '.mat'])
         this_betaBursts = betaBursts(betaBursts(:,1) == sub,:) %get data for this subject

         % Reject EEG artefactual trials from behavioural matrix. 
         all_recoding_all(EEG.arindx) = [];
         all_results(EEG.arindx,:) = [];
         
         %For all readiness ratings (0-not ready at all, 7-about to move)
         all_results(:,7:16) = NaN;
         for j = [0:7]
             idx = find(strcmp(all_recoding_all,num2str(j)));
             allP_singleTrial{i,j+1} = squeeze(EEG.data(exp.chans,:,idx)); 
             if size(allP_singleTrial{i,j+1},1) == 500
                 allP_singleTrial{i,j+1} = allP_singleTrial{i,j+1}'
             end
             
             %Get mean RP amplitude in last 100ms, for each trial
             meanRP = mean(allP_singleTrial{i,j+1}(:,280:300),2); 
             all_results(idx,7) = meanRP;

             % Add beta burst data
             all_results(idx,1:16) = [all_results(idx,1:7), this_betaBursts(idx,:)];
             
             %Get indices of all good trials w/o keypresses after orange letter
             idxnoPostP = [idxnoPostP; idx];
             clear idx; clear meanRP; 
         end

         %Do the same for trials with post probe keypresses - these will be
         %excluded from further analysis.
         idxpostP = find(strcmp(all_recoding_all,'postProbePress'));
         allP_singleTrial{i,9} = squeeze(EEG.data(exp.chans,:,idxpostP));
         if size(allP_singleTrial{i,9},1) == 500
             allP_singleTrial{i,9} = allP_singleTrial{i,9}'
         end
         
         meanPost= mean(allP_singleTrial{i,9}(:,280:300),2);
         all_results(idxpostP,7) = meanPost;
                    
         % Delete rejected trials
         all_results(isnan(all_results(:,6)),:) = [];
         allP_behData = [allP_behData; all_results];
         
%          save(['E3_P' num2str(sub) '_behavioural_results_kpe' num2str(exp.kpe) 'rejected_EEGcleaned_betaBursts_' thisChan],...
%              'all_recoding_all', 'all_results');
         
         clear all_results; clear idx;
         clear idxpostP; clear idxnoPostP; clear meanPost;
         clear this_betaBursts;
     end
     
     save([exp.procPath, 'E3_allP' num2str(exp.kpe) '_n' num2str(n) 'morletCycles_' num2str(exp.morletCycles) '_singleTrial_EEG_BehData_betaBursts_' thisChan],...
         'allP_singleTrial', 'allP_behData');

     allP_behData = array2table(allP_behData); 
     allP_behData(:,[4,5,9]) = []; 
     allP_behData.Properties.VariableNames = {'ur_id', 'block', 'rating', 'lastKeypress', 'RPAmp', 'id', 'burstcount', 'betamedian', 'betamean', 'startlast', 'endlast', 'amplast', 'durlast'};
%      writetable(allP_behData, [exp.procPath, 'E3_R_allP_behData_ICA_betaBursts_morletCycles_' num2str(exp.morletCycles) '_' thisChan '.csv']);
     writetable(allP_behData, [exp.procPath, 'Exp2_R_burstData_OL_' thisChan '.csv']);

end

