function data = bvLL_preprocessing(cfg)

% get options for preprocessing from cfg file
hpfilter    = ft_getopt(cfg, 'hpfilter', 1);
hpfreq      = ft_getopt(cfg, 'hpfreq', 2);
bsfilter    = ft_getopt(cfg, 'bsfilter', 1);
bsfreq      = ft_getopt(cfg, 'bsfreq', [48 52; 98 102]);
resample    = ft_getopt(cfg, 'resampling', 0);
resamplefs  = ft_getopt(cfg, 'resamplefs');
headerfile  = ft_getopt(cfg, 'headerfile');
dataset     = ft_getopt(cfg, 'dataset');
trigger     = ft_getopt(cfg, 'trigger');
channels    = ft_getopt(cfg, 'channels');
reref       = ft_getopt(cfg, 'reref');
refElectrode  = ft_getopt(cfg, 'refElectrode');
trialfun    = ft_getopt(cfg, 'trialfun');

cfg = [];
cfg.channel     = channels;
cfg.headerfile  = headerfile;
cfg.dataset     = dataset;

hdr = ft_read_header(cfg.headerfile);
cfg.Fs = hdr.Fs;
cfg.trigger = trigger;
cfg.padding = 1;
cfg.continuous = 'no';

% create trials
cfg.trialfun    = trialfun;
evalc('cfg = ft_definetrial(cfg);');

% create filters
if bsfilter
    cfg.bsfilter    = 'yes';
    cfg.bsfreq      = bsfreq;
end

if hpfilter
    cfg.hpfilter    = 'yes';
    cfg.hpfreq      = hpfreq;
end

if reref
    cfg.reref           = 'yes';
    if strcmp(refElectrode, 'noBadChannels')
        if isfield(subjectdata, 'removedchannels')
            removedChannels = strcat('-', subjectdata.removedchannels);
            channelString = cat(2,'all',removedChannels');
            cfg.refchannel = channelString;
        else
            error('cfg.refElectrode: noBadChannels selected, but no removedchannels field detected in the subject.mat file')
        end
    else
        cfg.refchannel  = refElectrode;
    end
end
    
fprintf('\t preprocessing ... ')
evalc('data = ft_preprocessing(cfg);');
fprintf('done \n')

if resample
    fprintf('\t \t resampling from %d to %d Hz ... ', hdr.Fs, resamplefs)
    cfg = [];
    cfg.resamplefs  = resamplefs;
    cfg.detrend     = 'yes';
    cfg.demean      = 'yes';
    
    evalc('data = ft_resampledata(cfg, data);');
    fprintf('done! \n')
end

