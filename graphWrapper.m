str = 'wpli_debiased';

a = dir([str '_*.mat']);
resultStr = {a.name};

% resultStr = {    
inputData = 'weighted';
thresholds = [0];

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    
    switch inputData
        case 'weighted'
            range = [0.001 1];
            
            a = (range(2)-range(1))/(max(Ws(:))-min(Ws(:)));
            b = range(2) - a * max(Ws(:));
            Wsnrm = a * Ws + b;
            
            for iT = 1:length(thresholds)
                
%                 WsThr = Wsnrm.*double(Wsnrm>thresholds(iT));
                
                [CC(:,:,iT), CPL(:,:,iT), S(:,:,iT), CCnrm(:,:,iT), CPLnrm(:,:,iT)] = gr_calculateMetrics(Ws, 'weighted', {'CC', 'CPL', 'S'});

%                 [graph.(inputData).CC(:,:,iT), graph.(inputData).CPL(:,:,iT)] = gr_calculateMetrics(WsThr, 'weighted', {'CC', 'CPL'});
                
            end
            
            graphResults.(inputData).CC = CC;
            graphResults.(inputData).CPL = CPL;
            graphResults.(inputData).S = S;
            graphResults.(inputData).CCnrm = CCnrm;
            graphResults.(inputData).CPLnrm = CPLnrm;
            
%             graphResults.(inputData).degree = squeeze(mean(Ws));
            
            
            graphResults.(inputData).thresholds = thresholds;
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graphResults', '-append')
            fprintf('done! \n')
            
            
        case 'binary'
            nans = isnan(Ws);
            Bs = double(Ws>0.15);
            Bs(nans) = NaN;
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Bs, 'binary', {'CC', 'CPL'});
         
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'graph', '-append')
            fprintf('done! \n')
            
        case 'binaryRandom'
            [graph.(inputData).CC, graph.(inputData).CPL] = ...
                gr_calculateMetrics(Brandom, 'binary', {'CC', 'CPL'});
                        
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

            