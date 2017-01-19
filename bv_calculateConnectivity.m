function connectivity = bv_calculateConnectivity(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
freqOutput  = ft_getopt(cfg, 'freqOutput','fourier');
saveData    = ft_getopt(cfg, 'saveData');

if nargin < 2
    disp(currSubject)
    
    eval(optionsFcn)
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
    subjectdata.cfgs.(outputStr) = cfg;
    
    trueRmChannels = ft_channelselection({'all','-M1', '-M2'}, subjectdata.rmChannels);
    
    data.label = cat(1,data.label, trueRmChannels);
    for iTrl = 1:length(data.trial)
        data.trial{iTrl}(size(data.trial{iTrl},1)+1:size(data.trial{iTrl},1)+length(trueRmChannels), :) = NaN;
    end

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
    
    analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    analysisOrder = [analysisOrder outputStr];
    analysisOrder = unique(analysisOrder, 'stable');
    subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    
    fprintf('\t saving subjectdata variable to Subject.mat ... ')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
    
end






