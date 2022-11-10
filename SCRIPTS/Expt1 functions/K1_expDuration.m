function [expDuration] = K1_expDuration(exp)

i = 0;
for sub = exp.sub_id(1:end)
    i = i+1;
    EEG = pop_loadset(['E:\Postdoc\K1 - LatentAwareness Rep\OLD\EEG Data\continuous data\K1_P' num2str(sub) '.set']); %PATH TO RAW data
    
    expDuration(i) = [EEG.event(end).latency - EEG.event(1).latency]/EEG.srate/60;
end
end