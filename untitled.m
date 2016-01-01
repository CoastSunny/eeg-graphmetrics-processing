function bv_splitData(cfg, data)

currSubject = ft_getopt(cfg, 'currSubject')
optionsFcn  = ft_getopt(cfg, 'optionsFcn');


if nargin < 2
    eval(optionsFcn)
    
    subjectFolderPath = PATHS.SUBJECTS
    
    [subjectdata, data] = bv_check4data(subjectFolderPath, 'CLEANED')

