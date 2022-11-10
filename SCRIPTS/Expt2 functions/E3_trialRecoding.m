function [] = E3_trialRecoding(exp)
% Recode trials as a function of rating & reject trials where a keypress
% occurred within the designated interval prior to the orange letter.

allP_results = []; %Initialise data vector
for sub = exp.sub_id(1:end)
    
    load([exp.behPath 'E3_results_' num2str(sub)]);
    id_num(1:36,1) = sub;
    
    for block = 1:exp.nblocks
        block_id(1:36,1) = block;
        % Get ratings
        ratings = ([results.block{block,1}{1,1}{4,:}])';
        
        % Generate recoding matrixes
        for r = 1:length(ratings)
            recoding_all{r,1} = num2str(ratings(r));
        end
        
        % Substitute [] for NaNs in the ratings & key press column
        for i = 1:length([results.block{block,1}{1,1}{2,:}])
            if isempty(results.block{block,1}{1,1}{4,i})
                results.block{block,1}{1,1}{4,i} = NaN;
            end
            if isempty(results.block{block,1}{1,1}{8,i})
                results.block{block,1}{1,1}{8,i} = NaN;
            end
        end
        
        % Find idx of ratings
        ratings_idx = [find(~isnan([results.block{block,1}{1,1}{4,:}]))]';
        
        % Find last key press before rating & calculate time interval OR
        % last orange letter
        for k = 1:length(ratings_idx)
            if ~isempty(find(~isnan([results.block{block,1}{1,1}{8,1:ratings_idx(k)}]),1,'last'));
                last_kp_idx(k,1) = find(~isnan([results.block{block,1}{1,1}{8,1:(ratings_idx(k))}]),1,'last');
                time_interval(k,1) = (results.block{block,1}{1,1}{2,(ratings_idx(k)-1)}) - (results.block{block,1}{1,1}{8,last_kp_idx(k,1)}); % k-1 is the time of the orange letter presentation
                all_kp_idx = find(~isnan([results.block{block,1}{1,1}{8,1:(ratings_idx(k))}]));
            else
                last_kp_idx(k,1) = NaN;
                time_interval(k,1) = NaN;
            end
        end
        
        % All results
        if block == 1
            all_results = [id_num block_id ratings ratings_idx last_kp_idx time_interval];
            all_recoding_all = recoding_all;
        else
            all_results_new = [id_num block_id ratings ratings_idx last_kp_idx time_interval];
            all_results = [all_results; all_results_new];
            
            recoding_all_new = recoding_all;
            all_recoding_all = [all_recoding_all; recoding_all_new];
        end
        clear recoding_all;
    end
    
    % REJECT TRIALS 
    for i = 1:length(all_results(:,1)) % Reject trials with keypresses after probe (negative time interval)
        if all_results(i,6)<0
            all_results(i,6)= NaN;
            all_recoding_all{i,1} = 'postProbePress';
        elseif all_results(i,6)>0 && all_results(i,6)< exp.kpe      %Reject trials with keypresses within 2s prior to probe

            all_results(i,6)= NaN;
            all_recoding_all{i,1} = 'reject';
        end
    end
    
    % Save data 
    allP_results = [allP_results; all_results];
       
    save([exp.behPath, 'E3_P' num2str(sub) '_recoding_rej' num2str(exp.kpe)],  'all_results', 'all_recoding_all', 'time_interval');
    clear results; clear all_recoding_all;
end

save([exp.behPath, 'E3_P' num2str(sub) '_recoding_rej' num2str(exp.kpe)], 'allP_results');