function [EEG]  = K1_EEGRecoding(sub,exp, rejectRange) 
% Take the epoched and baselined data and add a recoding column to the triggers

if rejectRange == 8 % If orange letters are rejected when there's movement within 2s before
    
     EEG =  pop_loadset( [exp.filepath 'K1_epochOL8_P' num2str(sub) '.set'] );
     % Load the behavioural file
     recData = readtable([exp.mainpath '/data/behavioural/P' num2str(sub) '/K1_P' num2str(sub) '_rOL.csv']);
     % Make a vector from the recoding column
     recVector = recData.RecodingOL8(~strcmp(recData.RecodingOL8, ''));
     % Add the recoding vector to the EEG file
     EEG = K1_conditionRecoding(EEG, recVector, {'Trigger 1'});
     % Save epochs as OL8
     EEG = pop_saveset( EEG, ['K1_RepochOL8_P' num2str(sub)], exp.filepath);
     
elseif rejectRange == 12
    
     EEG =  pop_loadset( [exp.filepath 'K1_epochOL12_P' num2str(sub) '.set'] );
     % Load the behavioural file
     recData = readtable([exp.mainpath '/data/behavioural/P' num2str(sub) '/K1_P' num2str(sub) '_rOL.csv']);
     % Make a vector from the recoding column
     recVector = recData.RecodingOL12(~strcmp(recData.RecodingOL12, ''));
     % Add the recoding vector to the EEG file
     EEG = K1_conditionRecoding(EEG, recVector, {'Trigger 1'});
     % Save epochs as OL12
     EEG = pop_saveset( EEG, ['K1_RepochOL12_P' num2str(sub)], exp.filepath);
     
end

end