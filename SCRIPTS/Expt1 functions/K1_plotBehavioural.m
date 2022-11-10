function K1_plotBehavioural(behData)

%% Total numbers
figure
labels = {'Orange total', 'Orange - SP', 'Orange - AW', 'Self paced'};
bar(behData',1.0, 'grouped', 'LineWidth',6.0, 'EdgeColor', [1 1 1]);
set(gca, 'xticklabel', labels, 'fontsize', 22)
title('Total counts')

% % Totals for participant
% figure(1)
% 
% orange_total = length(find(expData.blackOrange == 1));
% orange_SPresponse = length(find(strcmp(expData.Recoding, 'orangeResponse_SPkey')));
% orange_AWresponse = length(find(strcmp(expData.Recoding, 'orangeResponse_AWkey')));
% selfPaced_SP = length(find(strcmp(expData.Recoding, 'selfPaced_SPkey')));
% selfPaced_AW = length(find(strcmp(expData.Recoding, 'selfPaced_AWkey')));
% 
% totals = [orange_total, orange_SPresponse, orange_AWresponse, selfPaced_SP, selfPaced_AW];
% labels = {'Orange total', 'Orange - SP', 'Orange - AW', 'Self paced', 'Self Paced - AW'};
%     
% thisPlot = bar(totals, 1.0, 'LineWidth',2.0);
% set(gca, 'xticklabel', labels, 'fontsize', 12)
% title(['Subject ' num2str(sub)])

% Waiting times between SP presses

end
