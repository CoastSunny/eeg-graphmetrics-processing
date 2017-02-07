 function bv_createSubjectFolders(cfg)
% Create the folder structure necessary to run analyses for baby
% connectivity. Add subject specific strings. Also, add path to
% raw data folder as a string to the function. Copies all necessary files
% from one raw folder into individual subject folders under a subjectdir
% ('./Subjects')
%
% Example:
% Filenames
% /RAW/pp01_gratings.eeg
% /RAW/pp01_gratings.stm
% /RAW/pp01_gratings.vhdr
% /RAW/pp01_gratings.vmrk
% /RAW/pp02_gratings.eeg
% /RAW/pp02_gratings.stm
% /RAW/pp02_gratings.vhdr
% /RAW/pp02_gratings.vmrk
%
% call function: makeFolderStructure('pp','RAW')
%
%
% Copyright (C) 2015-2016, Bauke van der Velde
%
% createSubjectFolders()

overwrite   = ft_getopt(cfg, 'overwrite', 0);
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
pathsFcn    = ft_getopt(cfg, 'pathsFcn');

eval(optionsFcn);
eval(pathsFcn);

files = dir([PATHS.RAWS filesep '*' OPTIONS.sDirString '*']);
fileNames = {files.name};

allNamesSplit = cellfun(@(x) strsplit(x,'_'),fileNames,'Un',0);
allFileNames = cellfun(@(v) v(1), allNamesSplit(1,:));
uniqueFileNames = unique(allFileNames, 'stable');

subjectName = uniqueFileNames;
uniqueSubjectNames = subjectName;

if ~exist(PATHS.SUBJECTS,'dir'); mkdir PATHS.SUBJECTS; end % create, if necessary, Subject folder

removeIdx = 0;
for subjIndex = 1:length(uniqueSubjectNames);
    currSubjectName = uniqueSubjectNames{subjIndex};
    paths2SubjectFolder = [PATHS.SUBJECTS filesep currSubjectName];
    if ~exist(paths2SubjectFolder,'dir')
        mkdir(paths2SubjectFolder); % create, if necessary, individual subject folder
    end
    
    subjectdata.subjectName = currSubjectName;
    disp(subjectdata.subjectName)
    
    subjectdata.PATHS.SUBJECTDIR = [PATHS.SUBJECTS filesep subjectdata.subjectName];
    
    
    switch OPTIONS.dataType
        case 'eeg'
            dataFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.eeg']);
            hdrFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.vhdr']);
    
        case 'bdf'
            dataFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.bdf']);
            hdrFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.bdf']);
    end
            
    subjectdata.PATHS.DATAFILE = [PATHS.RAWS filesep dataFile.name];
    subjectdata.PATHS.HDRFILE = [PATHS.RAWS filesep hdrFile.name];
    [~, subjectdata.filename, ~] = fileparts(subjectdata.PATHS.DATAFILE);
    
    subjectdata.date = date;
    
    fprintf('\t saving Subject.mat...')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject'],'subjectdata');
    fprintf('done \n')
    clear subjectdata

end

