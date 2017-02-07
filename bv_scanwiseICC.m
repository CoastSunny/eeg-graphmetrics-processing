function r = bv_scanwiseICC(Ws)

sz = size(Ws);
if sz(end) ~= 2
    error('Scan session dimension not last in Ws. Please redo your Ws dimensions')
end

if sz(1) ~= sz(2)
    error('Your Ws do not consist of square connectivity matrices')
end

if length(sz) > 4
    error('More than 4 dimensions found. Unknown dimension ... ')
end

scAvg = squeeze(nanmean(nanmean(Ws,1),2));
r = ICC(scAvg, '1-k');