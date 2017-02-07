function data = bv_removeComps(cfg, data, comp)

currSubject         = ft_getopt(cfg, 'currSubject');
optionsFcn          = ft_getopt(cfg, 'optionsFcn');
saveData            = ft_getopt(cfg, 'saveData');
outputStr           = ft_getopt(cfg, 'outputStr');
dataStr             = ft_getopt(cfg, 'dataStr');
compStr             = ft_getopt(cfg, 'compStr');
automaticRemoval    = ft_getopt(cfg, 'automaticRemoval');
saveFigure          = ft_getopt(cfg, 'saveFigure');

if strcmpi(automaticRemoval, 'yes')
    automaticFlag = 1;
else
    automaticFlag = 0;
end

if nargin < 3
    
    disp(currSubject)
    eval(optionsFcn)
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    
    if isempty(dataStr)
        error('cfg.dataStr not given while also no data input variable given')
    end
    if isempty(compStr)
        error('cfg.compStr not given while also no data input variable given')
    end
    if isempty(currSubject)
        error('no cfg.currSubject while also no data/comp input variable given')
    end
    
    [subjectdata, data, comp] = bv_check4data(subjectFolderPath, dataStr, compStr);
end

oldcfg = cfg;

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

if automaticFlag
    fprintf('\t automatic blink component removal started ... ')
    [rmComps, automaticFlag] = automaticCompRemoval(data,comp);
    fprintf('done! \n')
end

if ~automaticFlag
    
    fprintf('\t preparing layout...')
    cfg = [];
    cfg.channel  = data.label;
    cfg.layout   = 'EEG1010';
    cfg.feedback = 'no';
    cfg.skipcomnt  = 'yes';
    cfg.skipscale  = 'yes';
    evalc('lay = ft_prepare_layout(cfg);');
    fprintf('done! \n')
    
    fprintf('\t showing components ... \n')
    
    cfg = [];
    cfg.viewmode = 'component';
    cfg.layout = lay;
    cfg.ylim = [-2000 2000];
    cfg.blocksize = 30;
    evalc('ft_databrowser(cfg, comp)');
    set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
    
    % cfg = [];
    % cfg.viewmode = 'vertical';
    % cfg.ylim = [-100 100];
    % cfg.blocksize = 30;
    % evalc('ft_databrowser(cfg, data)');
    
    cfg = [];
    cfg.component = 1:30; % specify the component(s) that should be plotted
    cfg.layout    = 'EEG1010'; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    cfg.compscale = 'local';
    cfg.interactive = 'no';
    figure();
    evalc('ft_topoplotIC(cfg, comp);');
    set(gcf, 'units', 'normalized', 'Position', [xScreenLength/2 yScreenLength xScreenLength/2 yScreenLength])
    
    fprintf('\t press SPACE after inspecting components \n')
    pause;
    
    close all
    
    inputStr = sprintf('\t Input component numbers to be removed, seperated by a comma. ');
    rmComps = input(inputStr', 's');
    
    rmComps = strrep(rmComps, ' ', '');
    rmComps = strsplit(rmComps, ',');
    
    rmComps = str2double(rmComps);
    
end

if ~isnan(rmComps)
    
    rmCompIndx = rmComps;
    if rmCompIndx > 20
        rmCompIndx = 21;
    end
    
    cfg = [];
    cfg.badPartsMatrix  = [ones(length(rmComps), 1), rmCompIndx'];
    cfg.horzLim         = 60;
    cfg.scroll          = 0;
    cfg.visible         = 'on';
    cfg.channel         = unique([1:20, rmComps]);
    fig1 = scrollPlotData(cfg, comp);
    set(gcf, 'units', 'normalized', 'Position', [xScreenLength/2 yScreenLength xScreenLength/2 yScreenLength])
    
    cfg = [];
    cfg.component = rmComps; % specify the component(s) that should be plotted
    cfg.layout    = 'EEG1010'; % specify the layout file that should be used for plotting
    cfg.comment   = 'no';
    cfg.compscale = 'local';
    cfg.interactive = 'no';
    fig2 = figure();
    evalc('ft_topoplotIC(cfg, comp);');
    set(gcf, 'units', 'normalized', 'Position', [0 0 xScreenLength/2 yScreenLength])
    
    if strcmpi(saveFigure, 'yes');
        
        filename = [currSubject '_badComponentsTrial.png'];
        fprintf('\t saving figure to %s... ', filename)
        saveas(fig1, [PATHS.FIGURES filesep filename])
        fprintf('done! \n');
        
        filename = [currSubject '_badComponentsTopo.png'];
        fprintf('\t saving figure to %s... ', filename)
        saveas(fig2, [PATHS.FIGURES filesep filename])
        fprintf('done! \n');
        close all
    end
    
    
    
    
    badComponents = strread(num2str(rmComps),'%s');
    
    fprintf(['\t removing component(s): ' repmat('%s ',1,length(badComponents)), ...
        ' ... '], badComponents{:})
    
    badComponents = cellfun(@str2num, badComponents);
    oldcfg.removedComps = badComponents;
    
    cfg             = [];
    cfg.component   = badComponents;
    evalc('data            = ft_rejectcomponent(cfg,comp,data);');
    
    fprintf('done! \n')
      
    if strcmpi(saveData, 'yes')
        
        cRemFilename = [currSubject '_' outputStr '.mat'];
        subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.SUBJECTDIR filesep cRemFilename];
        
        fprintf('\t Saving %s ... ', cRemFilename)
        save(subjectdata.PATHS.COMPREMOVED, 'data')
        fprintf('done! \n')
        
        analysisOrder = strsplit(subjectdata.analysisOrder, '-');
        analysisOrder = [analysisOrder outputStr];
        analysisOrder = unique(analysisOrder, 'stable');
        subjectdata.analysisOrder = strjoin(analysisOrder, '-');
        
        subjectdata.cfgs.(outputStr) = oldcfg;
        fprintf('\t Saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
        fprintf('done! \n')
    end
else
    if strcmpi(saveData, 'yes')
        
        subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.PREPROC];
        subjectdata.cfgs.(outputStr) = oldcfg;
        fprintf('\t Saving Subject.mat ... ')
        save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
        fprintf('done! \n')
    end
end
