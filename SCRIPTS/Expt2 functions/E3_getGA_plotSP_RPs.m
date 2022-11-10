function [] = E3_getGA_plotSP_RPs(exp) 

%Put all SP data in a single file 
exp.sub_selection = [4,5,6,7,8,10,11,12,13,14,15,16,17,18,19,20,21];
i = 0;
for sub = exp.sub_selection(1:end)
    i = i+1;
    EEG = pop_loadset(['E:/PhD - London/E3 - Gradual Awareness/april2019/abadfrE3_P' num2str(sub) '.set'])
    SP_action_av{i} = mean(EEG.data(:,:,:), 3)
    SP_action{i} = (EEG.data(:,:,:))
end
% save([exp.procPath, 'E3_actionLocked_allP'], 'SP_action')


%% Tiled layout - subplot channel 3 for each participant
figure
t = tiledlayout('flow')
ch = 3;
for i = 1:length(exp.sub_selection)
nexttile;
% subplot(5,4,i)
%plot(SP_action{i}(c,:,:)); p.LineWidth = 2;
if (i == 8)
    p = stdshade(squeeze(SP_action{i}(ch,:,:))', 0.5,'r'); p.LineWidth = 2;
else
    p = stdshade(squeeze(SP_action{i}(ch,:,:))', 0.5,'b'); p.LineWidth = 2;
end
yline(0, 'LineWidth', 2) %, get(gca, 'ylim'), 'Color', [0 0 0]); p.LineWidth = 2;    % Plot mean 

rangeBegin = -2.5;
rangeEnd = 0.5;
numberOfXTicks = 7;
xTicks = [100,300,500,600,700];
xticks(xTicks);
xAxisVals = [-2,-1,0,0.5,1];
set(gca,'FontSize', 9, 'XTickLabel',xAxisVals, 'Ydir', 'reverse','ylim', [-20 10], 'xlim', [0 700]);
line([500 500], get(gca, 'ylim'), 'Color', [0 0 0]); p.LineWidth = 2;    % Plot mean
title(['ID = ' num2str(i)])


% Fit linear regression for exclusion criterion 
x = [1:500];
y = mean(SP_action{i}(ch,1:500,:),3);
c = polyfit(x,y,1);
y_est = polyval(c,x);

% Display evaluated equation y = m*x + b
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
hold on
plot(x,y_est, 'r--')

%Mean amplitude 100ms before action
meanAmp(i) = mean(mean(SP_action{i}(ch,400:500,:),2), 3); 
disp(['MeanAmp is = ' num2str(meanAmp(i))])

%Decrease of 1uv over 2 seconds?
[~, idx] = min(mean(SP_action{i}(ch,480:500,:),3));
decrease(i) = mean(mean(SP_action{i}(ch,(idx-5+480):(idx+480+5),:),2),3) - mean(mean(SP_action{i}(ch,100:110,:),2),3);
disp(['MeanDecrease:' num2str(decrease(i))]); 

end

title(t,'Experiment 2 readiness potentials')
xlabel(t, 'Time (s)');
ylabel(t,['EEG amplitude at Cz (uV)']);

exportgraphics(t,[exp.figPath, 'FigS5.tiff'])


