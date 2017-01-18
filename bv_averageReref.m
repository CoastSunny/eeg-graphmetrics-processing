function data = bv_averageReref(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
saveData    = ft_getopt(cfg, 'saveData');
outputStr   = ft_getopt(cfg, 'outputStr');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
refElectrode = ft_getopt(cfg, 'refElectrode');

eval(optionsFcn)

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

disp(subjectdata.subjectName)


if nargin < 2
    try
        load(subjectdata.PATHS.(inputStr))
    catch
        error('no input data variable given and subjectdata.PATHS.COMPREMOVED does not exist')
    end
else
    if ~isempty(inputStr)
        error('Both input data variable and path name variable given. Please choose one')
    end
end


fprintf('\t rereferencing data ...', currSubject)

cfg = [];
cfg.reref = 'yes';
cfg.refchannel = refElectrode;
evalc('data = ft_preprocessing(cfg,data);');

fprintf('done! \n')

if strcmpi(saveData, 'yes')
    outputFilename = [ currSubject '_' outputStr '.mat'];
    subjectdata.PATHS.REREF = [subjectdata.PATHS.SUBJECTDIR filesep outputFilename];
    subjectdata.analysisOrder = cat(2, subjectdata.analysisOrder, '-reref');
    
    fprintf('\t saving preproc data to %s ... ', outputFilename)
    save([subjectdata.PATHS.REREF], 'data')
    fprintf('done! \n')
end

fprintf('\t saving Subject.mat file ... ' )
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n')