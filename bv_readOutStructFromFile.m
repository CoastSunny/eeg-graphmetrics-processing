function [output, names] = readOutStructFromFile(cfg)

startSubject    = ft_getopt(cfg, 'startSubject', 1);
endSubject      = ft_getopt(cfg, 'endSubject', 'end');
fields          = ft_getopt(cfg, 'fields');
analysisTree    = ft_getopt(cfg, 'analysisTree');
structFileName  = ft_getopt(cfg, 'structFileName', 'Subject.mat');
structVarFname  = ft_getopt(cfg, 'structVarName', 'subjectdata');
namesOnly       = ft_getopt(cfg, 'namesOnly', 'no');
optionsFcn      = ft_getopt(cfg, 'optionsFcn');

eval(optionsFcn)

subjectFolders = dir([PATHS.SUBJECTS filesep '*' sDirString '*']);
names = {subjectFolders.name};
names = names';            
output = [];

if strcmpi(namesOnly, 'yes') 
    return
end

if ischar(fields)
    fields = {fields};
end

if ischar(startSubject)
    startSubject = find(~cellfun(@isempty, strfind(names, startSubject)));
end
if ischar(endSubject)
    if strcmp(endSubject, 'end')
        endSubject = length(names);
    else
        endSubject = find(~cellfun(@isempty, strfind(names, endSubject)));
    end
end

for iSubject = startSubject:endSubject
    currSubjectName = names{iSubject};
%     disp(currSubjectName)
    try
        load([PATHS.SUBJECTS filesep currSubjectName filesep analysisTree filesep structFileName])
    catch
        error('\t %s file not found for %s', structFileName, currSubjectName)
    end
    
    try
        outputVar = eval(strjoin(['subjectdata', fields], '.'));
    catch
        warning('fields not found for subject %s, continue without value for current subject', currSubjectName)
        continue
    end
    
    if isempty(outputVar)
        continue
    end
    
    switch class(outputVar)
        case 'char'
            if ~exist('output', 'var')
                output = cell(length(subjectFolders), 1);
            end
            output{iSubject} = outputVar;
        case 'struct'
            output.(['Subject_' currSubjectName]) = outputVar;
        case 'double'
            outputVar = reshape(outputVar, [ 1 numel(outputVar) ] );
            if ~exist('output', 'var')
                output = NaN(length(subjectFolders), 1);
            else
                if size(outputVar, 2) > size(output, 2)
                    output = cat(2, output, NaN(length(subjectFolders), size(outputVar, 2) - size(output, 2)));
                end
            end
            output(iSubject,:) = outputVar;
        case 'cell'
            outputVar = reshape(outputVar, [ 1 numel(outputVar) ] );
            if ~exist('output', 'var')
                output = cell(length(subjectFolders), size(outputVar, 2));
            else
                if size(outputVar, 2) > size(output, 2)
                    output = cat(2, output, cell(length(subjectFolders), size(outputVar, 2) - size(output, 2)));
                end
            end
            output(iSubject,1:size(outputVar,2)) = outputVar;
    end
    clear outputVar
end
            
            

            