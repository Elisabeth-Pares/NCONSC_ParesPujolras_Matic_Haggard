%% K1 Cluster analysis

function [] = K1_RP_clusterAnalysis(exp)
exp.ch = 3; %select channel Cz as channel of interest
%Generated from K1_plotGA
load([exp.processedData 'K1_allP_averagedData_all.mat']) %contains data from participant subset

% Prepare data format
id = 0;
for sub = 1:length(exp.sub_selection)
    
    id = id + 1;
    % all trials
    channels = exp.ch;
    ch = 0;
    cfg = [];
   
    for channel = channels(1:end)
        ch = ch+1;
        
        allsubSP{1,id}.avg(ch,:) = allP{2}(sub,:);
        allsubAW{1,id}.avg(ch,:) = allP{1}(sub,:);
        allsubNR{1,id}.avg(ch,:)= allP{3}(sub,:)
        
        allsubSP{1,id}.cfg = cfg;
        allsubAW{1,id}.cfg = cfg;
        allsubNR{1,id}.cfg= cfg;
        
        allsubSP{1,id}.label        = {'CZ'};
        allsubAW{1,id}.label        = {'CZ'};
        allsubNR{1,id}.label       = {'CZ'};
        
        allsubSP{1,id}.fsample    	= 200;
        allsubAW{1,id}.fsample      = 200;
        allsubNR{1,id}.fsample     = 200;
        
        allsubSP{1,id}.time         = [-2.5:0.005:0.495];
        allsubAW{1,id}.time         = [-2.5:0.005:0.495];
        allsubNR{1,id}.time        = [-2.5:0.005:0.495];
        
        allsubSP{1,id}.dimord         = 'chan_time';
        allsubAW{1,id}.dimord         = 'chan_time';
        allsubNR{1,id}.dimord        = 'chan_time';
        
        %Create zero vector to test against 0
        allsubZero{1,id} = allsubSP{1,id}; 
        allsubZero{1,id}.avg = zeros(1,600);
    end
    
end

%% FieldTrip cluster analysis
cfg = [];
cfg.channel = {'CZ'};
cfg.latency = [-2 0];

cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.clusterthreshold    = 'nonparametric';
cfg.minnbchan           = 0;     
cfg.neighbours          = [];        % same as defined for the between-trials experiment; leave empty if not looking for channel clusters
cfg.tail                = 0;                           % 0 for two-tailed
cfg.clustertail         = 0;
cfg.correcttail         = 'alpha';              % use 'alpha' or 'prob' when running a two-sided test 
cfg.numrandomization    =  100000; %'all';

subj = length(exp.sub_selection);
design = zeros(2,2*subj);
for i = 1:subj
    design(1,i) = i;
end
for i = 1:subj
    design(1,subj+i) = i;
end

design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;


cfg.design = design;
cfg.uvar  = 1; % row 1 of design matrix indicates unit variable (participants id)
cfg.ivar  = 2; % row 2 of design matrix indicates independent variables (experimental conditions)

[AW_SP] = ft_timelockstatistics(cfg, allsubSP{:}, allsubAW{:}); % action locked statistics
save([exp.statsPath, 'K1_FT_stats'], 'AW_SP');
end