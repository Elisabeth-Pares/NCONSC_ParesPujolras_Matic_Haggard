%% K1 - create a separate file for each condition

% for sub = exp.sub_selection(1:end)
%     filename = ['K1_aRepochOL12_P' num2str(sub) '.set'];
%     
%     % Awareness report
%     EEG = pop_loadset('filename',filename,'filepath',exp.filepath);
%     EEG = pop_selectevent( EEG, 'type',{'Trigger 1'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG = pop_selectevent( EEG, 'value',{'orangeResponse_AWkey'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG.setname= ['AW_OSF_aRepochOL12_P' num2str(sub)];
%     EEG = pop_saveset( EEG, ['AW_OSF_aRepochOL12_P' num2str(sub)], exp.filepath);
%     
%     % Self-paced movement
%     EEG = pop_loadset('filename',filename,'filepath',exp.filepath);
%     EEG = pop_selectevent( EEG, 'type',{'Trigger 1'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG = pop_selectevent( EEG, 'value',{'orangeResponse_SPkey'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG.setname= ['SP_OSF_aRepochOL12_P' num2str(sub)];
%     EEG = pop_saveset( EEG, ['SP_OSF_aRepochOL12_P' num2str(sub)], exp.filepath);
%     
%     % No response
%     EEG = pop_loadset('filename',filename,'filepath',exp.filepath);
%     EEG = pop_selectevent( EEG, 'type',{'Trigger 1'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG = pop_selectevent( EEG, 'value',{'orange_noResponse'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%     EEG.setname= ['NR_OSF_aRepochOL12_P' num2str(sub)];
%     EEG = pop_saveset( EEG, ['NR_OSF_aRepochOL12_P' num2str(sub)], exp.filepath);
%     
%     % Both
%     EEG = pop_loadset('filename',filename,'filepath',exp.filepath);
%     if ~isempty(find(cell2mat(cellfun(@(c)strcmp(c,'orangeResponse_both'),{EEG.event.value},'UniformOutput',false))))
%         EEG = pop_selectevent( EEG, 'value',{'orangeResponse_both'},'deleteevents','on','deleteepochs','on','invertepochs','off');
%         EEG.setname= ['BOTH_OSF_aRepochOL12_P' num2str(sub)];
%         EEG = pop_saveset( EEG, ['BOTH_OSF_aRepochOL12_P' num2str(sub)], exp.filepath);
%     end
% end


%% Put in a single file
%% Requires loading all datasets manually on EEGlab
%Input
exp.filepath = ['E:\Postdoc\K1 - LatentAwareness Rep\epochs_180220\orange_letter_longer']
exp.nsub = length(exp.sub_id);
% 
% for i = 1:57
% %      figure; plot(squeeze(mean(ALLEEG(i).data(3,:,:)))); 
%      ALLEEG(i) = pop_eegfiltnew(ALLEEG(i), 'locutoff',3.8,'hicutoff',4.2,'revfilt',1,'plotfreqz',1);
%      ALLEEG(i) = eeg_checkset( ALLEEG(i) );
%      ALLEEG(i) = pop_eegfiltnew(ALLEEG(i), 'locutoff',7.8,'hicutoff',8.2,'revfilt',1,'plotfreqz',1);
%      ALLEEG(i) = eeg_checkset( ALLEEG(i) );
%      ALLEEG(i) = pop_eegfiltnew(ALLEEG(i), 'locutoff',15.8,'hicutoff',16.2,'revfilt',1,'plotfreqz',1);
%      ALLEEG(i) = eeg_checkset( ALLEEG(i) );
% %      hold on; plot(squeeze(mean(ALLEEG(i).data(3,:,:)))); 
% end
id = 0;
for sub = 1:exp.nsub
    id = id + 1;
    for ch = 1:EEG.nbchan
        AW_allTrials{id,ch,1} = squeeze(ALLEEG(sub).data(ch,:,:));
        ntrials_AW = size(ALLEEG(sub).data)
        AW_av{id,ch} = mean(AW_allTrials{id,ch},2);
    end
    
    ntrials_all(id,1) = ntrials_AW(3)
end

id = 0;
for sub = (exp.nsub+1):2*exp.nsub
    id = id + 1;
    for ch = 1:EEG.nbchan
        NR_allTrials{id,ch,1} = squeeze(ALLEEG(sub).data(ch,:,:));
        ntrials_NR = size(ALLEEG(sub).data)
        NR_av{id,ch} = mean(NR_allTrials{id,ch},2);
    end
    ntrials_all(id,2) = ntrials_NR(3)
end

id = 0;
for sub = ((2*exp.nsub)+1):(3*exp.nsub)
    id = id + 1;
    for ch = 1:EEG.nbchan
        SP_allTrials{id,ch,1} = squeeze(ALLEEG(sub).data(ch,:,:));
        ntrials_SP = size(ALLEEG(sub).data)
        SP_av{id,ch} = mean(SP_allTrials{id,ch},2);
    end
    ntrials_all(id,3) = ntrials_SP(3);
end

save([exp.processedData, 'K1_allP_averagedData'], 'AW_av', 'SP_av', 'NR_av', 'ntrials_all',...
 'AW_allTrials', 'SP_allTrials', 'NR_allTrials');

