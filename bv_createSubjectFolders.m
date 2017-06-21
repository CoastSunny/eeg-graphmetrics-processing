 function bv_createSubjectFolders(cfg)
% bv_createSubjectFolders creates the folder structure necessary to run 
% analyses for infant EEG and adds an individual Subject.mat file in each
% folder with individuals information and paths to important files. 
% Currently set-up to find the following datatype: 'bdf', 'eeg'. Set used 
% datatype in your setOptions file. Creates subject folders with a name based 
% on the raw data filename, by using as foldername the  part of the 
% filename before the first dash ('_'). f.e. 'A12345_raw.bdf' becomes 
% subjectname: 'A12345'
%
% Use as:
%  bv_createSubjectFolders(cfg)
%
% The input argument cfg is a configuration structure, which contains all
% details for the create subject folders.
%
% Possible inputarguments in configuration structure:
%   cfg.optionsFcn      = 'string', filename to options m-file. (default:
%                           'setOptions'). For example see
%                           setOptions_empty.
%   cfg.pathsFcn        = 'string', filename to paths m-file. (default:
%                           'setPaths'). For example see
%                           setPaths_empty.
%
% Saves an Subject.mat file, with a subjectdata structure with the
% following fields:
%   subjectdata.subjectName         = 'string', given name of the subject 
%   subjectdata.date                = 'string', time and data of creation
%   subjectdata.filename            = 'string', filename of dataset
%
%   subjectdata.PATHS               = .structure., with paths to all important
%                                       files
%   subjectdata.PATHS.SUBJECTDIR    = 'string', path to subjectdirectory
%   subjectdata.PATHS.DATAFILE      = 'string', path to dataset
%   subjectdata.PATHS.HDRFILE       = 'string', path to headerfile
%
%
% Copyright (C) 2015-2017, Bauke van der Velde
%
% See also SETPATHS_EMPTY, SETOPTIONS_EMPTY

% read out from configuration structure
optionsFcn  = ft_getopt(cfg, 'optionsFcn','setOptions');
pathsFcn    = ft_getopt(cfg, 'pathsFcn','setPaths');

% load in standard options and paths
eval(optionsFcn);
eval(pathsFcn);

% detect raw eeg files based on path to raws and the subject search string
% (OPTIONS.sDirString)
files = dir([PATHS.RAWS filesep '*' OPTIONS.sDirString '*']);
fileNames = {files.name};

% split the filenames at the dases and select the first part
allNamesSplit = cellfun(@(x) strsplit(x,'_'),fileNames,'Un',0);
allFileNames = cellfun(@(v) v(1), allNamesSplit(1,:));
uniqueFileNames = unique(allFileNames, 'stable');

subjectName = uniqueFileNames;
uniqueSubjectNames = subjectName;

if ~exist(PATHS.SUBJECTS,'dir'); mkdir PATHS.SUBJECTS; end % create, if necessary, Subject folder

removeIdx = 0;
for subjIndex = 1:length(uniqueSubjectNames);
    
    currSubjectName = uniqueSubjectNames{subjIndex}; % find current subject name
    paths2SubjectFolder = [PATHS.SUBJECTS filesep currSubjectName]; % create a path to current subject folder
    if ~exist(paths2SubjectFolder,'dir')
        mkdir(paths2SubjectFolder); % create, if necessary, individual subject folder
    end
    
    subjectdata.subjectName = currSubjectName;
    disp(subjectdata.subjectName)
    
    subjectdata.PATHS.SUBJECTDIR = [PATHS.SUBJECTS filesep subjectdata.subjectName]; % save path to subject folder in subjectdata
    
    
    switch OPTIONS.dataType % find raw EEG files (can be 'bdf' or 'eeg' datatype')
        case 'eeg'
            dataFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.eeg']); 
            hdrFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.vhdr']);
    
        case 'bdf'
            dataFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.bdf']);
            hdrFile = dir([PATHS.RAWS filesep uniqueFileNames{subjIndex}  '*.bdf']);
    end
            
    subjectdata.PATHS.DATAFILE = [PATHS.RAWS filesep dataFile.name]; % save both dataset and hdrfile to subjectdata structures
    subjectdata.PATHS.HDRFILE = [PATHS.RAWS filesep hdrFile.name];
    [~, subjectdata.filename, ~] = fileparts(subjectdata.PATHS.DATAFILE);
    
    subjectdata.date = date;
    
    fprintf('\t saving Subject.mat...')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject'],'subjectdata'); % save individual subjectdata structure to individual folder
    fprintf('done \n')
    clear subjectdata

end

