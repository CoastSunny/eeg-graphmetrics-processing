function bv_createResultsFile(cfg)

inputStr    = ft_getopt(cfg, 'inputStr');
optionsFcn  = ft_getopt(cfg, 'optionsFcn', 'setOptions');
pathsFcn    = ft_getopt(cfg, 'pathsFcn', 'setPaths');

eval(optionsFcn)
eval(pathsFcn)

folders = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
nFolders = {folders.name};
subjectNames = cellfun(@(v) v(1:4), nFolders, 'Un', 0);
subjectNames = unique(subjectNames);

noSubject = 0;
for i = 1:length(subjectNames);
    currSubjectName = subjectNames{i};
    disp(currSubjectName)
    
    subjectFolderIndx = not(cellfun(@isempty, strfind(nFolders, currSubjectName)));
    
    switch sum(subjectFolderIndx)
        case 2
            noSession = 0;
            noSubject = noSubject + 1;
            
            for iSession = find(subjectFolderIndx);
                noSession = noSession + 1;
                
                subjectFolderPath = [PATHS.SUBJECTS filesep nFolders{iSession}];
                [subjectdata, connectivity] = bv_check4data(subjectFolderPath, inputStr);
                
                fnames = fieldnames(connectivity);
                spctrmname = fnames(not(cellfun(@isempty, strfind(fnames, 'spctrm'))));
                
                Ws(:,:,:,noSubject, noSession) = connectivity.(spctrmname{:});
                subjects{noSubject} = currSubjectName;
            end
            
        otherwise
            fprintf('\t %1.0f session(s) found, skipping ... \n', ...
                sum(subjectFolderIndx))
            continue
    end
end

dims = 'chan_chan_freq_subj_ses';
chans = connectivity.label;
% subjects = subjectNames;
freq = connectivity.freq;
date = datetime('now');

wpli_debiasedflag = 0;
if sum(strfind(lower(inputStr), 'wpli_debiased'))
    wpli_debiasedflag = 1;
end

if wpli_debiasedflag
    fprintf('saving results file ... ')
    save([PATHS.RESULTS filesep lower(inputStr) '.mat'],'-v7.3', 'Ws', 'dims', 'subjects', 'freq','chans', 'date')
    fprintf('done! \n')
else
    freqRng = connectivity.freqRng;
    fprintf('saving results file ... ')
    save([PATHS.RESULTS filesep lower(inputStr) '.mat'],'-v7.3', 'Ws', 'dims', 'subjects', 'freq', 'freqRng', 'chans', 'date')
    fprintf('done! \n')
end

% switch(inputStr)
%     case 'PLI'
%         freqRng = connectivity.freqRng;
%         
%         fprintf('saving results file ... ')
%         save([PATHS.RESULTS filesep 'pli.mat'],'-v7.3', 'Ws', 'dims', 'subjects', 'freq', 'freqRng', 'chans', 'date')
%         fprintf('done! \n')
%         
%     case 'WPLI_DEBIASED'
%         fprintf('saving results file ... ')
%         save([PATHS.RESULTS filesep 'wpli_debiased.mat'],'-v7.3', 'Ws', 'dims', 'subjects', 'freq','chans', 'date')
%     fprintf('done! \n')
% 
%         
%     case 'WPLI'
%         
%         fprintf('saving results file ... ')
%         save([PATHS.RESULTS filesep 'wpli.mat'],'-v7.3', 'Ws', 'dims', 'subjects', 'freq','chans', 'date')
%         fprintf('done! \n')
% end

