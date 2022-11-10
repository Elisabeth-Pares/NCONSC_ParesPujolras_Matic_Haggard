function [] = E3_burstDescription(exper, epoch)

if epoch == 1
    trialType = {'orangeLetter'};
elseif epoch == 2
    trialType = {'selfPaced_all'};
end

for tt = trialType(1:end)
    if strcmp(tt,'selfPaced_all')
        epoch_onset = 1;
        epoch_dur = 699;
    elseif strcmp(tt, 'orangeLetter')
        epoch_onset = 1;
        epoch_dur = 300; %from start to orange letter
    end
    
    load([exper.procPath, 'E3_betaBursts_fullDetails_' tt{1} '_' exper.thisChan '.mat'])
    
    %Mean burst duration
    maxrho = 6; %Based on orange letter epochs
    tiledlayout(4,5)
    for i = 1:length(dat)
%         allBursts = [(dat{1, 8}.burstdur{1, 5}{1:end,1})];
%         %Remove 200's and 0's
%         allBursts(allBursts == 200 | allBursts == 0) = [];
%         
%         meanDur.(tt{1})(i) = mean(allBursts)/200*1000; %In ms
        clear allBursts;
        
        %Mean burst count 
        meanCount.(tt{1})(i) = mean(dat{i}.allTrials{maxrho}.dat(:,1)); 
        %Mean burst amplitude
        %field st_amp_burst acts as a mask for single trial amplitudes st_amp
        amplitudeData = dat{i}.st_amp{1}(epoch_onset:epoch_onset+epoch_dur,:);
        mask = dat{i}.st_amp_burst{1,maxrho};
        maskedData = amplitudeData(mask);
        meanAmp.(tt{1})(i) = mean(maskedData);
        
        %Calculate burst probability and plot over beta amplitude 
        burstP(i,:) = mean(mask,2); %Over trials
        meanBeta(i,:) = mean(amplitudeData,2);
        nexttile; 
        plot(burstP(i,50:end)); hold on; plot(meanBeta(i,50:end)); 
        clear mask; clear amplitudeData; clear maskedData; 
        clear allBursts; clear toRemove;
    end
    
%     %Plot burst count & duration before & after action 
%     % Display descriptives
%     disp(['Descriptives for ' tt{1} ':'])
%     disp(['Mean burst count = '  num2str(mean(meanCount.(tt{1})))]);
%     disp(['Mean burst amplitude = ' num2str(mean(meanAmp.(tt{1})))]);
%     disp(['Mean burst duration = ' num2str(mean(meanDur.(tt{1}))) ' ms']);
    
    if strcmp(tt{1}, 'selfPaced_all')
        %Plot grand averages over time
        f = figure;
        colororder({'b', 'r'});
        yyaxis left
        stdshade(burstP(:,50:650), 0.15, 'b', '-',[],1);
        %     set(gca, 'ylim', [0.07,0.135]);
        ylabel('Burst probability');
        yyaxis right
        stdshade(meanBeta(:,50:650), 0.15, 'r','-', [],1);
        %     set(gca, 'ylim', [1,1.35]);
        set(gca, 'ylim', [1,1.35])
        
        set(gca, 'XTick', [50,150,250,350,450,550,650],...
            'XTickLabel', {'-2', '-1.5', '-1', '-0.5', '0', '0.5', '1'},...
            'FontSize', 14) ;
        xlabel('Time (s)'); ylabel('Beta amplitude (au)');
        title('Experiment 2')
        line([450,450], [1,1.35], 'color', 'k');

        
        f.PaperUnits = 'inches';
        f.PaperPosition = [0 0 6.5 5];
        print(f,[exper.figPath, 'FigS1b'],'-dtiffn','-r1200')
    end
    
   clear burstP; clear meanBeta; clear burstCount;

   
end
end

