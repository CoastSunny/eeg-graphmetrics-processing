resultStr = {'wpli_debiased_delta.mat',...
    'wpli_debiased_theta.mat', ...
    'wpli_debiased_alpha1.mat', ...
    'wpli_debiased_alpha2.mat', ...
    'wpli_debiased_alphaTheta.mat', ...
    'wpli_debiased_beta.mat', ...
    'wpli_debiased_gamma.mat', };

method = {'cleanSessions', 'conMatrixCor', 'corrCorrMatrix', 'corrGroupAvg', ...
    'scanwise', 'unitwise', 'unitwise75'};

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    
    for iMethod = 1:length(method)
        currMethod = method{iMethod};
        switch(currMethod)
            case 'cleanSessions'
                fprintf('\t cleaning data over sessions \n')
                Ws = bv_cleanWsOverSessions(Ws);
                fprintf('\t saving newly cleaned Ws to %s', resultStr{i})
                save(resultStr{i}, 'Ws', '-append')
                fprintf('done! \n')
                
            case 'conMatrixCor'
                fprintf('\t calculating correlation between connectivity matrices \n')
                indivCorrs(i,:) = bv_corrSesConnectivity(Ws);
                results.conMatrices = indivCorrs(i,:);
                fprintf('\t adding variable to %s', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
                
            case 'corrCorrMatrix'
                fprintf('\t creating correlation between all connectivity matrices matrix')
                
                WsNeat = zeros([size(Ws,1) size(Ws,2) size(Ws,3)*size(Ws,4)]);
                
                WsNeat(:,:,1:2:end) = Ws(:,:,:,1);
                WsNeat(:,:,2:2:end) = Ws(:,:,:,2);
                
                results.corrCorrMatrix = createCorrCorrMatrix(WsNeat);
                fprintf('\t adding variable to %s', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
                
            case 'corrGroupAvg'
                fprintf('\t correlating group averaged connectivity matrices \n')
                
                W1 = nanmean(Ws(:,:,:,1),3);
                W2 = nanmean(Ws(:,:,:,2),3);
                
                results.grpAvg.W1 = W1;
                results.grpAvg.W2 = W2;
                
                rGrpAvg(i) = correlateMatrices(W1, W2);
                
                results.rGrpAvg = rGrpAvg(i);
                
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
            case 'scanwise'
                fprintf('\t calculating scanwise reliability ... ')
                pc = 0;
                results.r_scanwise = bv_scanwiseICC(Ws);
                fprintf('done! \n')
                
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
                
            case 'unitwise'
                fprintf('\t calculating unitwise reliability ... ')

                pc = 0;
                results.r_unitwise = bv_unitwiseICC(Ws, pc);
                results.mr_unitwise = mean(results.r_unitwise);
                fprintf('done! \n')                
               
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
                
            case 'unitwise75'
                fprintf('\t calculating top 25 perc unitwise reliability ... ')
                pc = 75;
                results.r_unitwise75 = bv_unitwiseICC(Ws, pc);
                results.mr_unitwise75 = mean(results.r_unitwise75);
                fprintf('done! \n')
                
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'results', '-append')
                fprintf('done! \n')
                
                
            case 'randomizeWeightedNetworks'
                if exist('Wrandom', 'var')
                    clear Wrandom
                end
                
                m = size(Ws,4);
                for j = 1:m
                    fprintf('\t randomizing networks session %1.0f ... ', j)
                    
                    currWs = Ws(:,:,:,j);
                    %         currWs_thr = double(currWs > 0.1);
                    Wrandom(:,:,:,:,j) = bv_randomizeWeightedMatrices(currWs, 100);
                end
                
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'Wrandom', '-append')
                fprintf('done! \n')
                
            case 'randomizeBinaryNetworks'
                if exist('Brandom', 'var')
                    clear Brandom
                end
                
                m = size(Ws,4);
                for j = 1:m
                    fprintf('\t randomizing networks session %1.0f ... ', j)
                    
                    
                    
                    currWs = Ws(:,:,:,j);
                    nans = isnan(currWs);
                    currWs_thr = double(currWs > 0.15);
                    BrandMat = bv_randomizeBinaryMatrices(currWs_thr, 100);
                    BrandMat(nans) = NaN;
                    Brandom(:,:,:,:,j) = BrandMat;
                end
                
                fprintf('\t saving to %s ... ', resultStr{i})
                save(resultStr{i}, 'Brandom', '-append')
                fprintf('done! \n')
                
            otherwise
                error('Unknown method')
        end
    end
end


