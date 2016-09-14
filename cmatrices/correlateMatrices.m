function [R, P] = correlateMatrices(W1, W2)

W1(isnan(W1)) = 0;
W2(isnan(W2)) = 0;
[R, P] = corrcoef(squareform(W1), squareform(W2));