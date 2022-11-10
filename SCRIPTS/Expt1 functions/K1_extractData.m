function [EEG] =  K1_extractData(exp, filename, trialType) 

EEG = pop_loadset('filename',filename,'filepath',exp.filepath);

switch trialType
    
    case 'AW'
        
        EEG = pop_selectevent( EEG, 'value',{'orangeResponse_AWkey'},'deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG.setname= ['AW_' filename];
        EEG = pop_saveset( EEG, ['AW_' filename], [exp.analysesdata '/stimulus_locked']);
        
    case 'SP'
        
        EEG = pop_selectevent( EEG, 'value',{'orangeResponse_SPkey'},'deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG.setname= ['SP_' filename];
        EEG = pop_saveset( EEG, ['SP_' filename], [exp.analysesdata '/stimulus_locked']);
        
    case 'NoR'
        
        EEG = pop_selectevent( EEG, 'value',{'orange_noResponse'},'deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG.setname= ['NoR_' filename];
        EEG = pop_saveset( EEG, ['NoR_' filename], [exp.analysesdata '/stimulus_locked']);   
        
    case 'BOTH'
        
        if  any(strcmp(unique({EEG.event.value})', 'orangeResponse_both')) % If there are some both-hand trials
            EEG = pop_selectevent( EEG, 'value',{'orangeResponse_both'},'deleteevents','on','deleteepochs','on','invertepochs','off');
            EEG.setname= ['BOTH_' filename];
            EEG = pop_saveset( EEG, ['BOTH_' filename], [exp.analysesdata '/stimulus_locked']);   
        end            
        
    case 'SPaction'
        
        EEG.setname= ['SPaction_' filename];
        EEG = pop_saveset( EEG, ['SPaction_' filename], [exp.analysesdata '/action_locked']);   

end