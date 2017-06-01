function dataOld = bv_cutAppendedIntoTrials(cfg)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');
triallength = ft_getopt(cfg, 'triallength');

disp(currSubject)

eval('setOptions');
eval('setPaths');

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
[subjectdata, dataOld] = bv_check4data(subjectFolderPath, inputStr);

trialparts2use = find(dataOld.contSecs > triallength);

if isempty(trialparts2use)
    fprintf('\t \t no trials found, skipping ... ')
    return;
end

sampleinfo = [];
trialinfo = [];
for i = 1:length(trialparts2use)
    trl = trialparts2use(i);
    nTrls = floor(dataOld.contSecs(trl) / triallength);
    
    for j = 1:nTrls
        currsampleinfoStart = (dataOld.sampleinfo(trl,1) + triallength*dataOld.fsample*(j-1));
        currsampleinfoEnd = dataOld.sampleinfo(trl,1) + triallength*dataOld.fsample*(j) - 1;
        currsampleinfo = [currsampleinfoStart currsampleinfoEnd];
        
        sampleinfo = cat(1, sampleinfo, currsampleinfo);
        trialinfo = cat(1, trialinfo, dataOld.trialinfo(trl));
        
    end
end

fprintf('\t %1.0f trials found \n', length(trialinfo))

trl = [sampleinfo zeros(size(sampleinfo,1),1) trialinfo];

fprintf('\t redefining triallength to %1.0fs ... ', triallength)
cfg = [];
cfg.trl = trl;
evalc('data = ft_redefinetrial(cfg, dataOld);');
fprintf('done! \n')

if strcmpi(saveData, 'yes')
    
    bv_saveData(data, subjectdata, outputStr)
    
end

