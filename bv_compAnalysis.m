 function comp = bv_compAnalysis(cfg, data)

method      = ft_getopt(cfg, 'method', 'runica');
extended    = ft_getopt(cfg, 'extended', 0);
saveData    = ft_getopt(cfg, 'saveData', 1);
outputStr   = ft_getopt(cfg, 'outputStr', 'comp');
inputFile   = ft_getopt(cfg, 'inputFile');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');

if isempty(currSubject)
    error('Please give the subject folder name as cfg.currSubject')
end
if isempty(optionsFcn)
    error(['Please give the path to your options file in cfg.optionsFcn, ' ...
        'find a standard options file at setStandards.m'])
end

if nargin < 2 && isempty(inputFile)
    error('No data input given and no cfg.inputFile given')
elseif nargin == 2 && ~isempty(inputFile)
    error('Both data input and cfg.inputFile given. Please choose one')
end

try 
    eval(optionsFcn)
catch
    error('Options file not found')
end

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

disp(subjectdata.subjectName)

if ~isempty(inputFile)
    try
        load(subjectdata.PATHS.(inputFile))
    catch
        errorStr = sprintf('%s not found', intputFile);
        error(errorStr)
    end
end

subjectdata.cfgs.(outputStr) = cfg;

fprintf('\t calculating component analysis ... ')

cfg = [];
cfg.method              = method;
cfg.(method).extended   = 0;
cfg.(method).pca        = rank([data.trial{:}]);
evalc('comp = ft_componentanalysis(cfg, data);');

fprintf('done! \n')

compFilename = [currSubject '_' outputStr '.mat'];

if strcmpi(saveData, 'yes')
    fprintf('\t saving comp file and Subject.mat ... ')

    subjectdata.PATHS.COMP = [subjectdata.PATHS.SUBJECTDIR filesep compFilename];
    save(subjectdata.PATHS.COMP, 'comp')
    
    analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    analysisOrder = [analysisOrder outputStr];
    analysisOrder = unique(analysisOrder, 'stable');
    subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    fprintf('done! \n')
end

fprintf('\t saving Subject.mat file ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n')