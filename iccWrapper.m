resultStr = {...
    'wpli_debiased_delta.mat',...
    'wpli_debiased_theta.mat', ...
    'wpli_debiased_alpha1.mat', ...
    'wpli_debiased_alpha2.mat', ...
    'wpli_debiased_beta.mat', ...
    'wpli_debiased_gamma.mat'};

% 'pli_delta.mat', ...
%     'pli_theta.mat',...
%     'pli_alpha1.mat', ...
%     'pli_alpha2.mat', ...
%     'pli_beta.mat', ...
%     'pli_gamma.mat', ...

inputData = 'weighted'; % weighted, binary, weightedRandom, binaryRandom
randomflag = 0;

if strfind(inputData, 'Random') > 0
    randomflag = 1;
end

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    if exist('ICCresults', 'var')
        if isfield(ICCresults, inputData)
            ICCresults = rmfield(ICCresults, inputData);
        end
    end
    
    metrics = fieldnames(graphResults.(inputData));
    metrics = metrics(cellfun(@isempty, strfind(metrics, 'thresholds')));
    for j = 1:length(metrics)
        currMetricName = metrics{j};
        currMetric = real(graphResults.(inputData).(currMetricName));
        
        fprintf('\t %s \n', currMetricName) 
        
        for iT = 1:size(currMetric,3)
            
            if ~randomflag
                cThresh = squeeze(currMetric(:,:,iT));
                
                fprintf('\t \t calculate ICC ... ')
                cThresh = cThresh(~any(isnan(cThresh),2),:);
                cThresh = cThresh(~any(isinf(cThresh),2),:);
                output(iT) = ICC(cThresh, '1-k');
                fprintf('done! \n')
                
                fprintf('\t \t bootstrapping for CI ... ')
                bootstat = bootstrp(1000,@(x) ICC(x, '1-k'), cThresh);

                CI(iT,1)  = prctile(bootstat, 2.5);
                CI(iT,2)  = prctile(bootstat, 97.5);
                fprintf('done! \n')
                
            else
                
                for k = 1:size(currMetric,2)
                    tmp = squeeze(currMetric(:,k,:));
                    tmp = tmp(~any(isnan(tmp),2),:);
                    tmp = tmp(~any(isinf(tmp),2),:);
                    output(k,iT) = ICC(tmp, '1-k');
                end
                
            end
        end
        ICCresults.(inputData).(currMetricName) = output;
        ICCresults.(inputData).([currMetricName '_CI']) = CI;
        

    end
    fprintf('\t saving to %s ... ', resultStr{i})
    save(resultStr{i}, 'ICCresults', '-append')
    fprintf('done! \n')
end
