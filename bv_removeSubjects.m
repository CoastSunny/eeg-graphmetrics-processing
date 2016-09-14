function removeSubjects

optionsFcn = ft_getopt(cfg, 'optionsFcn');

eval(optionsFcn)

% cfg = [];
% cfg.startSubject = 1;
% cfg.endSubject = 'end';
% cfg.analysisTree = [];
% cfg.structFileName = 'Subject.mat';
% cfg.structVarFname = 'subjectdata';
% cfg.fields = {'removedchannels'};
% [rmChannelsAllSubjects, names] = readOutStructFromFile(cfg);
    
cfg.fields = {'cleaned', 'withBadChannels', 'condition11'};
[cleanTrialsNonSocial] = readOutStructFromFile(cfg);

cfg.fields = {'cleaned', 'withBadChannels', 'condition12'};
[cleanTrialsSocial] = readOutStructFromFile(cfg);

ppn = cellfun(@(x) x(1:5), names, 'Un', 0);
uniquePPN = unique(ppn);

removedSubjectDir = PATHS.REMOVED;
removedQCDir      = [PATHS.QCDir filesep 'removed'];

if ~exist(removedQCDir, 'dir')
    mkdir(removedQCDir)
end
if ~exist(removedSubjectDir, 'dir')
    mkdir(removedSubjectDir)
end

PPN2BeRemoved = zeros(1, length(uniquePPN));

for iUniquePPN = 1:length(uniquePPN)
    ppnName = uniquePPN{iUniquePPN};
    disp(ppnName)
    ppnIndx = not(cellfun(@isempty, strfind(names, ppnName)));

    while 1
        if sum(not(cellfun(@isempty, strfind(names, ppnName)))) < 2
            errorstr = 'removing, less than 2 sessions available \n';
            fprintf(['\t ' errorstr])
            
            rmPPNs = names(ppnIndx);
            removingSubjects(rmPPNs, errorstr, removedQCDir, removedSubjectDir)
            break
        end
        
        rmChannels = rmChannelsAllSubjects(ppnIndx,:);
        rmChannels = rmChannels(not(cellfun(@isempty, rmChannels)));
        rmChannels = unique(rmChannels);
        if length(rmChannels) > 2
            errorstr = 'too many channels removed over sessions, removing subject all together \n';
            fprintf(['\t ' errorstr])
            
            rmPPNs = names(ppnIndx);
            removingSubjects(rmPPNs, errorstr, removedQCDir, removedSubjectDir)
            break
        end
        
        if min(cleanTrialsNonSocial(ppnIndx)) < 5
            errorstr = 'less than 5 non social trials, removing subject all together \n';
            fprintf(['\t ' errorstr])
            
            rmPPNs = names(ppnIndx);
            removingSubjects(rmPPNs, errorstr, removedQCDir, removedSubjectDir)
            break
        end
        
        if min(cleanTrialsSocial(ppnIndx)) < 5
            errorstr = 'less than 5 social trials, removing subject all together \n';
            fprintf(['\t ' errorstr])
            
            rmPPNs = names(ppnIndx);
            removingSubjects(rmPPNs, errorstr, removedQCDir, removedSubjectDir)
            break
        end
        
        fprintf(' \t everything is in order, not removing \n')
        
        break
    end    
end        

fclose('all');

function removingSubjects(rmPPNs, errorstr, removedQCDir, removedSubjectDir)
setStandards()

for irmPPN = 1:length(rmPPNs)
    currrmPPN = rmPPNs{irmPPN};
    movefile([PATHS.SUBJECTS filesep currrmPPN], [removedSubjectDir filesep currrmPPN])
    movefile([PATHS.QCDir filesep currrmPPN], [removedQCDir filesep currrmPPN])
    
    fid = fopen([removedSubjectDir filesep currrmPPN filesep 'WhyRemoved.txt'],'w');
    fprintf(fid, errorstr);
    fclose( fid );
    fid = fopen([removedQCDir filesep currrmPPN filesep 'WhyRemoved.txt'],'w');
    fprintf(fid, errorstr);
    fclose( fid );
end
    