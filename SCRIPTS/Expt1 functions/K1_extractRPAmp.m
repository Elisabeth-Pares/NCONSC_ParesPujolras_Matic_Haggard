function [] = K1_extractRPAmp(exp,ch)

load([exp.processedData, 'K1_allP_averagedData.mat'])
exp.timeExtract = [2.4*200:2.5*200]; % extract data from -100 to 0 w.r.t. orange letter. 

exp.nsub = length(exp.sub_selection);

allDat = [];
for sub = exp.sub_selection(1:end)
    dat_aw = mean(AW_allTrials{sub,ch}(exp.timeExtract,:)',2)
    dat_nr = mean(NR_allTrials{sub,ch}(exp.timeExtract,:)',2)
    dat_sp = mean(SP_allTrials{sub,ch}(exp.timeExtract,:)',2)
    
    dat_aw = [repmat((sub), size(dat_aw,1),1), repmat(3, size(dat_aw, 1),1), dat_aw]; %ID, response (3 = AW), RP value
    dat_nr = [repmat((sub), size(dat_nr,1),1), repmat(1, size(dat_nr, 1),1), dat_nr]; %ID, response (1 = NR), RP value
    dat_sp = [repmat((sub), size(dat_sp,1),1), repmat(2, size(dat_sp, 1),1), dat_sp]; %ID, response (2 = SP), RP value
    
    subDat = [dat_aw; dat_nr; dat_sp];
    allDat = [allDat; subDat];
    clear dat_aw; clear dat_nr; clear dat_sp; clear subDat;
end

csvwrite([exp.processedData, 'K1_RPamp_12_forR.csv'], allDat); 
end