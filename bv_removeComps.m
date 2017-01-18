function data = bv_removeComps(cfg, data, comp)


currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
saveData    = ft_getopt(cfg, 'saveData');
outputStr   = ft_getopt(cfg, 'outputStr');
dataStr     = ft_getopt(cfg, 'dataStr');
compStr     = ft_getopt(cfg, 'compStr');

if isempty(currSubject)
    error('no cfg.currSubject given')
end

eval(optionsFcn)

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

disp(subjectdata.subjectName)

if nargin < 3
    try
        [~, filenameComp, ~] = fileparts(subjectdata.PATHS.(compStr));
        
        fprintf('\t loading %s.mat ... ', filenameComp)
        load(subjectdata.PATHS.(compStr))
        fprintf('done! \n')
    catch
        error('No input component variable given and no comp file found at subjectdata.PATHS.COMP')
    end
end

if nargin < 2
    try
        [~, filenameData, ~] = fileparts(subjectdata.PATHS.(dataStr));
        
        fprintf('\t loading %s.mat ... ', filenameData)
        load(subjectdata.PATHS.(dataStr))
        fprintf('done! \n')
    catch
        error('No input data variable given and no data file found at subjectdata.PATHS.PREPROC')
    end
end


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

cfg = [];
cfg.viewmode = 'vertical';
cfg.ylim = [-100 100];
cfg.blocksize = 30;
evalc('ft_databrowser(cfg, data)');

cfg = [];
cfg.component = 1:30; % specify the component(s) that should be plotted
cfg.layout    = 'EEG1010'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
cfg.compscale = 'local';
cfg.interactive = 'no';
figure();
evalc('ft_topoplotIC(cfg, comp);');

fprintf('\t press SPACE after inspecting components \n')
pause;

close all

inputStr = sprintf('\t Input component numbers to be removed, seperated by a comma. ');
rmComps = input(inputStr', 's');

rmComps = strrep(rmComps, ' ', '');

if ~strcmp(rmComps, '')
    badComponents = strsplit(rmComps, ',');
    
    fprintf(['\t removing component(s): ' repmat('%s ',1,length(badComponents)), ...
        ' ... '], badComponents{:})
    
    badComponents = cellfun(@str2num, badComponents);
    subjectdata.removedComps = badComponents;
    
    cfg             = [];
    cfg.component   = badComponents;
    evalc('data            = ft_rejectcomponent(cfg,comp,data);');
    
    fprintf('done! \n')
    
    cRemFilename = [currSubject '_' outputStr '.mat'];
    subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.SUBJECTDIR filesep cRemFilename];
    
    if strcmpi(saveData, 'yes')
        subjectdata.analysisOrder = cat(2, subjectdata.analysisOrder, '-comp');

        fprintf('\t Saving %s ... ', cRemFilename)
        save(subjectdata.PATHS.COMPREMOVED, 'data')
        fprintf('done! \n')
    end
    
else
    subjectdata.PATHS.COMPREMOVED = [subjectdata.PATHS.PREPROC];
end


fprintf('\t Saving Subject.mat ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n')