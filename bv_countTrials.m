function nTrls = bv_countTrials(cfg)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');

disp(currSubject)

eval('setOptions');
eval('setPaths');

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
[subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);

nTrls = length(data.trial);

