function [data, artefactdef, counts] = bv_artefactRejection(cfg, data)

betaLim     = ft_getopt(cfg, 'betaLim');
gammaLim    = ft_getopt(cfg, 'gammaLim');
varLim      = ft_getopt(cfg, 'varLim');
invVarLim   = ft_getopt(cfg, 'invVarLim');
kurtLim     = ft_getopt(cfg, 'kurtLim');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
triallength = ft_getopt(cfg, 'triallength');
saveFigures = ft_getopt(cfg, 'saveFigures');
showFigures = ft_getopt(cfg, 'showFigures');
currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');
rmTrials    = ft_getopt(cfg, 'rmTrials');
cutOutputData = ft_getopt(cfg, 'cutOutputData');
zScoreLim   = ft_getopt(cfg, 'zScoreLim');
vMaxLim     = ft_getopt(cfg, 'vMaxLim');

eval(optionsFcn)

output = 'pow';

if isempty(betaLim)
    betaLim = Inf;
end
if isempty(gammaLim)
    gammaLim = Inf;
end
if isempty(varLim)
    varLim = Inf;
end
if isempty(invVarLim)
    invVarLim = Inf;
end
if isempty(kurtLim)
    kurtLim = Inf;
end
if isempty(optionsFcn)
    error('please add options function cfg.optionsFcn')
end

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

disp(subjectdata.subjectName)

if nargin < 2
    try
        [~, filenameData, ~] = fileparts(subjectdata.PATHS.(inputStr));
        
        fprintf('\t loading %s ... ', [filenameData '.mat'])
        load(subjectdata.PATHS.(inputStr))
        fprintf('done! \n')
    catch
        error('No input data variable given and inputStr not given / found')
    end
end

oldData = data;

fprintf('\t redefining triallength to %s seconds ... ', num2str(triallength))
cfg = [];
cfg.length = triallength;
cfg.overlap = 0;
evalc('data = ft_redefinetrial(cfg, data);');
fprintf('done! \n')

fprintf('\t artefact calculation \n')
fprintf('\t\t frequency calculation ... ')

freqrange = [2 100];
evalc('freq = bvLL_frequencyanalysis(data, freqrange, output);');

freqFields  = fieldnames(freq);
field2use   = freqFields{not(cellfun(@isempty, strfind(freqFields, 'spctrm')))};

fprintf('done! \n')

fprintf('\t\t artefact determination ... ')
cfg = [];
cfg.betaLim     = betaLim;
cfg.gammaLim    = gammaLim;
cfg.varLim      = varLim;
cfg.invVarLim   = invVarLim;
cfg.kurtLim     = kurtLim;
cfg.zScoreLim   = zScoreLim;
cfg.vMaxLim     = vMaxLim;

evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');
fprintf('done! \n')


if strcmpi(showFigures, 'yes')
    fprintf('\t creating and plotting figures for artefacts \n')
    fprintf('\t\t creating frequency spectrum plot ...')
    
    figure; plot(freq.freq, log10(abs(squeeze(mean(freq.(field2use)))))', 'LineWidth', 2)
    legend(data.label)
    set(gca, 'YLim', [-4 Inf])
        
    fprintf('done! \n')
    
    if strcmpi(saveFigures, 'yes')
        fprintf('\t\t\t saving ... ')
        set(gcf, 'Position', get(0, 'Screensize'));
        saveas(gcf, [PATHS.FIGURES filesep currSubject '_freqDirty.png'])
        fprintf('done! \n')
        close all
    end
    
    % figure;
    fprintf('\t\t creating scrollplot with artefacts in red ... ')
    addpath('~/git/eeg-graphmetrics-processing/figures/')
    cfg = [];
    cfg.badPartsMatrix  = artefactdef.badPartsMatrix;
    cfg.horzLim         = 'full';
    cfg.triallength     = 1;
    cfg.scroll          = 0;
    cfg.visible         = 'on';
    cfg.triallength     = 5;
    scrollPlot          = scrollPlotData(cfg, data);
    fprintf('done! \n')
    

    cfg = [];
    cfg.viewmode = 'vertical';
    ft_databrowser(cfg, oldData);
        
    if strcmpi(saveFigures,'yes')
        fprintf('\t\t\t saving ... ')
        set(gcf, 'Position', get(0,'Screensize'));
        saveas(gcf, [PATHS.FIGURES filesep currSubject '_dataDirty.png'])
        fprintf('done! \n')
        close all
    end
end

badTrialsPerChannel = hist(artefactdef.badPartsMatrix(:,2),1:length(data.label));
pBadTrials = badTrialsPerChannel / size(artefactdef.kurtLevels,2);
chans2remove = data.label(pBadTrials > 0.5);

if ~length(chans2remove) == 0
    fprintf(['\t channels to remove: ' repmat('%s ', 1, length(chans2remove)) '...'], chans2remove{:}) 
            
    if isfield(subjectdata, 'rmChannels')
        subjectdata.rmChannels = cat(1, subjectdata.rmChannels, chans2remove);
        subjectdata.rmChannels = unique(subjectdata.rmChannels);
    else
        subjectdata.rmChannels = chans2remove;
    end
    
    keepChannelIndx = ~ismember(data.label, chans2remove);
    
    cfg = [];
    cfg.channel = find(keepChannelIndx);
    
    if strcmpi(cutOutputData, 'yes');
        
        data = ft_selectdata(cfg, data);
        
        fprintf('\t recalculating artefacts without removed channels \n')
        
        fprintf('\t\t frequency calculation ... ')
        evalc('freq = bvLL_frequencyanalysis(data, freqrange,output);');
        fprintf('done! \n')
        
        fprintf('\t\t artefact determination ... ');
        cfg = [];
        cfg.betaLim     = betaLim;
        cfg.gammaLim    = gammaLim;
        cfg.varLim      = varLim;
        cfg.invVarLim   = invVarLim;
        cfg.kurtLim     = kurtLim;
        cfg.zScoreLim   = zScoreLim;
        
        evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');        
    
    else
        
        evalc('data = ft_selectdata(cfg, oldData);');
        
        
        if strcmpi(showFigures, 'yes');
            fprintf('\t showing cleaned frequency spectrum ... ')
            
            cfg = [];
            cfg.length  = 5;
            cfg.overlap = 0;
            evalc('dataCut = ft_redefinetrial(cfg, data);');
            
            evalc('freq = bvLL_frequencyanalysis(dataCut, freqrange,output);');
            
            figure; plot(freq.freq, log10(abs(squeeze(mean(freq.(field2use)))))', 'LineWidth', 2)
            legend(data.label)
            set(gca, 'YLim', [-4 Inf])
            fprintf('done! \n')
            drawnow;
        end
    end
    fprintf('done! \n')
    %         end
else
    fprintf('\t No channels to REMOVE! \n')
    
    if ~strcmpi(cutOutputData, 'yes');
        data = oldData;
    end
    
end

if strcmpi(rmTrials, 'yes')
    
    fprintf('\t removing artefactridden trials ... ')
    cfg = [];
    cfg.trials = artefactdef.goodTrials;
    evalc('data = ft_selectdata(cfg, data);');
    fprintf('done! \n')
    
    if strcmpi(showFigures, 'yes');
        fprintf('\t creating and plotting cleaned figures \n')
        
        fprintf('\t\t creating clean frequency spectrum plot ... ')
        evalc('freq = bvLL_frequencyanalysis(data, freqrange,output);');
        
        figure; plot(freq.freq, log10(abs(squeeze(mean(freq.(field2use)))))', 'LineWidth', 2)
        legend(data.label)
        set(gca, 'YLim', [-4 Inf])
        fprintf('done! \n')
        
        if strcmpi(saveFigures, 'yes')
            fprintf('\t\t\t saving ... ')
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf, [PATHS.FIGURES filesep currSubject '_freqClean.png'])
            fprintf('done! \n')
            close all
        end
        
        fprintf('\t\t creating clean scrollplot ... ');
        cfg = [];
        cfg.betaLim     = betaLim;
        cfg.gammaLim    = gammaLim;
        cfg.varLim      = varLim;
        cfg.invVarLim   = invVarLim;
        cfg.kurtLim     = kurtLim;
        cfg.zScoreLim   = zScoreLim;
        
        evalc('[artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq);');
        
        % figure;
        addpath('~/git/eeg-graphmetrics-processing/figures/')
        cfg = [];
        cfg.badPartsMatrix  = artefactdef.badPartsMatrix;
        cfg.horzLim         = 'full';
        cfg.triallength     = 1;
        cfg.scroll          = 0;
        cfg.visible         = 'on';
        cfg.triallength     = 5;
        scrollPlot          = scrollPlotData(cfg, data);
        fprintf('done! \n')
        
        if strcmpi(saveFigures, 'yes')
            fprintf('\t\t\t saving ... ')
            set(gcf, 'Position', get(0, 'Screensize'));
            saveas(gcf, [PATHS.FIGURES filesep currSubject '_dataClean.png'])
            fprintf('done! \n')
            close all
        end
        
    end
    
    if strcmpi(saveData, 'yes')
        outputStrPathName = upper(outputStr);

        
        
        dataFilename = [currSubject '_' outputStr '.mat'];
        artefactdefFilename = [currSubject '_artefactdef.mat'];
        subjectdata.PATHS.(outputStrPathName) = [subjectdata.PATHS.SUBJECTDIR filesep dataFilename];
        subjectdata.PATHS.ARTEFACTDEF = [subjectdata.PATHS.SUBJECTDIR filesep artefactdefFilename];
        
        fprintf('\t saving %s ... ', dataFilename)
        save(subjectdata.PATHS.(outputStrPathName), 'data')
        fprintf('done! \n')
        
        fprintf('\t saving %s ... ', artefactdefFilename)
        save(subjectdata.PATHS.ARTEFACTDEF, 'data')
        fprintf('done! \n')
        
        subjectdata.analysisOrder = cat(2, subjectdata.analysisOrder, '-', outputStr);
    end
else
    if strcmpi(saveData, 'yes')
        
        outputStrPathName = upper(outputStr);

        dataFilename = [currSubject '_' outputStr '.mat'];
        subjectdata.PATHS.(outputStrPathName) = [subjectdata.PATHS.SUBJECTDIR filesep dataFilename];
        
        fprintf('\t saving %s ... ', dataFilename)
        save(subjectdata.PATHS.(outputStrPathName), 'data')
        fprintf('done! \n')
        
        subjectdata.analysisOrder = cat(2, subjectdata.analysisOrder, '-', outputStr);
    end
end

fprintf('\t saving Subject.mat ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'] , 'subjectdata')
fprintf('done! \n')

fprintf('\t all done! \n')


close all
clear subjectdata
