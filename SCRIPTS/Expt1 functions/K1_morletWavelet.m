%% Morlet wavelet transform
% Source: http://www.mikexcohen.com/lecturelets/manytrials/manytrials.html
% Input:
%   -EXPER: structure with experimental parameters for wavelet transformation
%   -PLOTTING: logical indicating whether plots are required
% Output:
%   -DAT: structure with 3 sub-structures:

function [dat] = K1_morletWavelet(exper, plotting, whichEpoch)

if plotting == 1; figure ; end

% which channel to plot
channel2use = {'CZ'}; 
 
    epoch_dur = 600;% 500-epoch_onset;
    
for ch = channel2use(1:end)
    id = 0;
    for sub = exper.sub_id(1:end)
        id = id +1;
        
        switch whichEpoch  
            case 'orangeLetter'
                conditions = 1:3;  conditionLabels = {'AW', 'NR', 'SP'};
                exper.wd = ['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/orange_letter_longer/'];

            case 'selfPaced' 
                conditions = 1; conditionLabels = {'SelfPaced'};
                exper.wd = ['E:/Postdoc/K1 - LatentAwareness Rep/epochs_180220/action_locked/'];
        end
        
                for c = 1:length(conditions)
                   
                    conditionLabel = conditionLabels{c};
                    if strcmp(whichEpoch, 'orangeLetter')
                        EEG = pop_loadset([exper.wd conditionLabel '_OSF_aRepochOL12_P' num2str(sub) '.set']);
                    elseif strcmp(whichEpoch, 'selfPaced')
                        EEG = pop_loadset([exper.wd 'SPaction_K1_aepochSP_P' num2str(sub) '.set']);
                    end
                    
                    % frequency parameters
                    min_freq =  13;
                    max_freq = 30;
                    num_frex = 34;
                    frex = linspace(min_freq,max_freq,num_frex);
                    
                    % other wavelet parameters
                    range_cycles = exper.morletCycles;
                    s = logspace(log10(range_cycles(1)),log10(range_cycles(end)),num_frex) ./ (2*pi*frex);
                    wavtime = -2:1/EEG.srate:2;
                    half_wave = (length(wavtime)-1)/2;
                    
                    % FFT parameters
                    nWave = length(wavtime);
                    nData = EEG.pnts * EEG.trials; % EEG.pnts NOTE: do for whole epoch, even if it is longer than desired - in the beta burst count, take only up to the interesting time.
                    nConv = nWave + nData - 1;
                    
                    % initialize output time-frequency data
                    tf = zeros(length(frex),EEG.pnts); %EEG.pnts
                    
                    % now compute the FFT of all trials concatenated
                    alldata = reshape(EEG.data(strcmpi(ch,{EEG.chanlocs.labels}),1:EEG.pnts,:) ,1,[]);
                    %disp(num2str(size(EEG.data(strcmpi(channel2use,{EEG.chanlocs.labels}),1:500,:))))
                    dataX   = fft(alldata ,nConv );
                    
                    % loop over frequencies
                    for fi=1:length(frex)
                        
                        % create wavelet and get its FFT
                        % the wavelet doesn't change on each trial...
                        wavelet  = exp(2*1i*pi*frex(fi).*wavtime) .* exp(-wavtime.^2./(2*s(fi)^2));
                        waveletX = fft(wavelet,nConv);
                        waveletX = waveletX ./ max(waveletX);
                        
                        % now run convolution in one step
                        as = ifft(waveletX.*dataX);
                        as = as(half_wave+1:end-half_wave);
                        
                        % and reshape back to time X trials
                        as = reshape(as,EEG.pnts,EEG.trials ); %EEG.pnts
                        disp(num2str(size(as)))
                        % compute power for single trials
                        dat{id}.st_tf{c}(fi,:,1:EEG.trials) = abs(as).^2;
                        % dat{id}.st_amp{c}(:,1:EEG.trials) = abs(as);
                        % compute power and average over trials
                        dat{id}.tf{c}(fi,:) = mean(abs(as).^2 ,2);
                    end
                    dat{id}.st_amp{c}(:,1:EEG.trials) = squeeze(mean(sqrt(dat{id}.st_tf{c}(:,:,1:EEG.trials))));
                    
                    %figure
                    %Plot 1 sample trial trials
                    % Specify positions in the graph
                    if plotting == 2
                        if c == 1, pos = 1;
                        elseif c == 2, pos = 3;
                        elseif c == 3; pos = 5;
                        end
                        
                        subplot(3,2,pos)
                        plot(dat{id}.st_amp{c}(:,1))
                        subplot(3,2,pos+1)
                        contourf(EEG.times,frex,dat{id}.st_tf{c}(:,:,1),34,'linecolor','none')
                        colorbar
                    end
                    

                end
        
    end
    if plotting == 1
        figure
        for i = [1,3,5,7,9]
            subplot(5,2,i)
            plot(EEG.times(1:epoch_dur),dat{id}.st_amp{1}(:,i))
            subplot(5,2,i+1)
            contourf(EEG.times(1:epoch_dur),frex,dat{id}.st_tf{1}(:,:,i),40,'linecolor','none')
            colorbar
        end
    end
    save([exper.processedData, 'K1_betaWavelets_OSF_morletCycles_' num2str(exper.morletCycles) '_' whichEpoch '_' ch{1} '.mat'], 'dat');
    
end
end