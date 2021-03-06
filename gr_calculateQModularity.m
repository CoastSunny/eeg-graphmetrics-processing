function [Ci, Q] = gr_calculateQModularity(Ws, egdeType)

n = size(Ws,1);
m = size(Ws, 3);

L = zeros(1, size(Ws,3));
for i = 1:m
    W = Ws(:,:,i);
    % find removed channels
    rmChannels = sum(isnan(W)) == (size(W,2) - 1);
    if ~isempty(rmChannels)
        
        W(rmChannels,:) = [];
        W(:,rmChannels) = [];
        
    end
    
    switch egdeType
        case 'binary'
            [Ci(:,i),Q(i)] = modularity_und(W);
        case 'weighted'
            [Ci(:,:,i),Q(i)] = modularity_und(W);
    end
end
