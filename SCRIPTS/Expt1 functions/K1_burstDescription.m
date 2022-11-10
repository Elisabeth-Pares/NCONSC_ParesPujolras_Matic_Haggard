function [] = K1_burstDescription(exp, epoch, par)

if strcmp(epoch, 'orangeLetter')
    epochType = 'orangeLetter';
    trialType = {'orangeLetter'};
    epoch_dur = 300; 
elseif  strcmp(epoch, 'selfPaced')
    epochType = 'selfPaced';
    trialType = {'selfPaced_all'}; % strcmp(epoch, 'orangeLetter')
    %Note: epochs are 500 data points, but we want to look at pre-orange letter data only (up to sample 300, 1.5 s at 200 sampling rate)
end

for tt = trialType(1:end)
    if strcmp(tt,'selfPaced_all')
        epoch_onset = 100;
        epoch_dur = 500;
    elseif strcmp(tt, 'orangeLetter')
        epoch_onset = 1;
        epoch_dur = 300; %from start to orange letter
    end
    
    load([exp.processedData, 'Exp1_R_burstData_fullDetails_' epoch '.mat'])
    
    maxrho = 7; %Based on OL data
    %Mean burst duration
    tiledlayout(4,5)
    for i = 1:length(dat)
        allBursts = [(dat{1, i}.burstdur{1, 7}{1:end,1})];
        %Remove 200's and 0's
        allBursts(allBursts == 1) = []; % Remove trials with no bursts 

        meanDur.(tt{1})(i) = mean(allBursts)/200*1000; %In ms
        clear allBursts;
        
        %Mean burst count 
        meanCount.(tt{1})(i) = mean(dat{i}.allTrials{maxrho}.dat(:,1)); 
        %Mean burst amplitude
        %field st_amp_burst acts as a mask for single trial amplitudes st_amp
        amplitudeData = dat{i}.st_amp{1}(epoch_onset:epoch_onset+epoch_dur-1,:);
        mask = dat{i}.st_amp_burst{1,maxrho}(1:epoch_dur,:);
        maskedData = amplitudeData(mask);
        meanAmp.(tt{1})(i) = mean(maskedData);
        
        %%Note: two participants in this data set show strange peaks around
        %%the time of action, possibly eyeblinks (self-paced data were not
        burstP(i,:) = nanmean(mask,2); %Over trials
        meanBeta(i,:) = nanmean(amplitudeData,2);
        
        nexttile; 
        plot(burstP(i,50:end)); hold on; plot(meanBeta(i,50:end)); 
        clear mask; clear amplitudeData; clear maskedData; 
        clear allBursts; clear toRemove; clear toClean;
    end
    
    %Plot burst count & duration before & after action 
    % Display descriptives
    disp(['Descriptives for ' tt{1} ':'])
    disp(['Mean burst count = '  num2str(mean(meanCount.(tt{1})))]);
    disp(['Mean burst amplitude = ' num2str(mean(meanAmp.(tt{1})))]);
    disp(['Mean burst duration = ' num2str(mean(meanDur.(tt{1}))) ' ms']);

    
    if strcmp(tt{1}, 'selfPaced_all')
        %Plot grand averages over time
        f = figure;
        colororder({'b', 'r'})
        yyaxis left
        stdshade(burstP(:,1:475), 0.15, 'b', '-', [],1);
        set(gca, 'ylim', [0.04,0.14]);
        ylabel('Burst probability');

        yyaxis right

        stdshade(meanBeta(:,1:475), 0.15, 'r','-',[],1);
%         set(gca, 'ylim', [1,1.35]);
        set(gca, 'ylim', [0.9,1.3])
        ylabel('Beta amplitude (au)');
        set(gca, 'XTick', [1,100,200,300,400,450],...
            'XTickLabel', {'-2', '-1.5', '-1', '-0.5', '0', '0.25'}, ...
            'FontSize', 14) ;
%         xlabel('Time (s)'); ylabel('Beta amplitude');
        title('Experiment 1')    
        line([400,400], [0.9,1.35], 'color', 'k');

    end
    
        f.PaperUnits = 'inches';
        f.PaperPosition = [0 0 6.5 5];
        print(f,[exp.figPath, 'FigS1a'],'-dtiffn','-r1200')
    
   clear burstP; clear meanBeta; clear burstCount;

end
end

