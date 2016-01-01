function bv_showConnectivityMatrices(cfg, connectivity)

inputStr 	= ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
saveFigures = ft_getopt(cfg, 'saveFigures');
freqLabel   = ft_getopt(cfg, 'freqLabel');
freqRange   = ft_getopt(cfg, 'freqRange');


if nargin < 2
    disp(currSubject)
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, connectivity] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
end

if isempty(freqLabel) || isempty(freqRange)
    fprintf('\t No specific frequency bands given. Using all standard frequency bands. \n')
    freqLabel = {'delta', 'theta', 'alpha1', 'alpha2', 'beta', 'gamma1', 'gamma2'};
    freqRange = {[1 3], [3 6], [6 9], [9 12], [12 25], [25 48], [52 98]};
end

if not(length(freqLabel) == length(freqRange))
    disp('')
    errorStr = sprintf('cfg.freqLabel (%1.0f) and cfg.freqRange (%1.0f) differ in length', ...
        length(freqLabel), length(freqRange));
    error(errorStr)
end

for iFreq = 1:length(freqLabel)
    cFreqLabel = freqLabel{iFreq};
    cFreqRange = freqRange{iFreq};
    
    fprintf('\t %s \n', cFreqLabel)
    
    fprintf('\t\t selecting data ... ')
    cfg = [];
    cfg.frequency = cFreqRange;
    evalc('currConnectivity = ft_selectdata(cfg, connectivity);');
    fprintf('done! \n')
    
    fprintf('\t\t creating connectivity matrix ... ')
    W = mean(currConnectivity.wpli_debiasedspctrm,3);
    ncols = size(W,2);
    W(1:ncols+1:end) = NaN;
    
    figure;
    imagesc(W)
    title([currSubject ': Connectivity matrix ' cFreqLabel], 'FontSize', 20)
    set(gca, 'XTick', 1:length(connectivity.label), 'XTickLabel', connectivity.label, 'XTickLabelRotation', 90)
    set(gca, 'YTick', 1:length(connectivity.label), 'YTickLabel', connectivity.label)
    ylabel('Channels', 'FontSize', 14)
    xlabel('Channels', 'FontSize', 14)
    axis('square')
    fprintf('done! \n')
    
    xScreenLength = 1;
    yScreenLength = 1;
    
    if exist('WindowSize', 'file')
        [xScreenSize, yScreenSize] = WindowSize(0);
        set(0, 'units', 'pixels')
        realScreenSize = get(0, 'ScreenSize');
        xDiff = xScreenSize / realScreenSize(3);
        xScreenLength = xScreenLength * xDiff;
        yDiff = yScreenSize / realScreenSize(4);
        yScreenLength = yScreenLength * yDiff;
    end
    
    set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
    drawnow;
    
    
    if strcmpi(saveFigures, 'yes')
        if ~isfield(subjectdata.PATHS, 'FIGURES')
            subjectdata.PATHS.FIGURES = [subjectdata.PATHS.SUBJECTDIR filesep 'figures'];
        end
        if ~exist(subjectdata.PATHS.FIGURES, 'dir')
            mkdir(subjectdata.PATHS.FIGURES)
        end
        
        picFilename = [subjectdata.subjectName '_' cFreqLabel '_' outputStr '.png'];
        fprintf('\t\t saving %s ... ', picFilename)
        saveas(gcf, [subjectdata.PATHS.FIGURES filesep picFilename])
        fprintf('done! \n')
        
        close all
    end
    
end





