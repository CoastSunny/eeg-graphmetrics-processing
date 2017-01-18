function connectivity = bv_calculateConnectivity(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
freqOutput  = ft_getopt(cfg, 'freqOutput');
saveData    = ft_getopt(cfg, 'saveData');

eval(optionsFcn)

try
    load([PATHS.SUBJECTS filesep currSubject filesep 'Subject.mat'])
catch
    error('Subject.mat file not found')
end

disp(subjectdata.subjectName)

if nargin < 2
    try
        [~, filenameData, ~] = fileparts(subjectdata.PATHS.(inputStr));
        
        fprintf('\t loading %s ... ', [filenameData '.mat'])
        load(subjectdata.PATHS.(inputStr))
        fprintf('done! \n')
    catch
        error('No input data variable given and inputStr not given / found')
    end
end

data.label = cat(1,data.label, subjectdata.rmChannels);
for iTrl = 1:length(data.trial)
    data.trial{iTrl}(size(data.trial{iTrl},1)+1:size(data.trial{iTrl},1)+length(subjectdata.rmChannels), :) = NaN;
end

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

fprintf('\t frequency analysis started ... ')
cfg = [];
cfg.method      = 'mtmfft';
cfg.taper       = 'hanning';
cfg.output      = freqOutput;
cfg.keeptrials  = 'yes';
cfg.tapsmofrq   = 2;
evalc('freq            = ft_freqanalysis(cfg, data);');
fprintf('done! \n')
% freqFields  = fieldnames(freq);
% field2use   = freqFields{not(cellfun(@isempty, strfind(freqFields, 'spctrm')))};
%
% figure; plot(freq.freq, log10(abs(real(squeeze(mean(freq.(field2use)))))))

fprintf('\t connectivity analysis started ... ')
cfg = [];
cfg.method  = 'wpli_debiased';
evalc('connectivity = ft_connectivityanalysis(cfg, freq);');
fprintf('done! \n')

if strcmpi(saveData, 'yes');
    
    outputFilename = [subjectdata.subjectName '_' outputStr '.mat'];
    fieldname = upper(outputStr);
    subjectdata.PATHS.(fieldname) = [subjectdata.PATHS.SUBJECTDIR filesep ...
        outputFilename];
    
    fprintf('\t saving %s ... ', outputFilename)
    save(subjectdata.PATHS.(fieldname), 'connectivity')
    fprintf('done! \n')
end

fprintf('\t saving subjectdata variable to Subject.mat ... ')
save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
fprintf('done! \n')





