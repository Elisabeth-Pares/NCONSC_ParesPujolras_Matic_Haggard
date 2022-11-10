function [expDuration] = E3_expDuration(exp)

i = 0;
for sub = exp.sub_id(1:end)
    i = i+1;
    EEG = pop_loadset(['E:\PhD - London\E3 - Gradual Awareness\converted data\E3_P' num2str(sub) '.set']);
    
    expDuration(i) = [EEG.event(end).latency - EEG.event(1).latency]/EEG.srate/60;
end
end