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
dataType    = ft_getopt(cfg, 'dataType');

eval(optionsFcn);

files = dir([PATHS.RAWS filesep '*' sDirString '*']);
fileNames = {files.name};

allNamesSplit = cellfun(@(x) strsplit(x,'_'),fileNames,'Un',0);
allFileNames = cellfun(@(v) v(1), allNamesSplit(1,:));
uniqueFileNames = unique(allFileNames, 'stable');

subjectName = uniqueFileNames
% ppIndx = cellfun(@(x) x, strfind(allFileNames, sDirString));
% 
% for iPP = 1:length(ppIndx)
%     subjectNum = regexp(allFileNames{iPP},'\d*','Match');
%     subjectNum = subjectNum{1};
%     
%     if length(subjectNum) < 3
%         subjectNum = cat(2, (repmat(num2str(0), 1, 3 - length(subjectNum))), subjectNum);
%     end
%     
%     subjectName{iPP} = cat(2, sDirString, subjectNum);
% end

% controlLog = not(cellfun(@isempty, strfind(allFileNames, 'C')));
% controlLog = controlLog + not(cellfun(@isempty, strfind(allFileNames, 'c')));
% controlLog = controlLog + not(cellfun(@isempty, strfind(allFileNames, 'MR')));
% controlIndx = find(controlLog);
% 
% for iFile = controlIndx
%     subjectName{iFile} = ['c' subjectName{iFile}];
% end
% uniqueSubjectNames = unique(subjectName, 'stable');

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
    
    
    switch dataType
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
    

    % find out if subject has .stm file. If so, subtract column 4 and store
    % in subjectdata.watched which trial the subject has watched. If not,
    % move subject to removed folder and warn the user
%     try 
%         stmfile = [PATHS.RAWS filesep subjectdata.filename '.stm'];
%         
%         subjectdata.stm           = dlmread(stmfile);
%  
%         notWatchedIdx = find(subjectdata.stm(:,4)==0);
%         watchedIdx = find(subjectdata.stm(:,4)==1);
%         
%         subjectdata.hasstmfile    = 'yes';
%         subjectdata.notwatched    = notWatchedIdx; % subject made a mistake on the first and third trial
%         subjectdata.watched       = watchedIdx;
%         subjectdata.totalwatched  = length(subjectdata.watched);
%     catch
% %         warning('no stm-file found for subject: %s', subjectdata.subjectName)
%         
%         removeIdx = removeIdx + 1;
%         movefile([subjectdata.PATHS.SUBJECTDIR], [PATHS.REMOVED filesep currSubjectName]);
%         
%         subjectdata.PATHS.SUBJECTDIR   = [PATHS.REMOVED filesep currSubjectName];
%         
%         errorstr = 'Subject stm-file not found, moved to removed folder';
%         fprintf(['\t ' errorstr '\n'], currSubjectName)
%         fid = fopen([subjectdata.PATHS.SUBJECTDIR filesep 'WhyRemoved.txt'],'w');
% 
%         fprintf(fid, errorstr);
%         fclose( fid );
%         
%         removeLog{removeIdx, 1} = subjectdata.subjectName;
%         removeLog{removeIdx, 2} = errorstr;
%     end
    
%     controlBool = ~isempty(strfind(subjectdata.filename, 'C')) || ~isempty(strfind(subjectdata.filename, 'c')) || ~isempty(strfind(subjectdata.filename, 'MR'));
%     
%     if controlBool
%         subjectdata.condition = 'control';
%     else
%         subjectdata.condition = 'autism';
%     end
%     
    fprintf('\t saving Subject.mat...')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject'],'subjectdata');
    fprintf('done \n')
    clear subjectdata

end

