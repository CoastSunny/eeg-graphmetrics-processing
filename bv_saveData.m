function bv_saveData(data, subjectdata, outputStr)

filename = [subjectdata.subjectName '_' outputStr '.mat'];
filePath = [subjectdata.PATHS.SUBJECTDIR filesep filename];
subjectdata.PATHS.(upper(outputStr)) = filePath;

fprintf('\t saving %s ... ', filename)
save(filePath, 'data')
fprintf('done! \n')

fprintf('\t saving Subject.mat ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n');