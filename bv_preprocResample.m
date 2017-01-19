function data = bv_preprocResample(cfg)

resampleFs  = ft_getopt(cfg, 'resampleFs');
trialfun    = ft_getopt(cfg, 'trialfun');
hpfreq      = ft_getopt(cfg, 'hpfreq');
notchfreq   = ft_getopt(cfg, 'notchfreq');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
filttype    = ft_getopt(cfg, 'filttype', 'but');
outputStr   = ft_getopt(cfg, 'outputStr', 'preproc');
saveData    = ft_getopt(cfg, 'saveData', 'yes');
refElectrode= ft_getopt(cfg, 'refElectrode');
reref       = ft_getopt(cfg, 'reref', 'no');
rmChannels  = ft_getopt(cfg, 'rmChannels');
lpfreq      = ft_getopt(cfg, 'lpfreq');

cfgSave = [];

eval(optionsFcn)

analysisOrd = {};

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

subjectdata.cfgs.(outputStr) = cfg;

disp(subjectdata.subjectName)

fprintf('\t Setting up for preprocessing ... ')

hdrfile = subjectdata.PATHS.HDRFILE;
dataset = subjectdata.PATHS.DATAFILE;

subjectdata.rmChannels = rmChannels';

cfg = [];
cfg.channel = cat(2,'EEG', strcat('-',rmChannels));
cfg.dataset = dataset;
cfg.headerfile = hdrfile;
cfg.continuous = 'yes';
cfg.demean = 'yes';
cfg.detrend = 'yes';
evalc('data = ft_preprocessing(cfg);');

cfg = [];
cfg.channel  = data.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');

[~, indxSort] = ismember(lay.label, data.label);

data.label = data.label(indxSort);
data.trial = cellfun(@(x) x(indxSort,:), data.trial, 'Un', 0);

fprintf('done! \n')

if ~isempty(resampleFs)
    
    data.trial{1}(end+1,:) = data.sampleinfo(1):data.sampleinfo(2);
    data.label{end+1} = 'sample';
    
    
    fprintf('\t Resampling data from %s to %s ... ', num2str(data.fsample), num2str(resampleFs))
    
    
    cfg = [];
    cfg.resamplefs = resampleFs;
    %     cfg.sampleindex = 'yes';
    % cfg.outputfile = 'preproc_resampled.mat';
    evalc('data = ft_resampledata(cfg, data);');
    
    fprintf('done! \n')
    
    sampleLine = data.trial{1}(end,:);
    incorrectResampleIndx = find(not(round(diff(sampleLine)) == 2048/512));
    
    incorrectResampleIndx = [1 incorrectResampleIndx+1];
    
    for i = 1:length(incorrectResampleIndx)
        data.trial{1}(end,incorrectResampleIndx(i)) = (incorrectResampleIndx(i)-1)*2048/512 + 1;
    end
    
    oldSampleInfo = data.trial{1}(end,:);
    data.trial{1}(end,:) = [];
    data.label(end) = [];
   
    analysisOrd = [analysisOrd, 'res'];
    
end

fprintf('\t Filtering data  ... ')

cfg = [];
if ~isempty(hpfreq)
    cfg.hpfilter            = 'yes';
    cfg.hpfreq              = hpfreq;
    cfg.hpfilttype          = filttype;
    cfg.hpinstabilityfix    = 'reduce';
    
    if strcmpi(filttype, 'firws')
        cfg.hpfiltord  = floor(2048*4.8);
    end
end
if ~isempty(lpfreq)
    cfg.lpfilter            = 'yes';
    cfg.lpfreq              = lpfreq;
    cfg.lpfilttype          = filttype;
    cfg.lpinstabilityfix    = 'reduce';
    
    if strcmpi(filttype, 'firws')
        cfg.hpfiltord  = floor(2048*4.8);
    end
end

if ~isempty(notchfreq)
    cfg.bsfilter    = 'yes';
    maxFreq         = data.fsample / 2;
    for i = 1: (maxFreq / notchfreq)
        
        bsFreq(i,:) = [notchfreq*i - 2, notchfreq*i + 2];
    end
    
    cfg.bsfilter    = 'yes';
    cfg.bsfreq      = bsFreq;
    cfg.bsfilttype  = 'but';
    cfg.bsinstabilityfix    = 'reduce';
    
%     if strcmpi(filttype, 'firws')
%         cfg.bsfiltord  = floor(2048*4.8);
%     end
    
end

evalc('data = ft_preprocessing(cfg, data);');

analysisOrd = [analysisOrd, 'filt'];


fprintf('done!\n')

if ~isempty(trialfun)
    fprintf('\t Redefining trialstructure based on %s ...', trialfun)
    
    subjectdata.trialfun = trialfun;
    
    cfg = [];
    cfg.dataset = dataset;
    cfg.headerfile = hdrfile;
    cfg.trialfun = trialfun;
    cfg.Fs = resampleFs;
    cfg.oldsampledata = oldSampleInfo;
    evalc('cfg = ft_definetrial(cfg)');
    evalc('data = ft_redefinetrial(cfg, data);');
    
    analysisOrd = [analysisOrd, 'trial'];
    
    fprintf('done!\n')
end

if strcmpi(reref, 'yes')
    
    fprintf('\t rereferencing data ... ')
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = refElectrode;
    evalc('data = ft_preprocessing(cfg,data);');
    fprintf('done! \n')
    
    analysisOrd = [analysisOrd, 'reref'];
    
end
    
if strcmpi(saveData, 'yes');
    subjectdata.PATHS.PREPROC = [subjectdata.PATHS.SUBJECTDIR ...
    filesep subjectdata.subjectName '_' outputStr '.mat'];
    
    fprintf('\t saving data to %s ... ', [subjectdata.subjectName '_' outputStr '.mat'])
    save(subjectdata.PATHS.PREPROC, 'data')
    fprintf('done! \n')
    
    subjectdata.analysisOrder = strjoin(analysisOrd, '-');
end


fprintf('\t saving Subject.mat ... ')
save([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'], ...
    'subjectdata')
fprintf('done! \n')