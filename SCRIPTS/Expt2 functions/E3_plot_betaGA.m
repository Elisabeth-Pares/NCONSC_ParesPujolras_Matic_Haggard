function [] = E3_plot_betaGA(exp,dat)
%% Plot trial-averaged beta amplitude  
all_spampst = [];
for i = 1:length(exp.sub_id)
    all_spampst = [all_spampst; dat{1,i}.st_amp{1}'];
    all_spamp{i} = dat{1,i}.st_amp{1};
    all_sptf{i} = mean(dat{1,i}.st_tf{1},3);
end

%% Pooled across subjects 
figure 
stdshade(all_spampst(:,30:670), 0.5, 'b')
hold on 
yLimits = get(gca,'YLim');  %# Get the range of the y axi
line([500,500], [yLimits], 'color', 'k');
set(gca, 'XTick', [1,100,200,300,400,500,600,700],...
    'XTickLabel', {'-2.5', '-2', '-1.5', '-1', '-0.5', '0', '0.5', '1'})
 xlabel('Time (s)'); ylabel('Beta amplitude');
 
 %% For one subject 
sub = 1

xTick = [100,300,500]; 
edgeCorrect = 50;

figure 
colormap('jet')
subplot(1,2,1)
%stdshade(all_spampst(:,30:670), 0.5, 'b') pooled across subjects 
stdshade(all_spamp{1}(50:650,:)', 0.5, 'r')
hold on 
yLimits = get(gca,'YLim');  %# Get the range of the y axi
line([450,450], [yLimits], 'color', 'k');
set(gca, 'XTick', xTick-edgeCorrect,...
   'XTickLabel', {'-2', '-1', '0'},...
    'XLim', [0,600], 'FontSize', 12)
 xlabel('Time (s)'); ylabel('Beta amplitude');

 subplot(1,2,2)
contourf(50:650,frex,all_sptf{sub}(:,50:650),40,'linecolor','none')
yLimits = get(gca,'YLim');  %# Get the range of the y axi
line([450,450], [yLimits], 'color', 'k');
hold on
set(gca, 'XTick', xTick-edgeCorrect,...
   'XTickLabel', {'-2', '-1', '0'},...
    'XLim', [50,650], 'FontSize', 12)
 xlabel('Time (s)'); ylabel('Hz');
colorbar
