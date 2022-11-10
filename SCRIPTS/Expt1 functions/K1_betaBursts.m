%% Function to identify beta bursts on a single trial level
% Following Little et al. 2019

function [dat] = K1_betaBursts(exper, epoch)
%%
% which channel to plot
channel2use = {'Cz'}; 

for ch = channel2use(1:end)
    
    switch epoch 
        case 'orangeLetter' 
            load([exper.processedData, 'K1_betaWavelets_OSF_morletCycles_' num2str(exper.morletCycles) '_orangeLetter_' ch{1} '.mat']);
            conditions = 1:3;
        case 'selfPaced'
            load([exper.processedData, 'K1_betaWavelets_OSF_morletCycles_' num2str(exper.morletCycles) '_selfPaced_' ch{1} '.mat'])
            conditions = 1;
    end
            
    %Initially explore several thresholds.
    %The chosen threshold will be the one that maximises
    %the correlation between trial-wise beta amplitude and beta burst count.
    if strcmp(epoch, 'orangeLetter')
        epoch_onset= 101; %500 ms
        epoch_dur = 550 - epoch_onset; %Note: excluding last 250ms before orange letter to avoid post-probe activity leaking in
    elseif strcmp(epoch, 'selfPaced')
        epoch_onset= 101; % 500 ms
        epoch_dur = 600 - epoch_onset; 
    end
    
    % Identify beta bursts using a range of beta amplitude thresholds
    std_range = [0:0.25:5];  % from 0*SD to 5*SD in 0.25 steps; range taken from Little et al. 2019
    th = 0;
    
    for s = std_range(1:end)
        
        id = 0;
        th = th+1;
        
        for sub = 1:length(exper.sub_id)
            allTrials = [];
            id = id+1;
            %Append single trial amplitudes for all conditions
            for c = 1:length(conditions)
                if c == 1
                    allTrials = [dat{id}.st_amp{c}(epoch_onset:epoch_onset+epoch_dur,:)];
                else
                    allTrials = [allTrials, dat{id}.st_amp{c}(epoch_onset:epoch_onset+epoch_dur,:)]; % append
                end
            end
            
            % concatenate all trials to get one single median value
            allTrials = reshape(allTrials', [], 1);
            median_betaamp = median(allTrials);
            std_betaamp = std(allTrials);
            threshold = median_betaamp + s*std_betaamp; %define threshold
            
            for c = 1:length(conditions)
                dat{id}.st_amp_burst{c,th} = dat{id}.st_amp{c}(epoch_onset:epoch_onset+epoch_dur,:) > threshold; %logical finding bursts
                bursts = dat{id}.st_amp_burst{c,th};
                ntrials = size(bursts, 2)
                
                for t = 1:ntrials
                    exclude = 0;
                    clear starts; clear ends; clear lastburst;
                    trial = bursts(:,t)';
                    
                    x1 = diff(trial) == 1; %indicates start of burst
                    x2 = diff(trial) == -1; %indicates end of burst
                    
                    starts = find(x1);
                    ends = find(x2);
                    
                    dat{id}.burstdur{c,th}{t} = [];
                    
                    if isempty(ends), ends = epoch_dur; end
                    if isempty(starts), starts = epoch_dur; exclude = 1; end
                    
                    if starts(1) < ends(1) % if start earlier than end
                        % if the first detected start is earlier than the first
                        % detected end, this means that the trial started with
                        % a no-burst
                        if length(starts) == length(ends)
                            dat{id}.burstdur{c,th}{t,1}= ends-starts; % count duration of consecutive bursts
                        elseif length(ends) > length(starts)
                            dat{id}.burstdur{c,th}{t,1} = [ends(1), starts-ends(2:end), epoch_dur-starts(end)];
                        elseif length(ends) < length(starts)
                            dat{id}.burstdur{c,th}{t,1} = [starts(1), starts(2:end)-ends, epoch_dur-starts(end)];
                        end
                        
                    else % if end earlier than start
                        % if the first detected start is later than the first
                        % detected end, this means that the trial started with
                        % a burst
                        if length(starts) == length(ends)
                            dat{id}.burstdur{c,th}{t,1} = [ends(1), ends(2:end)-starts(1:end-1), epoch_dur-starts(end)];
                        else
                            dat{id}.burstdur{c,th}{t,1} = [ends(1), ends(2:end)-starts, epoch_dur-starts(end)];
                        end
                    end
                    if exclude == 0
                        dat{id}.burstcount_epochmedian{c,th}(t,1) = length(dat{id}.burstdur{c,th}{t,1});
                    elseif exclude == 1
                        dat{id}.burstcount_epochmedian{c,th}(t,1) = 0; %No bursts
                    end
                    
                    dat{id}.burstcount_epochmedian{c,th}(t,2) = median(dat{id}.st_amp{c}(epoch_onset:epoch_onset+epoch_dur,t)); % get median beta amplitude for each trial to then plot correlation
                    dat{id}.burstcount_epochmedian{c,th}(t,3) = mean(dat{id}.st_amp{c}(epoch_onset:epoch_onset+epoch_dur,t)); % get median beta amplitude for each trial to then plot correlation
                    
                    % Get indices for last burst
                    if starts(end)<ends(end)
                        lastburst = [starts(end):ends(end)];
                        %Last burst start and end
                        dat{id}.burstcount_epochmedian{c,th}(t,4) = starts(end);
                        dat{id}.burstcount_epochmedian{c,th}(t,5) = ends(end);
                    elseif length(starts) > 1
                        lastburst = [starts(end-1):ends(end)];
                        %Last burst start and end
                        dat{id}.burstcount_epochmedian{c,th}(t,4) = starts(end-1);
                        dat{id}.burstcount_epochmedian{c,th}(t,5) = ends(end);
                    else
                        lastburst = [starts(end):ends(end)];
                        %Last burst start and end
                        dat{id}.burstcount_epochmedian{c,th}(t,4) = starts(end);
                        dat{id}.burstcount_epochmedian{c,th}(t,5) = ends(end);
                    end
                    
                    if isempty(lastburst)
                        lastburst = [ends(end):starts(end)];
                    end
                    
                    %Last burst height
                    dat{id}.burstcount_epochmedian{c,th}(t,6) = max(dat{id}.st_amp{c}(lastburst,t));
                    dat{id}.burstcount_epochmedian{c,th}(t,7) = length(lastburst)
                    
                end
            end
            %Create a matrix with the correlation between median beta amplitude
            %and beta burst count on a trial-by-trial basis
            dat{id}.allTrials{th}.dat = cat(1,dat{id}.burstcount_epochmedian{:,th});
            
            % subplot(4,5,id)
            % scatter(dat{id}.allTrials{th}.dat(:,2), dat{id}.allTrials{th}.dat(:,1))
            rho = corr(dat{id}.allTrials{th}.dat(:,2), dat{id}.allTrials{th}.dat(:,1));
            allrho(id,th) = rho;
            dat{id}.allTrials{th}.rho = rho;
            % text(0,0,num2str(rho))
            % lsline
        end
    end
    
    %% Find optimal threshold
    garho = median(allrho)
    maxrho = find(garho == max(garho))
    optstd = std_range(maxrho) % this is the number of STD that maximises the grand-averaged correlation
    %% Use max rho to find beta burst counts in different conditions and test for differences
    figure
    betaDat.all = [];
    for id = 1:length(exper.sub_id)
        for c = 1:length(conditions)
            thisdat = dat{id}.burstcount_epochmedian{c,maxrho}(:,[1:3,5,6]); %burst count, median, mean, start last burst, end last burst, height last burst, dur last burst
            betaDat.dat(id,c) = mean(thisdat(:,1));
            betaDat.sd(id,c) = std(thisdat(:,1));
            betaDat.all = [betaDat.all; [repmat(id,length(thisdat(:,1)), 1), repmat(c, length(thisdat(:,1)), 1), thisdat]];
        end
    end
    
    betaDat.all = array2table(betaDat.all); 
    betaDat.all.Properties.VariableNames = {'id', 'cond', 'burstcount', 'betamedian', 'betamean', 'endlast', 'amplast'};
%   writetable(betaDat.all, [exper.processedData, 'K1_betaBursts_morletCycles_' num2str(exper.morletCycles) '_' epoch '_' ch{1} '.csv'])
    writetable(betaDat.all, [exper.processedData, 'Exp1_R_burstData_' epoch '_' ch{1} '.csv'])
    
%     save([exper.processedData, 'K1_betaBursts_morletCycles_' num2str(exper.morletCycles) 'fullDetails_' epoch '.mat'], 'dat', 'maxrho', 'optstd')
    save([exper.processedData, 'Exp1_R_burstData_fullDetails_' epoch '.mat'], 'dat', 'maxrho', 'optstd')

    %Saved to plot FigS1
end
end




