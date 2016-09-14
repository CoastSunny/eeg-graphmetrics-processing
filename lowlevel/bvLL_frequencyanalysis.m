function freq = bvLL_frequencyanalysis(data, freqrange)

if nargin < 2
    error('Please input data')
end
if nargin < 1
    error('Please input config file')
end

cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'dpss';
cfg.output      = 'pow';
cfg.tapsmofrq   = 4;
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.keeptrials  = 'yes';
freq = ft_freqanalysis(cfg, data);



