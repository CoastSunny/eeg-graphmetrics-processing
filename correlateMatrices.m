function [R, P] = correlateMatrices(W1, W2)

if numel(W1) ~= numel(W2)
    error('different matrix sizes')
else
    ncols = size(W1, 2);
    W1(1:ncols+1:end) = 0;
    W2(1:ncols+1:end) = 0;
end

[R, P] = corr(squareform(W1)', squareform(W2)', 'rows', 'pairwise');