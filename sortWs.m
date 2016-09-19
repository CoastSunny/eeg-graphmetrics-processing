function sortedWs = sortWs(Ws, origChans, newChans)

if nargin < 3
    error('please input new channel order')
end
if nargin < 2
    error('please input old channel order')
end
if nargin < 1
    error('please input weighted matrices to be sorted')
end

if length(origChans) ~= length(newChans)
    error('original channel order and new trial order not same length')
end

sortIndx = zeros(1,length(origChans));
for iLabel = 1:length(origChans)
    sortIndx(iLabel) = find(ismember(origChans, newChans{iLabel}));
end

sortedWs = Ws(sortIndx, sortIndx, :, :);