resultStr = {'wpli_debiased_delta.mat',...
    'wpli_debiased_theta.mat', ...
    'wpli_debiased_alpha1.mat', ...
    'wpli_debiased_alpha2.mat', ...
    'wpli_debiased_beta.mat', ...
    'wpli_debiased_gamma.mat', };

inputData = 'weightedRandom';

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    
    switch inputData
        case 'weighted'
            [graph.(inputData).CC, graph.(inputData).CPL, graph.(inputData).S] = gr_calculateMetrics(Ws, 'weighted', {'CC', 'CPL', 'S'});

            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'binary'
            nans = isnan(Ws);
            Bs = double(Ws>0.15);
            Bs(nans) = NaN;
            [graph.(inputData).CC, graph.(inputData).CPL, graph.(inputData).S] = ...
                gr_calculateMetrics(Bs, 'binary', {'CC', 'CPL', 'S'});
         
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'binaryRandom'
            [graph.(inputData).CC, graph.(inputData).CPL, graph.(inputData).S] = ...
                gr_calculateMetrics(Brandom, 'binary', {'CC', 'CPL', 'S'});
                        
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'weightedRandom'
            
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Wrandom, 'weighted', {'CC', 'CPL'});
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
    end
  
end

            