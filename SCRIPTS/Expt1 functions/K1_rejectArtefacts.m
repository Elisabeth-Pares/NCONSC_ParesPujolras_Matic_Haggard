function [EEG]  = K1_rejectArtefacts(sub,exp)  

% Artefact rejection - stimulus locked epochs
EEG = pop_loadset([exp.filepath 'K1_RepochOL8_P' num2str(sub) '.set']);
[EEG arej] = pop_eegthresh(EEG,1,exp.actionChans , -120, 120, -2.5, 0.5, 0,1);
EEG.arej = arej;
EEG = pop_saveset( EEG, ['K1_aRepochOL8_P' num2str(sub)], exp.filepath);

EEG = pop_loadset([exp.filepath 'K1_RepochOL12_P' num2str(sub) '.set']);
[EEG arej] = pop_eegthresh(EEG,1,exp.actionChans , -120, 120, -2.5, 0.5, 0,1);
EEG.arej = arej;
EEG = pop_saveset( EEG, ['K1_aRepochOL12_P' num2str(sub)], exp.filepath);

% Action locked epochs
EEG = pop_loadset([exp.filepath 'bSP_eICA_cdfrK1_P' num2str(sub) '.set']);
[EEG arej] = pop_eegthresh(EEG,1,exp.actionChans , -120, 120, -2.5, 0.5, 0,1);
EEG.arej = arej;
EEG = pop_saveset( EEG, ['K1_aepochSP_P' num2str(sub)], exp.filepath);

end

