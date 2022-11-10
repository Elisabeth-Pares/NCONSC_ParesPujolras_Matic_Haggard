function [cfg] = CFGfieldTripSetup()
%% CFG for fieldTrip stats

%Configuration    
cfg = [];
cfg.channel = {'CZ'};
cfg.latency = [-2 0];

cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.clusterthreshold = 'nonparametric';
cfg.minnbchan = 0;     
cfg.neighbours = [];             % same as defined for the between-trials experiment; leave empty if not looking for channel clusters
cfg.tail = 0;                           % 0 for two-tailed
cfg.clustertail = 0;                    % 0 for two-tailed
cfg.alpha = 0.05;                      
cfg.correcttail = 'alpha';                 % use 'alpha' or 'prob' when running a two-sided test 
cfg.numrandomization = 10000;

cfg.dimord = 'chan_time';
subj = 19;
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


end

