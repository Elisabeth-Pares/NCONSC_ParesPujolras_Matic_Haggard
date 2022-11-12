function [] = K1_rtExtract(exp,whichEpoch)


allRT = []; urEvents = [];
        switch whichEpoch  
            case 'orangeLetter'
                conditions = 1:3;  conditionLabels = {'AW', 'NR', 'SP'};
                exper.wd = ['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/orange_letter_longer/'];

            case 'selfPaced' 
                conditions = 1; conditionLabels = {'SelfPaced'};
                exper.wd = ['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/action_locked/'];
        end
        
        for sub = exp.sub_id(1:end)
                for c = 1:length(conditions)
                   
                    conditionLabel = conditionLabels{c};
                    if strcmp(whichEpoch, 'orangeLetter')
                        EEG = pop_loadset([exper.wd conditionLabel '_OSF_aRepochOL12_P' num2str(sub) '.set']);
                    elseif strcmp(whichEpoch, 'selfPaced')
                        EEG = pop_loadset([exper.wd 'SPaction_K1_aepochSP_P' num2str(sub) '.set']);
                    end
                   
                    urEvents = [EEG.event.urevent]; %Trials to select in raw data
                    if c ~= 2
                       %Load raw data
                       EEG = pop_loadset(['E:\Postdoc\K1 - LatentAwareness Rep\OLD\EEG Data\continuous data\K1_P' num2str(sub) '.set']); %PATH TO RAW data
                       %Select events of interest 
                       for t = 1:length(urEvents)
                           thisOL = [EEG.event([EEG.event.urevent] == urEvents(t)).latency];
                           if (c == 1 & strcmp([EEG.event([EEG.event.urevent] == urEvents(t)+1).type], 'Trigger 3')) || ...
                               (c == 3 & strcmp([EEG.event([EEG.event.urevent] == urEvents(t)+1).type], 'Trigger 4')) || ...
                               (c == 3 & strcmp([EEG.event([EEG.event.urevent] == urEvents(t)+1).type], 'Trigger 2'))
                               thisMov = [EEG.event([EEG.event.urevent] == urEvents(t)+1).latency];
                               thisRT = ((thisMov-thisOL)/EEG.srate);
                           else
                               warning('No resp trigger!')
                               thisRT = 999;
                           end
                           condRT(t,:) = [sub, c, thisRT];
                           clear thisOL; clear thisMov; clear thisRT; 
                       end
                    else
                         for t = 1:length(urEvents)
                             condRT(t,:) = [sub, c, 999];
                         end
                    end
                    allRT = [allRT; condRT];
                    clear condRT; clear urEvents;
                end
                
        end
        rtData = array2table(allRT); 
        rtData.Properties.VariableNames = {'id', 'cond', 'rt'}
        writetable(rtData,[exp.processedData, 'Exp1_RTdata_test.csv']);
end
