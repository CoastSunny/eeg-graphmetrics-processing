function connectivity = bv_calculateConnectivity(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
outputStr   = ft_getopt(cfg, 'outputStr');
currSubject = ft_getopt(cfg, 'currSubject');
optionsFcn  = ft_getopt(cfg, 'optionsFcn');
freqOutput  = ft_getopt(cfg, 'freqOutput','fourier');
saveData    = ft_getopt(cfg, 'saveData');
nTrials     = ft_getopt(cfg, 'nTrials','all');
method      = ft_getopt(cfg, 'method');

if nargin < 2
    disp(currSubject)
    
    eval(optionsFcn)
    eval('setOptions')
    
    subjectFolderPath = [PATHS.SUBJECTS filesep currSubject];
    try
        [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    catch
        fprintf('\t previous data not found, skipping ... \n')
        connectivity = [];
        return
    end
    
    subjectdata.cfgs.(method) = cfg;
    
end



switch(method)
    case 'wpli_debiased'
        
        
        
        fprintf('\t frequency analysis started ... ')
        cfg = [];
        cfg.method      = 'mtmfft';
        cfg.taper       = 'hanning';
        cfg.output      = freqOutput;
        cfg.keeptrials  = 'yes';
        %         cfg.keeptapers  = 'yes';
        cfg.tapsmofrq   = 2;
        if strcmpi(nTrials, 'all')
            cfg.trials  = 'all';
        else
            cfg.trials      = 1:nTrials;
        end
        evalc('freq            = ft_freqanalysis(cfg, data);');
        fprintf('done! \n')
        
        fprintf('\t connectivity analysis started ... ')
        cfg = [];
        cfg.method  = 'wpli_debiased';
        evalc('connectivity = ft_connectivityanalysis(cfg, freq);');
        fprintf('done! \n')
        
        if not(isempty(subjectdata.rmChannels))
            trueRmChannels = subjectdata.rmChannels(not(ismember(subjectdata.rmChannels, OPTIONS.PREPROC.rmChannels)));
            connectivity = addRemovedChannels(connectivity, trueRmChannels);
        end
        
        connectivity.wpli_debiasedspctrm = bv_setDiag(connectivity.wpli_debiasedspctrm, 0);
        
    case 'wpli'
        
        fprintf('\t frequency analysis started ... ')
        cfg = [];
        cfg.method      = 'mtmfft';
        cfg.taper       = 'hanning';
        cfg.output      = freqOutput;
        cfg.keeptrials  = 'yes';
        %         cfg.keeptapers  = 'yes';
        cfg.tapsmofrq   = 2;
        cfg.trials      = 1:nTrials;
        evalc('freq            = ft_freqanalysis(cfg, data);');
        fprintf('done! \n')
        
        fprintf('\t connectivity analysis started ... ')
        cfg = [];
        cfg.method  = 'wpli';
        evalc('connectivity = ft_connectivityanalysis(cfg, freq);');
        fprintf('done! \n')
        
        connectivity.wplispctrm = abs(connectivity.wplispctrm);
        
    case 'pli'
                
        freqLabel = {'delta', 'theta', 'alpha1', 'alpha2', 'beta', 'gamma'};
        freqRng = {[1 3], [3 6], [6 9], [9 12], [12 25], [25 40]};
        
        for iFreq = 1:length(freqLabel)
            currFreq = freqLabel{iFreq};
            currFreqRng = freqRng{iFreq};
            
            fprintf('\t calculating PLI for %s Hz...', currFreq)
            
            cfg = [];
            cfg.lpfilter = 'yes';
            cfg.lpfreq = currFreqRng(2);
            cfg.hpfilter = 'yes';
            cfg.hpfreq = currFreqRng(1);
            if strcmpi(nTrials, 'all')
                cfg.trials  = 'all';
            else
                cfg.trials      = 1:nTrials;
            end
            
            evalc('dataFilt = ft_preprocessing(cfg, data);');
            
            PLIs = PLI(dataFilt.trial,1);
            PLIs = cat(3,PLIs{:});
            W = mean(PLIs,3);
            
            connectivity.plispctrm(:,:,iFreq) = W;
            fprintf('done!\n')
        end
        
        connectivity.dimord = 'chan_chan_freq';
        connectivity.freq = freqLabel;
        connectivity.freqRng = freqRng;
        connectivity.label = data.label;
              
        if not(isempty(subjectdata.rmChannels))
            trueRmChannels = subjectdata.rmChannels(not(ismember(subjectdata.rmChannels, OPTIONS.PREPROC.rmChannels)));
            connectivity = addRemovedChannels(connectivity, trueRmChannels);
        end
        
        connectivity.plispctrm = bv_setDiag(connectivity.plispctrm, 0);
       
end


if strcmpi(saveData, 'yes');
    
    outputFilename = [subjectdata.subjectName '_' outputStr '.mat'];
    fieldname = upper(outputStr);
    subjectdata.PATHS.(fieldname) = [subjectdata.PATHS.SUBJECTDIR filesep ...
        outputFilename];
    
    fprintf('\t saving %s ... ', outputFilename)
    save(subjectdata.PATHS.(fieldname), 'connectivity')
    fprintf('done! \n')
    
    analysisOrder = strsplit(subjectdata.analysisOrder, '-');
    analysisOrder = [analysisOrder method];
    analysisOrder = unique(analysisOrder, 'stable');
    subjectdata.analysisOrder = strjoin(analysisOrder, '-');
    
    
    fprintf('\t saving subjectdata variable to Subject.mat ... ')
    save([subjectdata.PATHS.SUBJECTDIR filesep 'Subject.mat'], 'subjectdata')
    fprintf('done! \n')
    
end


function connectivity = addRemovedChannels(connectivity, trueRmChannels)

connectivity.label = cat(1,connectivity.label, trueRmChannels);

fnames = fieldnames(connectivity);
fname2use = fnames{not(cellfun(@isempty, strfind(fnames, 'spctrm')))};

currSpctrm = connectivity.(fname2use);
startRow = (size(currSpctrm,1) + 1);
endRow = (size(currSpctrm,1)) + length(trueRmChannels);
currSpctrm(1:size(currSpctrm,1), startRow:endRow, :) = NaN;
currSpctrm(startRow:endRow, 1:size(currSpctrm,2), :) = NaN;

cfg = [];
cfg.channel  = connectivity.label;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');

[~, indxSort] = ismember(lay.label, connectivity.label);

currSpctrm = currSpctrm(indxSort, indxSort,:);
connectivity.label = connectivity.label(indxSort);
connectivity.(fname2use) = currSpctrm;




