function output = bv_summarizeGraphResults(str, field)

resultFiles = dir([str '*.mat']);
resultNames = {resultFiles.name};

for i = 1:length(resultNames)
    currResult = resultNames{i};
    disp(currResult)
    currName = strsplit(currResult, '_');
    currName = currName{end};
    currName = strsplit(currName, '.');
    currName = currName(1);
    output(i).freqband = currName{:};
    
    fprintf('\t loading ... ')
    load(currResult)
    fprintf('done! \n')
    
    fnames = fieldnames(results);
    
    for j = 1:length(fnames)
        currField = fnames{j};
        eval([ 'output(i).(currField) = results.' currField]);
    end
end
