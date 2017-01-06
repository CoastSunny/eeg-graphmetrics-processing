function [artefactdef, counts] = bvLL_artefactDetection(cfg, data, freq)

% Get options for artefact detection from cfg-file
betaLim     = ft_getopt(cfg, 'betaLim');
gammaLim    = ft_getopt(cfg, 'gammaLim');
varLim      = ft_getopt(cfg, 'varLim');
invVarLim   = ft_getopt(cfg, 'invVarLim');
kurtLim     = ft_getopt(cfg, 'kurtLim');
rangeLim    = ft_getopt(cfg, 'rangeLim');
zLim        = ft_getopt(cfg, 'zLim');

if (~isempty(betaLim) || ~isempty(gammaLim)) && nargin < 3
    error('detecting artefacts based on frequency power, but no frequency input found in function')
end
if nargin < 2
    error('Please input data')
end
if nargin < 1
    error('Please input config file')
end

doStandardArtefacts = 0;
artefactMethods = {};
if ~isempty(betaLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'betaPower');
end
if ~isempty(gammaLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'gammaPower');
end
if ~isempty(kurtLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'kurtosis');
end
if ~isempty(varLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'variance');
end
if ~isempty(invVarLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'inverseVariance');
end
if ~isempty(rangeLim)
    doStandardArtefacts = 1;
    artefactMethods = cat(2, artefactMethods, 'range');
end

badChannels = [];
badTrials = [];
artefactdef.allCounts = [];
fprintf('\t \t Calculating artefact levels ... ')
if doStandardArtefacts
    if ismember('kurtosis', artefactMethods)
        artefactdef.kurtLevels      = zeros(length(data.label), length(data.trial));
    end
    if ismember('variance', artefactMethods)
        artefactdef.varLevels       = zeros(length(data.label), length(data.trial));
    end
    if ismember('inverseVariance', artefactMethods)
        artefactdef.invVarLevels    = zeros(length(data.label), length(data.trial));
    end
    if ismember('range', artefactMethods)
        artefactdef.invVarLevels    = zeros(length(data.label), length(data.trial));
    end
       
    for i = 1:length(data.trial)
        if ismember('kurtosis', artefactMethods)
            artefactdef.kurtLevels(:,i) = kurtosis(data.trial{i}, [], 2);
        end
        if ismember('variance', artefactMethods)  
            artefactdef.varLevels(:,i) = std(data.trial{i}, [], 2).^2;
        end
        if ismember('inverseVariance', artefactMethods) 
            artefactdef.invVarLevels(:,i) = 1./(std(data.trial{i}, [], 2).^2);
        end
        if ismember('range', artefactMethods)
            artefactdef.rangeLevels (:, i) = max(data.trial{i}, [], 2) - min(data.trial{i}, [], 2);
        end
        
    end
    
    if ismember('kurtosis', artefactMethods)
        
        [badChannelKurt, badTrialKurt] = find(artefactdef.kurtLevels > kurtLim);
        badChannels = [badChannels; badChannelKurt];
        badTrials = [badTrials; badTrialKurt];
        counts.Kurt = hist(badChannelKurt, 1:length(data.label));
        artefactdef.allCounts = [artefactdef.allCounts counts.Kurt'];

    end
    if ismember('variance', artefactMethods)
        
        [badChannelVar, badTrialVar] = find(artefactdef.varLevels > varLim);
        badChannels = [badChannels; badChannelVar];
        badTrials = [badTrials; badTrialVar];
        counts.Var       = hist(badChannelVar, 1:length(data.label));
        artefactdef.allCounts = [artefactdef.allCounts counts.Var'];
        

    end
    if ismember('inverseVariance', artefactMethods)
        
        [badChannelInvVar, badTrialInvVar]  = find(artefactdef.invVarLevels > invVarLim);
        badChannels = [badChannels; badChannelInvVar];
        badTrials = [badTrials; badTrialInvVar];
        counts.InvVar    = hist(badChannelInvVar, 1:length(data.label));
        artefactdef.allCounts = [artefactdef.allCounts counts.InvVar'];
        
    end
    if ismember('range', artefactMethods)
        
        [badChannelRange, badTrialRange]  = find(artefactdef.rangeLevels > rangeLim);
        badChannels = [badChannels; badChannelRange];
        badTrials = [badTrials; badTrialRange];
        counts.Range    = hist(badChannelRange, 1:length(data.label));
        artefactdef.allCounts = [artefactdef.allCounts counts.Range'];
        
    end
end

if doStandardArtefacts


    


    
    if ismember('betaPower', artefactMethods)
        betaStart   = find(freq.freq == 10);
        betaEnd     = find(freq.freq == 25);
        
        artefactdef.betaPower   = squeeze( mean( freq.powspctrm( :, :, betaStart:betaEnd), 3 ) );
        artefactdef.betaPower   = artefactdef.betaPower';
        
        [badChannelBeta, badTrialBeta]  = find(artefactdef.betaPower > betaLim);
        badChannels                     = [badChannels; badChannelBeta];
        badTrials                       = [badTrials; badTrialBeta];
        counts.Beta                     = hist(badChannelBeta, 1:length(data.label));
        artefactdef.allCounts           = [artefactdef.allCounts counts.Beta'];

    end
    if ismember('gammaPower', artefactMethods)
        
        gammaStart  = find(freq.freq == 25);
        gammaEnd    = find(freq.freq == 50);
        
        artefactdef.gammaPower  = squeeze( mean( freq.powspctrm( :, :, gammaStart:gammaEnd), 3 ) );
        artefactdef.gammaPower  = artefactdef.gammaPower';
    
        [badChannelGamma, badTrialGamma]    = find(artefactdef.gammaPower > gammaLim);
        badChannels                         = [badChannels; badChannelGamma];
        badTrials                           = [badTrials; badTrialGamma];
        counts.Gamma                        = hist(badChannelGamma, 1:length(data.label));
        artefactdef.allCounts               = [artefactdef.allCounts counts.Gamma'];
        
    end
end

artefactdef.badPartsMatrix = unique([ badTrials badChannels ], 'rows');

artefactdef.badTrials = unique(badTrials);
artefactdef.goodTrials = 1:size(artefactdef.kurtLevels,2);
artefactdef.goodTrials(ismember(artefactdef.goodTrials, artefactdef.badTrials)) = [];

artefactdef.pBadTrialsPerChannel = ceil(((hist(artefactdef.badPartsMatrix(:,2), 1:length(data.label)))./length(data.trial)) .* 100);
fprintf('done \n')
