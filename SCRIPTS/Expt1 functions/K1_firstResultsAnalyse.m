% Behavioural data first analyses

%% Run behavioural recoding for all participants for different rejection ranges

for sub = [16, 17]
    expData = K1_importBehavioural(exp,sub);
    expData = compareOLrecoding(exp, expData, sub);  
end

%% Import all behavioural data first
for sub = sub_id
    data(sub).OL12 = readtable(fullfile(exp.mainpath, '/data/behavioural/',['P' num2str(sub)], ['K1_P' num2str(sub) '_rOL.csv']));
end

%%

for range = [8 12 ]
    
    for sub = [1:5 7:17]
        
    % Import data file first
    data = readtable(fullfile(exp.mainpath, '/data/behavioural/',['P' num2str(sub)], ['K1_P' num2str(sub) '_rOL' num2str(range) '.csv']));
    
    % Take only the counts
    
    if range == 0
        counts_0.reject(sub) = length(find(strcmp(data.RecodingOL, 'orange_reject')));
        counts_0.noResponse(sub) = length(find(strcmp(data.RecodingOL, 'orange_noResponse')));
        counts_0.SPresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_SPkey')));
        counts_0.AWresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_AWkey'))); 
        
    elseif range == 6
        counts_6.reject(sub) = length(find(strcmp(data.RecodingOL, 'orange_reject')));
        counts_6.noResponse(sub) = length(find(strcmp(data.RecodingOL, 'orange_noResponse')));
        counts_6.SPresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_SPkey')));
        counts_6.AWresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_AWkey'))); 

    elseif range == 8
        counts_8.reject(sub) = length(find(strcmp(data.RecodingOL, 'orange_reject')));
        counts_8.noResponse(sub) = length(find(strcmp(data.RecodingOL, 'orange_noResponse')));
        counts_8.SPresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_SPkey')));
        counts_8.AWresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_AWkey')));
        
    elseif range == 10
        counts_10.reject(sub) = length(find(strcmp(data.RecodingOL, 'orange_reject')));
        counts_10.noResponse(sub) = length(find(strcmp(data.RecodingOL, 'orange_noResponse')));
        counts_10.SPresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_SPkey')));
        counts_10.AWresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_AWkey')));
        
    elseif range == 12
        counts_12.reject(sub) = length(find(strcmp(data.RecodingOL, 'orange_reject')));
        counts_12.noResponse(sub) = length(find(strcmp(data.RecodingOL, 'orange_noResponse')));
        counts_12.SPresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_SPkey')));
        counts_12.AWresponse(sub) = length(find(strcmp(data.RecodingOL, 'orangeResponse_AWkey')));
        
    end
    
    end
    
end

% counts_0 = table(counts_0.reject, counts_0.noResponse, counts_0.SPresponse, counts_0.AWresponse);
%  writetable(counts_0, fullfile(exp.mainpath, '/results/behavioural/firstAnalysis/countsOL0.csv'))
%  
% counts_6 = table(counts_6.reject, counts_6.noResponse, counts_6.SPresponse, counts_6.AWresponse);
% writetable(counts_6, fullfile(exp.mainpath, '/results/behavioural/firstAnalysis/countsOL6.csv'))

counts_8 = table(counts_8.reject', counts_8.noResponse', counts_8.SPresponse', counts_8.AWresponse');
 writetable(counts_8, fullfile(exp.mainpath, '/results/behavioural/firstAnalysis/countsOL8.csv'))
 
% counts_10 = table(counts_10.reject, counts_10.noResponse, counts_10.SPresponse, counts_10.AWresponse);
% writetable(counts_10, fullfile(exp.mainpath, '/results/behavioural/firstAnalysis/countsOL10.csv'));

counts_12 = table(counts_12.reject', counts_12.noResponse', counts_12.SPresponse', counts_12.AWresponse');
writetable(counts_12, fullfile(exp.mainpath, '/results/behavioural/firstAnalysis/countsOL12.csv'));
    
%% Plot

for sub = sub_id
    
    values = [counts_8.Var2(sub), counts_8.Var3(sub) counts_8.Var4(sub);...
        counts_12.Var2(sub) counts_12.Var3(sub) counts_12.Var4(sub);];
        subplot(4, 4, sub)
        bar(values, 1.0, 'grouped','LineWidth',6.0, 'EdgeColor', [1 1 1])
        set(gca, 'xticklabel', {'8 rejected', '12 rejected'}, 'fontsize', 12)
        title(['Subject ' num2str(sub)])
       
end

subplot(311)
bar([counts_8.Var2' counts_12.Var2'], 1.0, 'grouped', 'LineWidth', 3.0, 'EdgeColor', [1 1 1])
plot(0,15)
title('No awareness trials')

subplot(312)
bar([counts_8.Var3' counts_12.Var3'], 1.0, 'grouped', 'LineWidth', 3.0, 'EdgeColor', [1 1 1])
hold on
title('SP response')

subplot(313)
bar([counts_8.Var4' counts_12.Var4'], 1.0, 'grouped', 'LineWidth', 3.0, 'EdgeColor', [1 1 1])
hold on
title('AW response')
