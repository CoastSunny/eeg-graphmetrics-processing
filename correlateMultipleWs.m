function [R, P] = correlateMultipleWs(Ws1, Ws2)

if nargin < 2
    error('Please add in two sets of correlations matrices')
end

if sum(size(Ws1) == size(Ws2)) ~= length(size(Ws1))
    error('size Ws1 (%s) does not equal size Ws2 (%s)', num2str(size(Ws1)), num2str(size(Ws2)))
end

for iW = 1:size(Ws1,3);
    currW1 = Ws1(:,:,iW);
    currW2 = Ws2(:,:,iW);
    
    rmChanIndxW1 = find(sum(isnan(currW1),2) == size(currW1,1));
    rmChanIndxW2 = find(sum(isnan(currW2),2) == size(currW2,1));
    
    rmChanIndx = [rmChanIndxW1; rmChanIndxW2];
    
    if ~isempty(rmChanIndx)
        currW1(rmChanIndx,:) = [];
        currW1(:,rmChanIndx) = [];
        currW2(rmChanIndx,:) = [];
        currW2(:,rmChanIndx) = [];
    end
    
    if isempty(currW1) || isempty(currW2)
        continue
    end
    
    [currR, currP] = correlateMatrices(currW1, currW2);
    R(iW) = currR;
    P(iW) = currP;
end

