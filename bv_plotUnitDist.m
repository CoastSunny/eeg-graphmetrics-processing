function fig = bv_plotUnitDist(r_unitwise)

fig = figure;

x = [-1:0.1:1];
y = hist(r_unitwise, x);

ynrm = y/sum(y);

plot(x,ynrm, 'LineWidth', 3, 'color', [0.25 0.25 0.25])
