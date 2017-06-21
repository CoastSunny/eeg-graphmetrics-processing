function freq = bvLL_frequencyanalysis(data, freqrange, output)

if nargin < 3
    output = 'pow';
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
% cfg.tapsmofrq   = 0.4;
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.keeptrials  = 'yes';
freq = ft_freqanalysis(cfg, data);



