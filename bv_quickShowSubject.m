function bv_quickShowSubject(str, filestr, cfg)

if nargin < 3
    cfg = [];
end


eval('setOptions')
eval('setPaths')

subject = dir([PATHS.SUBJECTS filesep str '*']);
nSubject = length(subject);

if nSubject ~= 1
    if nSubject == 0
        errorStr = sprintf('Subject with str-input: %s not found', str);
    elseif nSubject > 1
        errorStr = sprintf('Too many subjects found with str-input: %s', str);
    end
    error(errorStr)
end


disp(subject.name)
subjectFolderPath = [PATHS.SUBJECTS filesep subject.name];

[subjectdata, data] = bv_check4data(subjectFolderPath, upper(filestr));


cfg.viewmode = 'vertical';
if length(data.trial) == 1
    cfg.blocksize = 8;
end
fprintf('\t showing %s data \n', upper(filestr))
evalc('ft_databrowser(cfg, data)');
