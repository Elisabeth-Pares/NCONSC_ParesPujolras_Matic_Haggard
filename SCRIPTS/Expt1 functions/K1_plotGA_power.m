function [] = K1_plotGA_power(exper)
load(['K1_betaWavelets_OSF_morletCycles_7_orangeLetter_CZ.mat'], 'dat');

%Plotting parameters
xTick = [100,200,300,400,500]; 
xLabels = {'-2','-1.5','-1', '-0.5', '0'}
% frequency parameters
min_freq =  13;
max_freq = 30;
num_frex = 34;
frex = linspace(min_freq,max_freq,num_frex);

%% Grand-averaged Beta power 
close all 

%Data are structured as: 1-AW, 2-NR, 3-SP; see K1_morletWavelet function.
allP_AW = []; allP_NR = []; allP_SP = [];
for sub = 1:length(exper.sub_selection)
    thisData = dat{1,sub};
    if sub == 1
        allP_AW = [thisData.tf{1}];
        allP_NR = [thisData.tf{2}];
        allP_SP = [thisData.tf{3}];
    else
        allP_AW = [allP_AW + thisData.tf{1}];
        allP_NR = [allP_NR + thisData.tf{2}];
        allP_SP = [allP_SP + thisData.tf{3}];
    end
end

allP_AW_ga = allP_AW/length(exper.sub_selection);
allP_NR_ga = allP_NR/length(exper.sub_selection);
allP_SP_ga = allP_SP/length(exper.sub_selection);

%% Plot
close all 
f = figure
colormap('jet');
subplot(1,3,1)
contourf(50:500,frex(3:end),allP_NR_ga(3:end,50:500),40,'linecolor','none');
set(gca, 'XTick', xTick, 'XTickLabel', xLabels,...
    'XLim', [50,500]);
title(['No Response']);
xlabel('Time (s)')
ylabel('Hz')
colorlimits = caxis;
set(gca, 'FontSize', 16)

subplot(1,3,2)
contourf(50:500,frex(3:end),allP_SP_ga(3:end,50:500),40,'linecolor','none');
set(gca, 'XTick', xTick, 'XTickLabel', xLabels,...
    'XLim', [50,500]);
title(['Unaware']);
xlabel('Time (s)')
ylabel('Hz')
caxis(colorlimits);
set(gca, 'FontSize', 16)
    
subplot(1,3,3)
contourf(50:500,frex(3:end),allP_AW_ga(3:end,50:500),40,'linecolor','none');
set(gca, 'XTick', xTick, 'XTickLabel', xLabels,...
    'XLim', [50,500]);
xlabel('Time (s)')
ylabel('Hz')
title(['Aware']);
%colorbar
caxis(colorlimits);

set(gca, 'FontSize', 16)
f.PaperUnits = 'inches';
f.PaperPosition = [0 0 16 5];
print(f,[exper.figPath, 'Fig2g'],'-dtiffn','-r1200')



