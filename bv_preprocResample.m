function [ data ] = bv_preprocResample(cfg)
% bv_preprocResample reads-in, preprocesses (and resample) raw EEG data,
% based on FT_PREPROCESSING of the fieldtrip toolbox and applies several
% user-specified preprocessing steps to the signals. The function uses
% subject information (stored in an individual Subject.mat file) gathered 
% with the BV_CREATESUBJECTFOLDERS, so please run that function first.
% Order of preprocessing: 
%           1) resampling 
%           2) filtering 
%           3) rereferencing
%
% Use as
% [ data ] = bv_preprocResample( cfg )
%
% The input argument cfg is a configuration structure, which contains all
% details for the preprocessing of the dataset. 
%
% Input arguments that should always be specified in the configuration
% structure
%   cfg.currSubject     = 'string': subject folder name of the subject to
%                           be analyzed
%   cfg.pathsFcn        = 'string': filename of m-file to be read with all 
%                           necessary paths to run this function (default: 
%                           'setPaths'). Take care to add your trialfun 
%                           to your matlab path). For an example options 
%                           fcn see setPaths.m
%   cfg.trialfun        = 'string': filename of trialfun to be used for
%                           the preprocessing (take care to add your
%                           trialfun to your matlab path). See for example
%                           TRIALFUN_YOUTH_3Y
%   cfg.saveData        = 'string': specifies whether data needs to be
%                           saved to personal folder ('yes' or 'no', 
%                           default: 'yes')
%   cfg.outputStr       = 'string': addition to filename when saving, so
%                           that the output filename becomes [currSubject 
%                           outputStr .mat]. Outputstr is also used used to
%                           save path two outputfile in the individuals
%                           Subject.mat file (default: 'preproc')
%
% Input arguments that should be specified when resampling data
%   cfg.resampleFs      = [ number ]: specify new sampling rate (default:
%                           no resampling)
%
% Input arguments that should be specified when filtering data
%   cfg.hpfreq          = [ number ]: high-pass filter frequency cut-off,
%                           (default: no high-pass filtering)
%   cfg.lpfreq          = [ number ]: low-pass filter frequency cutt-off,
%                           (default: no low-pass filtering)
%   cfg.notchfreq       = [ number ]: notch filter frequency, (default: no
%                           notch filter)
%   cfg.filttype        = 'string': filter type, possible options 'but'
%                           (two-pass butterworth filter) or 'firws' (fir
%                           windowed sync). (default: 'but')
%
% Input arguments that should be specified when referencing data
%   cfg.reref           = 'string': specifies whether data needs to be
%                           rereferenced ('yes' or 'no', default: 'no')
%   cfg.refelec         = 'string' or { cell }: with EEG rereference 
%                           channel(s), can be 'all' for common average
%                           reference (default: 'all')
%
%
% Optional input arguments
%   cfg.rmChannels      = 'string' or { cell }: Nx1 cell-array with 
%                           channels to be removed before preprocessing 
%                           (default = {}), see FT_CHANNELSELECTION for 
%                           extra details
%
% See also BV_CREATESUBJECTFOLDERS, TRIALFUN_YOUTH_3Y, FT_CHANNELSELECTION, 
% FT_PREPROCESSING,FT_RESAMPLEDATA 

% read in data from configuration file and (if necessary) set defaults
currSubject = ft_getopt(cfg, 'currSubject');
pathsFcn    = ft_getopt(cfg, 'pathsFcn');
trialfun    = ft_getopt(cfg, 'trialfun');
saveData    = ft_getopt(cfg, 'saveData', 'yes');
outputStr   = ft_getopt(cfg, 'outputStr', 'preproc');
resampleFs  = ft_getopt(cfg, 'resampleFs');
hpfreq      = ft_getopt(cfg, 'hpfreq');
lpfreq      = ft_getopt(cfg, 'lpfreq');
notchfreq   = ft_getopt(cfg, 'notchfreq');
filttype    = ft_getopt(cfg, 'filttype', 'but');
reref       = ft_getopt(cfg, 'reref', 'no');
refelec     = ft_getopt(cfg, 'refelec', 'all');
rmChannels  = ft_getopt(cfg, 'rmChannels');

eval(pathsFcn) % get paths necessary to run function
analysisOrd = {};

% Try to load in individuals Subject.mat. If unknown throw error.
try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

subjectdata.cfgs.(outputStr) = cfg; % save used config file in subjectdata
subjectdata.rmChannels = rmChannels'; % save possible removed channels in subjectdata

disp(subjectdata.subjectName)
fprintf('\t Setting up for preprocessing ... ')

hdrfile = subjectdata.PATHS.HDRFILE;
dataset = subjectdata.PATHS.DATAFILE;

% read in data (without possible removed channels)
cfg = [];
if ~isempty(rmChannels)
    cfg.channel = cat(2,'EEG', strcat('-',rmChannels));
else
    cfg.channel = cat(2,'EEG');
end

cfg.dataset = dataset;
cfg.headerfile = hdrfile;
cfg.continuous = 'yes';
% cfg.demean = 'yes';
% cfg.detrend = 'yes';
evalc('data = ft_preprocessing(cfg);');

% order channels based on location
cfg = [];
cfg.channel  = data.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);'); % get standard channel sort, use evalc to prevent additional messages on command line

% sort current dataset based on standard
[~, indxSort] = ismember(lay.label, data.label);
data.label = data.label(indxSort);
data.trial = cellfun(@(x) x(indxSort,:), data.trial, 'Un', 0);
fprintf('done! \n')

% *** Resampling (if a resampleFs is given)
if ~isempty(resampleFs)
    
    % important steps to take to ensure sample info can be used after
    % resampling. 1) adding a channel to the original data that contains
    % sample indices of the original data set (1:ntotsamples). 2)
    % downsampling causes this sample indices also to be downsampled.
    % Therefore giving yout he mapping between the new and the old samples
    % (see https://mailman.science.ru.nl/pipermail/fieldtrip/2016-March/010263.html)
    
    data.trial{1}(end+1,:) = data.sampleinfo(1):data.sampleinfo(2);
    data.label{end+1} = 'sample'; % also add a label for this extra vector
    
    % resample (with detrend)
    fprintf('\t Resampling data from %s to %s ... ', num2str(data.fsample), num2str(resampleFs))
    cfg = [];
    cfg.resamplefs  = resampleFs;
    cfg.detrend     = 'yes';

    evalc('data = ft_resampledata(cfg, data);');
    
    fprintf('done! \n')
    
    % correct poor resampling of first and last sampling indices
    sampleLine = data.trial{1}(end,:);
    incorrectResampleIndx = abs(diff(sampleLine)) > 2*2048/512;
    
    incorrectResampleIndx = [1 incorrectResampleIndx+1];
    
    for i = 1:length(incorrectResampleIndx)
        data.trial{1}(end,incorrectResampleIndx(i)) = (incorrectResampleIndx(i)-1)*2048/512 + 1;
    end
    
    
    oldSampleInfo = data.trial{1}(end,:); % save resampled sampling indices for laster use.
    data.trial{1}(end,:) = []; % remove sample channel from data
    data.label(end) = [];
   
    analysisOrd = [analysisOrd, 'res']; % managing analysis order to be saved later
   
end

% *** Filtering data (if a hpfreq, lpfreq, or notchfreq is given)
fprintf('\t Filtering data  ... \n')
fprintf('\t\t')
cfg = []; % create new configuration structure
if ~isempty(hpfreq) % high-pass filter configuration
    cfg.hpfilter            = 'yes';
    cfg.hpfreq              = hpfreq;
    cfg.hpfilttype          = filttype;
    cfg.hpinstabilityfix    = 'reduce'; % set to overcome problems with filter order
    
    fprintf('hpfilter: %1.1f ', hpfreq)
    
    if strcmpi(filttype, 'firws')
        cfg.hpfiltord  = floor(2048*4.8);
    end
end
if ~isempty(lpfreq) % low-pass filter configuration
    cfg.lpfilter            = 'yes';
    cfg.lpfreq              = lpfreq;
    cfg.lpfilttype          = filttype;
    cfg.lpinstabilityfix    = 'reduce';
    
    fprintf('lpfilter: %1.1f ', lpfreq)
    
    if strcmpi(filttype, 'firws')
        cfg.hpfiltord  = floor(2048*4.8);
    end
end

if ~isempty(notchfreq) % notch filter configuration
    cfg.bsfilter    = 'yes';
    maxFreq         = data.fsample / 2;
    
    % create a notchfilter for all the resonance frequencies of given notch
    % filter. The notch filter is created as a bandstop filter with the two
    % limits chosen as the given notchfreq +/- 2 
    for i = 1: (maxFreq / notchfreq)
        bsFreq(i,:) = [notchfreq*i - 2, notchfreq*i + 2];
    end
    
    fprintf('notchfilter: %1.1f ', notchfreq)
    
    cfg.bsfilter    = 'yes';
    cfg.bsfreq      = bsFreq;
    cfg.bsfilttype  = 'but';
    cfg.bsinstabilityfix    = 'reduce';
    
    if strcmpi(filttype, 'firws')
        cfg.bsfiltord  = floor(2048*4.8);
    end
    
end

cfg.padding = 10; % set padding to limit edge effects of filter (not really important if you load in continuous data) 

evalc('data = ft_preprocessing(cfg, data);');

analysisOrd = [analysisOrd, 'filt']; % managing analysis order to save later 


fprintf('done!\n')
% *** cut data into trials based on trialfun
% Your trialfun detects the epochs in your data and adds them to a trl
% variable. It's very important that if you've resampled your data, you use your 
% updated sample info. See for example trialfun_YOUth_3Y
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
    
    analysisOrd = [analysisOrd, 'trial']; % managing analysis order to save later
    
    fprintf('done!\n')
end

% **** rereferencing data if necessary
if strcmpi(reref, 'yes')
    
    fprintf('\t rereferencing data ... ')
    cfg = [];
    cfg.reref = 'yes';
    cfg.refchannel = refelec;
    evalc('data = ft_preprocessing(cfg,data);');
    fprintf('done! \n')
    
    analysisOrd = [analysisOrd, 'reref'];
    
end
    
% **** saving data
if strcmpi(saveData, 'yes');
    subjectdata.PATHS.PREPROC = [subjectdata.PATHS.SUBJECTDIR ...
    filesep subjectdata.subjectName '_' outputStr '.mat']; % add path of preproc file to subjectdata
    
    fprintf('\t saving data to %s ... ', [subjectdata.subjectName '_' outputStr '.mat'])
    save(subjectdata.PATHS.PREPROC, 'data')
    fprintf('done! \n')
    
    subjectdata.analysisOrder = strjoin(analysisOrd, '-'); % add analysis order so far to subjectdata
end


fprintf('\t saving Subject.mat ... ')
save([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'], ...
    'subjectdata')
fprintf('done! \n')