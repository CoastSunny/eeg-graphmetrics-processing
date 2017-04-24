function bv_plotUnitDist(r_unitwise,colors)

if nargin < 2
    colors = [0.25 0.25 0.25];
end


x = [-1:0.1:1];
y = hist(r_unitwise, x);

ynrm = smooth(y/sum(y));

plot(x,ynrm, 'LineWidth', 3, 'color', colors)
