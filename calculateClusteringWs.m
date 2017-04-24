function C = calculateClusteringWs(Ws, edgeType)

m = size(Ws, 3);
C = zeros(1, m);
for i = 1:m
    W = Ws(:,:,i);
    
    % find removed channels
    rmChannels = sum(isnan(W))==(size(W,2) - 1);
    if ~isempty(rmChannels)
        
        W(rmChannels,:) = [];
        W(:,rmChannels) = [];
        
    end
    
    W(isnan(W)) = 0;
    
    if isempty(W)
        C(i) = NaN;
        continue
    end
    
    switch edgeType
        case 'binary'
            C(i) = mean(clustering_coef_bu(W));
        case 'weighted'
%             Wnrm = weight_conversion(W, 'normalize');
            C(i) = mean(clustering_coef_wu(W));
    end
end