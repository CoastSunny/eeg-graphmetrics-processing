function L = calculatePathlengthWs(Ws, egdeType)

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
            D=distance_bin(W);
        case 'weighted'
            W(W>0) = 1./W(W>0);
            D=distance_wei(W);
    end
    L(i) = mean(squareform(D));
end
