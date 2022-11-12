function [] = E3_plotTopography(EEG, times, trialType,exp)

ga_dat = nanmean(EEG.data,3);

chanIdx = [1:26];
label = {trialType}
%% 

f = figure('Position', [25,25,600,300])
chans = [1,7,3];

plot(1:600,ga_dat(chans,1:600), 'LineWidth', 1.5);
l = legend(EEG.chanlocs(chans).labels, ...
    'location', 'northwest', 'AutoUpdate','off')
legend('boxoff');


ax = gca;
ax.YDir = 'reverse'
ylabel('Voltage (uV)')
xlabel('Time (s)')
ylim = [-15,2];
line([500 500], ylim, 'LineWidth', 0.5, 'Color', 'k');
xTicks = [0 100 200 300 400 500 600];
set(gca, 'XTick', xTicks, ...
    'XTickLabel', [-2.5 -2 -1.5 -1 -0.5 0 0.5],...
    'ylim', ylim,...
    'fontsize', 8)
title(label{1}, 'fontsize', 12);


% create smaller axes in top right, and plot on it
axes('Position',[.65 .65 .25 .25])
box on

i = 0;
for t = times(1:end)
    i = i+1;
    %subplot(1,length(times),i)
    time_dat = ga_dat(:,EEG.times == t*1000);
    topoplot(time_dat(chanIdx),EEG.chanlocs(chanIdx), ...
        'emarker', {'.','k',[5],1});
    colorlimits = [-6 5];
    if i == length(times)
        colorbar
        caxis(colorlimits)
    end
    set(gca, 'fontsize', 8)
end

exportgraphics(f,[exp.figPath, 'FigS6b.tiff'], 'Resolution', 600)

% saveas(gcf,['E3_topoplot_' label{1} '.emf'])
end