function [allEEG] = E3_getAverages(exp)
j = 1;
allP = [];


figure;
for i =  exp.sub_id(1:end)
   
    if i < 7 
        exp.chans = [1,2,3];
    else %Note: these participants had one electrode in a different configuration. 
        exp.chans = [1,7,3];
    end
      
    disp(['Averaging participant ' num2str(i) '...'])
    EEG = pop_loadset(['E:/PhD - London/E3 - Gradual Awareness/april2019/elect3_abadfrE3_P' num2str(i) '.set']) %ICAbad?
    
    %automatically interpolate bad electrodes to get nice topoplot
    % Identify bad channels based on kurtosis
    [iEEG,indelec] = pop_rejchan(EEG,'elec',[1:26],'threshold',3,'norm','on','measure','kurt');
    EEG.badChan = indelec;
    
    EEG = eeg_interp(EEG,indelec);
    EEG = eeg_checkset(EEG);

    thisP= mean(EEG.data,3); % average across trials
    allP(:,:,j) = [thisP];
    
    if i<7 %Put in the right position for averaging in topography 
        fcz = thisP(2,:,:);
        f3 = thisP(7,:,:);
        allP(7,:,j) = fcz; 
        allP(2,:,j) = f3; 
        clear cz; clear f3;
    end
    
    subplot(5,4,j);
    plot(1:700,thisP(exp.chans,:))
    clear thisP; clear indelec;
        j = j+1;

end
allEEG.data = allP;
allEEG.chanlocs = EEG.chanlocs; 
allEEG.times = EEG.times;

times = [-0.1]; %Time to plot
E3_plotTopography(allEEG, times, 'Experiment 2 RP topography',exp)
