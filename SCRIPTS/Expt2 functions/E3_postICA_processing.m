function [] = E3_postICA_processing(exp,sub)
%INPUT: cICA_bodfrE3_PX.set file - file saved after manual ICA correction
%OUTPUT: annotated file with behaviour (ratings & exclusions), and artefact rejected.

for e = 1:length(exp.epochs)
    % Load file
    EEG = pop_loadset(['cICA_b' exp.epochLabel{e} 'dfrE3_P' num2str(sub) '.set'], exp.filepath);
    
    % Recoding of trials
    load([exp.behPath, 'E3_P' num2str(sub) '_recoding_rej' num2str(exp.kpe)]);
    for i = 1:length(EEG.epoch)
        EEG.epoch(i).eventtype = all_recoding_all(i);
    end
    o = 0;
    for i = 1:length(EEG.event)
        if strcmp(EEG.event(i).type, 'Trigger 1')
            o = o+1;
            EEG.event(i).value= all_recoding_all{o};
        end
    end
    EEG = pop_saveset( EEG, ['rec_kprej' num2str(exp.kpe) '_cICA' exp.epochLabel{e} 'odfrE3_P' num2str(sub)], exp.filepath);
    
    % Artefact rejection
    [EEG, EEG.arindx] = pop_eegthresh(EEG,1, exp.chans,-120,120,-1.5,1,0,1);
    EEG = pop_saveset( EEG, ['rec_kprej' num2str(exp.kpe) '_acICA' exp.epochLabel{e} 'odfrE3_P' num2str(sub)], exp.filepath);
    
end
end