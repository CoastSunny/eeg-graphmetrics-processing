function Wrandomized = bv_randomizeWeightedMatrices(Ws, m)
% 
% 
Wrandomized = zeros([size(Ws) m]);
counter = 0;
n = size(Ws,3);
for iW = 1:n
    currW = Ws(:,:,iW);

    weights = squareform(currW);
    I = find(weights > 0);
    
    for j = 1:m
        weights(I) = weights(I(randperm(numel(I))));
        Wrandomized(:,:,iW,j) = squareform(weights);
        
        counter = counter + 1;
    end  
    
    if counter ~= m;
        fprintf(repmat('\b',1,length(percStr)))
    end
    percDone = counter / (n * m) * 100;

    percStr = sprintf('%1.0f%%', percDone);
    fprintf([percStr '%']);
end

fprintf('\n')