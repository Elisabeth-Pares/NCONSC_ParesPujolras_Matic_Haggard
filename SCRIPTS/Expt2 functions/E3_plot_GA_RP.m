function [] = E3_plot_GA_RP(exp, thisChan)

load(['E3_allP' num2str(exp.kpe) '_n' num2str(length(exp.sub_id)) 'morletCycles_' num2str(exp.morletCycles) '_singleTrial_EEG_BehData_betaBursts_' thisChan]);

avData = cellfun(@nanmean,allP_singleTrial,'un',0) % average all single trials
sizeData = cellfun(@size,avData, 'un',0) % get size to detect cells where there was a single trial

for i = 1:17  % remove false averages                  
    for j = 1:8 % not 9, because 9 is post letter KP
        a = sizeData{i,j} == [1,1];
        if a(2) == 1
            avData{i,j} = allP_singleTrial{i,j}
        end
    end
end

% Grand average across participants 
for i = 1:8
gaData{i} = (nanmean(cat(1,avData{:,i}),1))  % average 
end

% plot 
f = figure 
 set(gca,'FontSize', 12, 'xlim', [-3,0]);
    
for i = 1:8
    plot(gaData{1,i}(1:300),'LineWidth', 2);
    hold on 
end

set(gca, 'FontSize', 12)
set(gca,'Ydir','reverse')
set(0,'DefaultAxesColorOrder',hot(15))'
xlabel('Time (s)');ylabel('EEG amplitude at Cz (uV)');
ax = gca;
ax.XTick = [1,100,200,300];
ax.XTickLabel = ({'-1.5','-1','-0.5','0'});


f.PaperUnits = 'inches';
f.PaperPosition = [0 0 5.166 2.583];
print(f,[exp.figPath, 'Fig3a'],'-dtiffn','-r1200')

end
