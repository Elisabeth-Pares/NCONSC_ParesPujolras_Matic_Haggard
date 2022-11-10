function [] = K1_plotTopography(EEG, times, trialType,exp) 

ga_dat = mean(EEG.data,3);

chanIdx = [1:26]; %EEG channels; exclude VEOG & HEOG
label = {trialType};

f = figure
chans = [1,2,3];
plot(1:600,ga_dat(chans,:), 'LineWidth', 1.5);
legend(EEG.chanlocs(chans).labels, ...
    'location', 'northwest', 'AutoUpdate','off')


ax = gca;
ax.YDir = 'reverse'
ylabel('Voltage (uV)')
xlabel('Time (s)')
ylim = [-10,2];
title(label{1});
line([500 500], ylim, 'LineWidth', 0.5, 'Color', 'k');
%line([500 500], ylim, 'LineStyle', '--', 'Color', 'k');
xTicks = [0 100 200 300 400 500 600];
set(gca, 'XTick', xTicks, ...
    'XTickLabel', [-2.5 -2 -1.5 -1 -0.5 0 0.5],...
    'ylim', ylim,...
    'fontsize', 8)

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
    colorlimits = [-3 3];
    if i == length(times)
        colorbar
        caxis(colorlimits)
    end
    set(gca, 'fontsize', 8)
end

set(gcf, 'PaperUnits', 'centimeters');
%x_width=12 ;y_width=5.5;
x_width=16 ;y_width=8;
set(gca, 'fontsize', 8); %
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
saveas(gcf,[exp.figPath, 'FigS6a.emf'])

