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


fprintf('\t frequency analysis ... ')
cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'dpss';
cfg.output      = output;
cfg.tapsmofrq   = 1;
cfg.foilim      = [freqrange(1) freqrange(2)];
cfg.keeptrials  = 'yes';
evalc('freq = ft_freqanalysis(cfg, data);');
fprintf('done! \n')



