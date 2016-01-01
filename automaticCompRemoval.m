function [rmComp, succeeded] = automaticCompRemoval(data, comp)


clear R
ring1 = not(cellfun(@isempty, strfind(data.label, 'Fp')));
ring2 = not(cellfun(@isempty, strfind(data.label, 'AF')));
ring3 = not(cellfun(@isempty, regexp(data.label, '^F[1234567890z]')));
ring4 = not(cellfun(@isempty, regexp(data.label, '^FC[1234567890z]')));
ring5 = not(cellfun(@isempty, regexp(data.label, '^C[1234567890z]')));
% ring6 = not(cellfun(@isempty, regexp(data.label, '^CP[1234567890z]'))) ...
%     | not(cellfun(@isempty, regexp(data.label, '^TP[78910]')));
prefrontalIndx = ring1 | ring2 ;
frontalIndx = ring1 | ring2 | ring3 | ring4 | ring5;

trialdata   = [data.trial{:}];
frontaldata = trialdata(frontalIndx,:);
compdata    = [comp.trial{:}];

R = corr(trialdata', compdata');

[~, sortIndx] = sort(mean(abs(R(prefrontalIndx,:))), 'descend');

load('~/git/eeg-graphmetrics-processing/templates/blinkTopo.mat')

i = 1;
succeeded = 1;
while 1
    
    if i > min([10 length(sortIndx)]);
        fprintf('\n \t automatic component removal failed, please manually select components to be removed')
        succeeded = 0;
        rmComp = [];
        break
    end
    
    currComp = sortIndx(i);
    
    R1 = mean(abs(R(ring1,currComp)));
    R2 = mean(abs(R(ring2,currComp)));
    R3 = mean(abs(R(ring3,currComp)));
    R4 = mean(abs(R(ring4,currComp)));
    R5 = mean(abs(R(ring5,currComp)));
    
    if R1 > R2 && R2 > R3 && R3 > R4 && R2 > R5
        rmComp = currComp;
        break
    end
   
    i = i + 1;
end
