function [AW_GA, SP_GA, NR_GA] = K1_getGA(exp,channelIdx) 
%Channel index in numbers

load(['K1_allP_averagedData_12.mat']); % Get file with all data
exp.filepath = ['H:\Postdoc\K1 - LatentAwareness Rep\epochs_180220\orange_letter_longer']
exp.sub_selection = [1,2,3,4,5,7,8,9,12,14,15,16,17,18,19,20,21,22,23];

id = 0;
for  sub = 1:length(exp.sub_selection)
    id = id +1;
    AW_GA_pp(id,:) = AW_av{sub,channelIdx};
%     BOTH_GA_pp(id,:) = BOTH_av{id,channelIdx};
    SP_GA_pp(id,:) = SP_av{sub,channelIdx};
    NR_GA_pp(id,:) = NR_av{sub,channelIdx};
end

AW_GA = mean(AW_GA_pp(sub_sel,:));
% BOTH_GA = mean(BOTH_GA_pp);
SP_GA = mean(SP_GA_pp(sub_sel,:));
NR_GA = mean(NR_GA_pp(sub_sel,:));


%% Plot GA data per channel 
figure
sub_sel = [1:4,7,9:15,18:19];
p = plot(SP_GA); p.LineWidth = 4;
hold on 
p = plot(AW_GA); p.LineWidth = 4;
hold on 
p = plot(NR_GA); p.LineWidth = 4;
hold on 
% p = plot(BOTH_GA); 

rangeBegin = -2.5;
rangeEnd = 0.5;
numberOfXTicks = 7;
xAxisVals = linspace(rangeBegin, rangeEnd, numberOfXTicks);
set(gca,'FontSize', 25, 'XTickLabel',xAxisVals, 'Ydir', 'reverse','ylim', [-5 5], 'xlim', [0 600]);
xlabel(['Time (s)']);ylabel(['EEG amplitude at CZ (uV)']);

p = line([500 500], get(gca, 'ylim'), 'Color', [0 0 0]); p.LineWidth = 2;    % Plot mean 
legend('SP', 'LA', 'NR');

end