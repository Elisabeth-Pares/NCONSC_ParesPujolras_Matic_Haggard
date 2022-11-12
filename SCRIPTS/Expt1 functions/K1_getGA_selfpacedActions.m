function [] = K1_getGA_selfpacedAction(exp) 

%Put all SP data in a single file 
i = 0;
for sub = exp.sub_id(1:end)
    i = i+1;
    EEG = pop_loadset(['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/action_locked/SPaction_K1_aepochSP_P' num2str(sub) '.set'])
    SP_action_av{i} = mean(EEG.data(:,:,:), 3)
    SP_action{i} = (EEG.data(:,:,:))
end
save([exp.processedData, 'K1_actionLocked_allP'], 'SP_action')


%% Tiled layout - subplot channel 3 for each participant
load([exp.processedData, 'K1_actionLocked_allP'], 'SP_action')
%%
figure('Position', [25,25,750,750])
t = tiledlayout('flow')
ch = 3;

for i = 1:length(exp.sub_id)
nexttile;
if i == 6
    p = stdshade(squeeze(SP_action{i}(ch,:,:))', 0.5,'r'); p.LineWidth = 2;
else
    p = stdshade(squeeze(SP_action{i}(ch,:,:))', 0.5,'b'); p.LineWidth = 2;
end
yline(0, 'LineWidth', 2) %, get(gca, 'ylim'), 'Color', [0 0 0]); p.LineWidth = 2;    % Plot mean 

% Fit linear regression for exclusion criterion
x = [100:500];
y = mean(SP_action{i}(ch,100:500,:),3);
c = polyfit(x,y,1);
y_est = polyval(c,x);

% Display evaluated equation y = m*x + b
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
hold on
plot(x,y_est, 'r--')

rangeBegin = -2.5;
rangeEnd = 0.5;
numberOfXTicks = 7;
xTicks = [100,300,500,600];
xticks(xTicks);
xAxisVals = [-2,-1,0,0.5];
set(gca,'FontSize', 9, 'XTickLabel',xAxisVals, 'Ydir', 'reverse','ylim', [-12 10], 'xlim', [0 600]);
line([500 500], get(gca, 'ylim'), 'Color', [0 0 0]); p.LineWidth = 2;    % Plot mean
title(['ID = ' num2str(i)])

%Decrease of 1uv over 2 seconds?
%Find peak negativity 
[~, idx] = min(mean(SP_action{i}(ch,480:500,:),3));
decrease(i) = mean(mean(SP_action{i}(ch,(idx-5+480):(idx+480+5),:),2),3) - mean(mean(SP_action{i}(ch,100:110,:),2),3);
disp(['MeanDecrease:' num2str(decrease(i))]); 
clear idx; 

end

title(t, 'Experiment 1 readiness potentials')
xlabel(t, 'Time (s)');
ylabel(t,['EEG amplitude at Cz (uV)']);

exportgraphics(t,[exp.figPath, 'FigS4.tiff'], 'Resolution', 600)

end
