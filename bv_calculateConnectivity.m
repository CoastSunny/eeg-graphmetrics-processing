function connectivity = bv_calculateConnectivity(cfg, data)

inputStr 	= ft_getopt(cfg, 'inputStr');
% outputStr   = ft_getopt(cfg, 'outputStr');
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
    [subjectdata, data] = bv_check4data(subjectFolderPath, inputStr);
    
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
        
        [m,n,p]=size(connectivity.wpli_debiasedspctrm);
        idx=find(speye(m,n));
        xx=reshape(connectivity.wpli_debiasedspctrm,m*n,p);
        xx(idx,:) = 0;

        connectivity.wpli_debiasedspctrm = reshape(xx, m,n,p);
        
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
            
        trueRmChannels = subjectdata.rmChannels(not(ismember(subjectdata.rmChannels, OPTIONS.PREPROC.rmChannels)));
        
        label = cat(1,data.label, trueRmChannels);
        nChans = length(label);
        
        cfg = [];
        cfg.channel  = label;
        cfg.layout   = 'EEG1010';
        cfg.feedback = 'no';
        cfg.skipcomnt  = 'yes';
        cfg.skipscale  = 'yes';
        evalc('lay = ft_prepare_layout(cfg);');
        
        [~, indxSort] = ismember(lay.label, label);
        
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
            cfg.trials = 1:nTrials;
            
            evalc('dataFilt = ft_preprocessing(cfg, data);');
            
            PLIs = PLI(dataFilt.trial,1);
            PLIs = cat(3,PLIs{:});
            W = mean(PLIs,3);
            W(end+1:end+(nChans-size(W,1)), 1:end) = NaN;
            W(1:end, end+1:end+(nChans-size(W,2))) = NaN;
            
            W = W(indxSort, indxSort);
            
            connectivity.plispctrm(:,:,iFreq) = W;
            fprintf('done!\n')
        end
        
        
        
        
        connectivity.dimord = 'chan_chan_freq';
        connectivity.freq = freqLabel;
        connectivity.freqRng = freqRng;
        connectivity.label = data.label;
                
end
        

if strcmpi(saveData, 'yes');
    
    outputFilename = [subjectdata.subjectName '_' method '.mat'];
    fieldname = upper([method]);
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






