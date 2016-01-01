resultStr = {'wpli_debiased_delta.mat',...
    'wpli_debiased_theta.mat', ...
    'wpli_debiased_alpha1.mat', ...
    'wpli_debiased_alpha2.mat', ...
    'wpli_debiased_beta.mat', ...
    'wpli_debiased_gamma.mat', };

inputData = 'binaryRandom'; % weighted, binary, weightedRandom, binaryRandom
randomflag = 0;

if strfind(inputData, 'Random') > 0
    randomflag = 1;
end

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    if isfield(ICCresults, inputData)
        ICCresults = rmfield(ICCresults, inputData);
    end
    
    metrics = fieldnames(graph.(inputData));
    
    for j = 1:length(metrics)
        currMetricName = metrics{j};
        currMetric = graph.(inputData).(currMetricName);
        if ~randomflag

            currMetric = currMetric(~any(isnan(currMetric),2),:);
            currMetric = currMetric(~any(isinf(currMetric),2),:);
            output = ICC(currMetric, '1-k');
        else
            
            for k = 1:size(currMetric,2)
                tmp = squeeze(currMetric(:,k,:));
                tmp = tmp(~any(isnan(tmp),2),:);
                tmp = tmp(~any(isinf(tmp),2),:);
                output(k) = ICC(tmp, '1-k');
            end
            
        end
        ICCresults.(inputData).(currMetricName) = output;
        
        fprintf('\t saving to %s ... ', resultStr{i})
        save(resultStr{i}, 'ICCresults', '-append')
        fprintf('done! \n')
    end
    
    
end
