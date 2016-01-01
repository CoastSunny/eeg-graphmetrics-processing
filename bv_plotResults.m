function varargout = bv_plotResults(resultsName, vars, saveflag)

if ~iscell(vars)
    vars = {vars};
end

disp(resultsName)
try
    fprintf('\t loading ... ')
    load(resultsName)
    fprintf('done! \n')
catch
    error('%s not found', resultsName)
end

if saveflag
    figureDir = [pwd filesep 'figures' filesep resultsName];
    if ~exist(figureDir, 'dir')
        mkdir(figureDir)
    end
end

freqband = strsplit(resultsName, '_');
freqband = freqband{end};

for iVar = 1:length(vars)
    currVar = vars{iVar};

    
    switch currVar
        case 'conMatrices'
            
            if ~isfield(results, 'conMatrices')
                error('%s not found in %s', currVar, resultsName)
            end
            
            fprintf('\t creating R_conMatrices figure ... ')
            varargout{iVar} = figure; 
            bar(results.conMatrices)
            title([freqband ' individual correlation coefficient between sessions'], 'FontSize', 20)
            ylabel('Correlation coefficient (in r)', 'FontSize', 14)
            xlabel('Subjects', 'FontSize', 14)

            set(gca, 'YLim', [(min(results.conMatrices) - 0.05) 1])
            set(gca, 'XLim', [0 length(results.conMatrices)+1])
            fprintf('done! \n')
            
            if saveflag
                fprintf('\t saving figure ... ')
                filename = [freqband '_bar_corrConMatrices'];
                export_fig([figureDir filesep filename], '-dpng', '-transparent', '-r300')
                fprintf('done! \n')
                close all
            end
                
            
        case 'R_corrCorrMatrix'
            
            if ~exist(currVar, 'var')
                error('%s not found in %s', currVar, resultsName)
            end
            
            fprintf('\t creating R_conMatrices figure ... ')
            varargout{iVar} = figure;
            imagesc(R_corrCorrMatrix)
            colorbar;
            axis('square')
            fprintf('done! \n')
            
            if saveflag
                fprintf('\t saving figure ... ')
                filename = 'imR_corrCorrMatrix.png';
                print(varargout{iVar}, [figureDir filesep filename], '-dpng', '-r300')
                fprintf('done! \n')
                close all
            end
            
        case 'scatterGrpAvg'
            fprintf('\t creating scatter group averages ... ')
            varargout{iVar} = figure;
            W1 = squeeze(nanmean(Ws(:,:,:,1),3));
            W2 = squeeze(nanmean(Ws(:,:,:,2),3));
            
            scatter(squareform(W1), squareform(W2))
            title([freqband ' group averaged scatterplot'], 'FontSize', 20)
            axis('square')
            fprintf('done! \n')
            
            if saveflag
                fprintf('\t saving figure ... ')
                filename = [freqband '_scatterGrAvg'];
                export_fig([figureDir filesep filename], '-dpng', '-transparent', '-r300')
                fprintf('done! \n')
                close all
            end
            
        case 'plotGrpAvg'
            fprintf('\t plot group-averaged matrices... ')
            varargout{iVar} = figure;
            W1 = squeeze(nanmean(Ws(:,:,:,1),3));
            W2 = squeeze(nanmean(Ws(:,:,:,2),3));
            
            subplot(1,2,1)
            imagesc(W1)
            axis('square')
            colorbar
            subplot(1,2,2)
            imagesc(W2)
            axis('square')
            colorbar
            set(gcf, 'units', 'normalized', 'Position', [0 0 1 1])
            
            if saveflag
                fprintf('\t saving figure ... ')
                filename = 'groupAvgMat.png';
                print(varargout{iVar}, [figureDir filesep filename], '-dpng', '-r300')
                fprintf('done! \n')
                close all
            end
    end
end

