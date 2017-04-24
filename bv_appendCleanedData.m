function data = bv_appendCleanedData(cfg)

currSubject = ft_getopt(cfg, 'currSubject');
inputStr    = ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
saveData    = ft_getopt(cfg, 'saveData');

disp(currSubject)

eval('setOptions');
eval('setPaths');

subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
[subjectdata, dataOld] = bv_check4data(subjectFolderPath, inputStr);

fprintf('\t appending cleaned data based on data.sampleinfo ... ')
fsample = dataOld.fsample;

startTrial = dataOld.sampleinfo(:,1);
endTrial = dataOld.sampleinfo(:,2);
trialinfo = dataOld.trialinfo;

tmptrl(:,1) = startTrial(find([1; diff(startTrial) ~= fsample]));
tmptrl(:,2) = endTrial(find([diff(startTrial) ~= fsample; 1]));

tmptrialinfo = dataOld.trialinfo(ismember(dataOld.sampleinfo(:,1), tmptrl(:,1)));

% contrials = (diff([startTrial; inf]) == fsample);
% contrials = contrials .* ~abs(diff([0; dataOld.trialinfo]));
% startsample = startTrial(diff(contrials) == 1);
% endsample = endTrial(diff(contrials) == -1);
% 
% starttrialinfo = trialinfo(diff(contrials) == 1);
% 
% startsample2 = startTrial((diff([0; startTrial]) == fsample) == 0);
% starttrialinfo2 = trialinfo(diff(contrials) == 0);
% ex = ~ismember(startsample2, startsample);
% startsample2 = startsample2(ex);
% starttrialinfo2 = starttrialinfo2(ex);
% endsample2 = endTrial((diff([0; startTrial]) == fsample) == 0);
% endsample2 = endsample2(ex);
% 
% [startsampleEnd, indx] = sort([startsample; startsample2]);
% endsampleEnd = sort([endsample; endsample2]);
% trialinfoEnd = [starttrialinfo; starttrialinfo2];
% trialinfoEnd = trialinfoEnd(indx);

trl = [tmptrl zeros(length(tmptrialinfo),1) tmptrialinfo];

contSecs = (diff(tmptrl, [], 2) + 1) / fsample;

cfg = [];
cfg.trl = trl;
evalc('data = ft_redefinetrial(cfg, dataOld);');
fprintf('done! \n')

data.contSecs = contSecs;

if strcmpi(saveData, 'yes')
    
    bv_saveData(data, subjectdata, outputStr)
    
end

    

