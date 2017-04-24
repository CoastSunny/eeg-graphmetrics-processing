function bv_plotDataOnTopoplot(datalabel, vect, labels)


fprintf('preparing layout...')
cfg = [];
cfg.channel  = datalabel;
cfg.layout   = 'EEG1010';
cfg.feedback = 'yes';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');
fprintf('done \n')

[~, indxSort] = ismember(lay.label, labels);

vect = vect(indxSort);

fprintf('creating figure...')
maxVect = max(vect);

plotVect = vect*(1000/maxVect);

figure; scatter(lay.pos(:,1), lay.pos(:,2), plotVect)

labeloffset = 0.04;
text(double(lay.pos(:,1))+labeloffset, double(lay.pos(:,2)), lay.label , ...
    'fontsize',10,'fontname','helvetica', ...
    'interpreter','tex','horizontalalignment','left', ...
    'verticalalignment','middle','color','k');
line(lay.outline{1}(:,1), lay.outline{1}(:,2))
axis equal
axis off
fprintf('done \n')