function bv_changeRootSubjectFile

eval('setPaths')
eval('setOptions')

sDirs = dir([PATHS.SUBJECTS filesep '*' OPTIONS.sDirString '*']);
sNames = {sDirs.name};

for iSubjects = 1:length(sDirs)
    cSubject = sNames{iSubjects};
    disp(cSubject)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep cSubject];
    subjectdata = bv_check4data(subjectFolderPath);
    
    fnames = fieldnames(subjectdata.PATHS);
    subjectdata.PATHS.SUBJECTDIR = subjectFolderPath;
    
    for iField = 1:length(fnames)
        cField = fnames{iField};
        [~, filename, ext] = fileparts(subjectdata.PATHS.(cField));
        
        if strcmpi(ext, '.mat')
            subjectdata.PATHS.(cField) = [subjectdata.PATHS.SUBJECTDIR filesep filename ext];
            fprintf('\t %s changed \n', cField)
        end
        
        if ~exist(subjectdata.PATHS.(cField), 'file')
            fprintf('\t %s does not exist, removed from subject file \n', cField)
            subjectdata.PATHS = rmfield(subjectdata.PATHS, cField);
        end
    end
    
    fprintf('\t saving Subject.mat file ...')
    save([subjectFolderPath filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
    
end

    
    
