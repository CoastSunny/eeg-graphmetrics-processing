function freq = bvLL_frequencyanalysis(data, freqrange, output)

if nargin < 3
    output = 'powandcsd';
end
if nargin < 2
    error('Please input data')
end
if nargin < 1
    error('Please input config file')
end

cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'hanning';
cfg.output      = output;
cfg.tapsmofrq   = 2;
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.keeptrials  = 'yes';
% cfg.toi         = [min(data.time{1,1}):1/data.fsample:max(data.time{1,1})];
freq = ft_freqanalysis(cfg, data);



