resultStr = {'pli5_delta.mat', ...
    'pli5_theta.mat',...
    'pli5_alpha1.mat',...
    'pli5_alpha2.mat',...
    'pli5_beta.mat',...
    'pli5_gamma.mat'};

%     'wpli_debiased_delta.mat',...
%     'wpli_debiased_theta.mat',...
%     'wpli_debiased_alpha1.mat',...
%     'wpli_debiased_alpha2.mat',....
%     'wpli_debiased_beta.mat',...
%     'wpli_debiased_gamma.mat'};

% figureStr = {'conMatrices', ...
%     'R_corrCorrMatrix', ...
%     'scatterGrpAvg', ...
%     'plotGrpAvg', ...
%     'plotConnDist', ...
%     'plotUnitwiseDist'...
%     'degreeTopoplot'};

figureStr = {'barUnitWiseConn'};

for i = 1:length(resultStr)

    switch(figureStr{1})
        case {'conMatrices', ...
                'R_corrCorrMatrix', ...
                'scatterGrpAvg', ...
                'plotGrpAvg', ...
                'plotConnDist', ...
                'plotUnitwiseDist'...
                'degreeTopoplot',...
                'ccTopoplot'} ;
    
            for iFig = 1:length(figureStr)
                currFigStr = figureStr{iFig};
                bv_plotResults(resultStr{i}, currFigStr, 1)
            end
            
        case 'barPlotGlobConn'
            
            disp(resultStr{i})
            fprintf('\t loading ... ')
            load(resultStr{i})
            fprintf('done! \n')
            
            globConn(i) = results.r_scanwise;
            
        case 'barUnitWiseConn'
     
            disp(resultStr{i})
            fprintf('\t loading ... ')
            load(resultStr{i})
            fprintf('done! \n')
            
            output = bv_summarizeResults('pli5_');
            
            
            
            unitWiseConn(i) = results.mr_unitwise;
            unitWiseConnSE(i) = 2*nanstd(results.r_unitwise) / sqrt(length(results.r_unitwise));
            unitWise75Conn(i) = results.mr_unitwise75;
            unitWise75ConnSE(i) = 2*nanstd(results.r_unitwise75) / sqrt(length(results.r_unitwise75));

    end
            
    
end