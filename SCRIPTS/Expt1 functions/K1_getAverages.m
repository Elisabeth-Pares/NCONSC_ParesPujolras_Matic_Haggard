function [allEEG] = K1_getAverages(exp)
j = 1;
allP = [];
for i =  exp.sub_id(1:end)
    disp(['Averaging participant ' num2str(i) '...'])
    EEG = pop_loadset(['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/action_locked/SPaction_K1_aepochSP_P' num2str(i) '.set']);
    
    thisP= mean(EEG.data,3); % average across trials
    %Make sure channels are in right order 
    if i == 21
        cthisP(1:14,:) = thisP(17:30,:); 
        cthisP(15:30,:) = thisP(1:16,:);
        thisP = cthisP; 
    end
    allP(:,:,j) = [thisP];
    j = j+1;
    clear thisP; 
end
allEEG.data = allP;
allEEG.chanlocs = EEG.chanlocs; 
allEEG.times = EEG.times;

times = [-0.1];
%% Plot average topography 
K1_plotTopography(allEEG, times, 'Experiment 1 RP topography', exp)

