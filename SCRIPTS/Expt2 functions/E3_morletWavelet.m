%% Morlet wavelet transform
% Edited from: http://www.mikexcohen.com/lecturelets/manytrials/manytrials.html
% Input:
%   -EXPER: structure with experimental parameters for wavelet transformation 
%   -PLOTTING: logical indicating whether plots are required
% Output: 
%   -DAT: structure with 3 sub-structures: 
        
function [dat] = E3_morletWavelet(exper, plotting, epoch)

if plotting == 1; figure ; end
id = 0;

for sub = exper.sub_id(1:end)
    id = id +1;
    c = 1; %only one condition 
    
    if epoch == 1 % if epochs == 1, orange letter
        %epoch_dur = 300; %Note: epochs are 500 data points, but we want to look at pre-orange letter data only (up to sample 300, 1.5 s at 200 sampling rate)
        %Run for whole epoch to avoid edge effects!
        EEG = pop_loadset(['E:/PhD - London/E3 - Gradual Awareness/april2019/rec_kprej' num2str(exper.kpe) '_acICAabodfrE3_P' num2str(sub) '.set']); %Preprocessed data available at OSF 
        epoch_dur = EEG.pnts;
        epoch_plot = 600;
    elseif epoch == 2 % if epochs == self-paced 
        EEG = pop_loadset(['E:/PhD - London/E3 - Gradual Awareness/april2019/abadfrE3_P' num2str(sub) '.set']); %Preprocessed data available at OSF 
        epoch_dur = EEG.pnts; %Do for the whole epoch, pre & post-movement
        epoch_plot = 700;
    end
        
        % frequency parameters
        min_freq =  exper.min_freq;
        max_freq = exper.max_freq;
        num_frex = exper.num_freq;
        frex = linspace(min_freq,max_freq,num_frex);
        
        % which channel to plot
        channel2use = exper.thisChan; %previously CZ
       
        % other wavelet parameters
        range_cycles = exper.morletCycles;
        
        s = logspace(log10(range_cycles(1)),log10(range_cycles(end)),num_frex) ./ (2*pi*frex);
        wavtime = -2:1/EEG.srate:2;
        half_wave = (length(wavtime)-1)/2;
        
        % FFT parameters
        nWave = length(wavtime);
        nData = epoch_dur * EEG.trials; % EEG.pnts
        nConv = nWave + nData - 1;
        
        % initialize output time-frequency data
        tf = zeros(length(frex),epoch_dur); %EEG.pnts
        
        % now compute the FFT of all trials concatenated - edge effects
        % only on first and last trial!
        alldata = reshape(EEG.data(strcmpi(channel2use,{EEG.chanlocs.labels}),1:epoch_dur,:) ,1,[]);
        %disp(num2str(size(EEG.data(strcmpi(channel2use,{EEG.chanlocs.labels}),1:epoch_dur,:))))
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
            as = reshape(as,epoch_dur,EEG.trials ); %EEG.pnts
            disp(num2str(size(as)))
            % compute power for single trials
            dat{id}.st_tf{c}(fi,:,1:EEG.trials) = abs(as).^2;
            %dat{id}.st_amp{c}(:,1:EEG.trials) = abs(as); %I think this is taking only the last frequency...!
            
            % compute power and average over trials
            dat{id}.tf{c}(fi,:) = mean(abs(as).^2 ,2);
        end
        
        dat{id}.st_amp{c}(:,1:EEG.trials) = squeeze(mean(sqrt(dat{id}.st_tf{c}(:,:,1:EEG.trials))));
           
        %figure
        %Plot 1 sample trials
        % Specify positions in the graph
        if plotting == 2
            figure
%             xTick = [-2000,-1000,0]; 

            for i = [1,3,5]
                subplot(3,2,i)
                plot(dat{id}.st_amp{c}(1:epoch_plot,i+1))
                xlabel('Time (s)'); ylabel('Beta amp');
                yLimits = get(gca,'YLim');  %# Get the range of the y axi
                line([500,500], [yLimits], 'color', 'k');
                xTick = [100,300,500]; 
                set(gca, 'XLim', [100,600],...
                    'XTick', xTick,...
                    'XTickLabel', {'-2', '-1', '0'})
                
                subplot(3,2,i+1)
                contourf(EEG.times(1:epoch_plot),frex,dat{id}.st_tf{c}(:,1:epoch_plot,i+1),34,'linecolor','none')
                xlabel('Time (s)'); ylabel('Hz');
                yLimits = get(gca,'YLim');  %# Get the range of the y axi
                line([0,0], [yLimits], 'color', 'k' );
                xTick = [-2000,-1000,0]; 
                set(gca, 'XLim', [-2000,500],...
                    'XTick', xTick,...
                    'XTickLabel', {'-2', '-1', '0'})
                colorbar
                colorbar
                colormap('jet');
            end
        end
        
end
% Plot grand-average
% with amplitude and power spectra - CAREFUL, AMP doesnt seem to match TF
% Update: now it does! error was in line 67, now commented out - were
% looking only at frequency = 30Hz!

if plotting == 1
    figure
    
    xTick = [-2000,-1000,0];
    
    %     for i = [1,3,5,7,9]
    subplot(1,2,1)
    %freqstd = std(dat{id}.st_tf{1}(:,:,i)');
    %freqmean = mean(dat{id}.st_tf{1}(:,:,i),2) %frequency-wise mean for this trial
    %freqmat = repmat(freqmean,1,300) %repeat matrix to do point-by-point normalisation
    %freqstdmat = repmat(freqstd',1,300) %repeat matrix to do point-by-point normalisation
    
    %plot(EEG.times(1:epoch_dur),mean(dat{id}.st_amp{1}(:,:),2)) % added divided by mean to normalise
    stdshade(dat{id}.st_amp{1}(:,:), 0.5, 'b');
    xlabel('Time (s)'); ylabel('Beta amp');
    yLimits = get(gca,'YLim');  %# Get the range of the y axi
    line([500,500], [yLimits], 'color', 'k');
    xTick = [100,300,500];
    set(gca, 'XLim', [100,600],...
        'XTick', xTick,...
        'XTickLabel', {'-2', '-1', '0'})
    
    subplot(1,2,2)
    contourf(EEG.times(1:epoch_dur),frex,mean(dat{id}.st_tf{1}(:,:,:),3),40,'linecolor','none')
    xlabel('Time (s)'); ylabel('Hz');
    yLimits = get(gca,'YLim');  %# Get the range of the y axi
    line([0,0], [yLimits], 'color', 'k' );
    set(gca, 'XLim', [-2000,500],...
        'XTick', xTick,...
        'XTickLabel', {'-2', '-1', '0'})
    colorbar
    % end
end

% with amplitude and power spectra 
% if plotting == 1
%     figure
%     j= 0
%     for i = [1,3,5,7,9]
%         j = j+1
%         subplot(5,1,j)
%         contourf(EEG.times(1:epoch_dur),frex,dat{id}.st_tf{1}(:,:,i),40,'linecolor','none')
%         colorbar
%     end
% end

end