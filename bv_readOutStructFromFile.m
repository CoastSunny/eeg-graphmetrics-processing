function [output, names] = bv_readOutStructFromFile(cfg)

startSubject    = ft_getopt(cfg, 'startSubject', 1);
endSubject      = ft_getopt(cfg, 'endSubject', 'end');
fields          = ft_getopt(cfg, 'fields');
analysisTree    = ft_getopt(cfg, 'analysisTree');
structFileName  = ft_getopt(cfg, 'structFileName');
structVarFname  = ft_getopt(cfg, 'structVarFname');
namesOnly       = ft_getopt(cfg, 'namesOnly', 'no');
parentFolder    = ft_getopt(cfg, 'parentFolder');
optionsFcn      = ft_getopt(cfg, 'optionsFcn');
pathsFcn        = ft_getopt(cfg, 'pathsFcn');

eval(optionsFcn)
eval(pathsFcn)

if ~exist(parentFolder, 'dir')
    error('Cannot find parent folder')
else
    PATHS.PARENTFOLDER = [PATHS.ROOT filesep parentFolder];
end


folders = dir([ PATHS.PARENTFOLDER filesep '*' OPTIONS.sDirString '*']);
names = {folders.name};
names = names';            
output = {};

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
    file2load = dir([PATHS.PARENTFOLDER filesep currSubjectName filesep analysisTree filesep '*' structFileName '*']);
    fileName = file2load.name;
    try
        load([PATHS.PARENTFOLDER filesep currSubjectName filesep analysisTree filesep fileName])
    catch
        error('\t %s file not found for %s', structFileName, currSubjectName)
    end
    
    try
        outputVar = eval(strjoin([structVarFname, fields], '.'));
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
                output = cell(length(folders), 1);
            end
            output{iSubject} = outputVar;
        case 'struct'
            output.(['Subject_' currSubjectName]) = outputVar;
        case 'double'
%             outputVar = reshape(outputVar, [ 1 numel(outputVar) ] );
%             if ~exist('output', 'var')
%                 output = NaN(length(folders), 1);
%             else
%                 if size(outputVar, 2) > size(output, 2)
%                     output = cat(2, output, NaN(length(folders), size(outputVar, 2) - size(output, 2)));
%                 end
%             end
            output{iSubject} = outputVar;
        case 'cell'
            outputVar = reshape(outputVar, [ 1 numel(outputVar) ] );
            if ~exist('output', 'var')
                output = cell(length(folders), size(outputVar, 2));
            else
                if size(outputVar, 2) > size(output, 2)
                    output = cat(2, output, cell(length(folders), size(outputVar, 2) - size(output, 2)));
                end
            end
            output(iSubject,1:size(outputVar,2)) = outputVar;
    end
    clear outputVar
end
            
            

            