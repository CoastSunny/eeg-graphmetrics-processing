function Wnrm = normalizeW(W)

a = (1-0.001)/(max(W(:))-min(W(:)));
b = 1 - a * max(W(:));
Wnrm = a * W + b;