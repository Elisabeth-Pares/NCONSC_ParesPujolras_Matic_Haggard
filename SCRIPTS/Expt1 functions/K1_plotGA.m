%Plot grand-averaged RP for selected subjects
function [] = K1_plotGA(exp)

load([exp.processedData, '/K1_allP_averagedData.mat']) %contains data from all 19 participants 
exp.ch = 3 % Select channel CZ;

%Put participant-averaged Cz results in a single matrix for grand-averaging
i = 0;
for id = exp.sub_selection(1:end)
    i = i+1;
    allP{1}(i,:) = AW_av{id,exp.ch}(:);
    allP{2}(i,:) = SP_av{id,exp.ch}(:);
    allP{3}(i,:) = NR_av{id,exp.ch}(:);    
    clear sp_nr; clear sp_aw; clear both_dat;
end

allP_ga_aw = mean(allP{1})
allP_ga_sp = mean(allP{2})
allP_ga_nr = mean(allP{3})

save([exp.processedData, '/K1_allP_averagedData_all.mat'], 'allP') 

%% PLOTS 
%% Plot grand-averages with SEM 
% close all 
load([exp.processedData, '/K1_allP_averagedData_all.mat']) 
f = figure
stdshade(allP{1}(:,1:500), 0.5, [1,0.5,0.25]) %AW
hold on 
stdshade(allP{2}(:,1:500), 0.5, 'b') %SP
hold on 
stdshade(allP{3}(:,1:500), 0.5, 'k') %NR
hold on 

yLimits = get(gca,'YLim');  %# Get the range of the y axi
set(gca, 'YDir', 'reverse', ...
    'XTick', [1,100,200,300,400,500],...
    'XTickLabel', {'-2.5', '-2', '-1.5', '-1', '-0.5', '0'}, 'fontsize', 20)
xlabel('Time (s)'); ylabel('Cz amplitude (uV)');

f.PaperUnits = 'inches';
f.PaperPosition = [0 0 16 8];
print(f,[exp.figPath, 'Fig2b'],'-dtiffn','-r1200')

%% SS plots 
% figure
% tiledlayout(5,4)
% for i = 1:length(exp.sub_selection)
%     nexttile;
%     plot(allP{1}(i,1:500),'r'); 
%     hold on 
%     plot(allP{2}(i,1:500),'b');
%     set(gca, 'YDir', 'reverse'); 
%     title(['ID:' num2str(i)])
% 
% end

    

