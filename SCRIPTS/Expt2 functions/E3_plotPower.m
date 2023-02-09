function [] = E3_plotPower(exper)

%%
id = 0;
for sub = exper.sub_id(1:end)
    disp(num2str(sub)); %display participant ID
    id = id +1;
    rating = [];
    %Load EEG data
    EEG = pop_loadset(['F:/PhD - London/E3 - Gradual Awareness/april2019/Frec_kprej' num2str(exper.kpe) '_acICAabodfrE3_P' num2str(sub) '.set']);
    % Load behavioural data
    load(['F:/PhD - London/E3 - Gradual Awareness/april2019/E3_P' num2str(sub) '_behavioural_results_kpe' num2str(exper.kpe) 'rejected']);
    %Load TF data
    load('E3_betaBursts_fullDetails_orangeLetter_CZ.mat')
    
    %Reject artefact rejected trials
    idx = find(EEG.reject.rejthresh);
    for i = idx(1:end)
      all_recoding_all{i,1} = [];
    end
    all_recoding_all =  all_recoding_all(~cellfun('isempty',all_recoding_all));
    
    EEG.coding = all_recoding_all; 
    for i = 1:height(EEG.coding)
        thisVal = EEG.coding(i);
        if ~isempty(str2num(thisVal{1}))
            rating(i,1) = str2num(thisVal{1});
        else
            rating(i,1) = NaN;
        end
    end
   
    subMean = nanmean(rating);
    rating(rating(:,1)>subMean,2) = 1; %High
    rating(rating(:,1)<=subMean,2) =0; %Low
    rating(isnan(rating(:,1)),2) = NaN; 
    
    allPower.high(:,:,id) = nanmean(dat{1,id}.st_tf{1}(:,:,rating(:,2) == 1),3);
    allPower.low(:,:,id) = nanmean(dat{1,id}.st_tf{1}(:,:,rating(:,2) == 0),3);

    disp(['P' num2str(id) '#Low: ' num2str(sum(rating(:,2) == 0)) , ', #High: ' num2str(sum(rating(:,2) == 1))]);
    clear subMean; clear rating; clear EEG; clear idx; 
end

%% Plot contour plots with low vs. high readiness ratings 

% close all 
f = figure

%Plotting parameters
xTick = [100,200,300]; 
xLabels = {'-1','-0.5','0'}

colormap('jet');
subplot(1,2,1)
contourf(50:300,exp.frex(1:end),allPower.low(1:end,50:300),34,'linecolor','none');
set(gca, 'XTick', xTick, 'XTickLabel', xLabels,...
    'XLim', [50,300]);
% title(['Low ratings']);
xlabel('Time (s)')
ylabel('Hz')
caxis([2,10])
set(gca, 'FontSize', 19)

subplot(1,2,2)
contourf(50:300,exp.frex(1:end),allPower.high(1:end,50:300),34,'linecolor','none');
set(gca, 'XTick', xTick, 'XTickLabel', xLabels,...
    'XLim', [50,300]);
% title(['High ratings']);
xlabel('Time (s)')
ylabel('Hz')
caxis([2,10])
% colorbar;
set(gca, 'FontSize', 19)

f.PaperUnits = 'inches';
f.PaperPosition = [0 0 12 5];
print(f,[exper.figPath, 'Fig3f'],'-dtiffn','-r1200')





end