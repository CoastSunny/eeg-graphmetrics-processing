function fig = topoplotWrapper(dat, chans, lim) 

if nargin < 3
    lim = [min(dat), max(dat)];
end

% cfg = [];
% cfg.channel  = chans;
% cfg.layout   = 'EEG1010';
% cfg.feedback = 'no';
% cfg.skipcomnt  = 'yes';
% cfg.skipscale  = 'yes';
% evalc('lay = ft_prepare_layout(cfg);');
% 
% chanX = lay.pos(:,1);
% chanY = lay.pos(:,2);
% 
% opt = {'interpmethod','v4','interplim','mask','gridscale',1000,'outline',lay.outline, ...
%     'shading','flat','isolines',10,'mask', lay.mask ,'style','isofill', 'conv', 'off', 'datmask', [], ...
%     'clim', [min(dat) max(dat)]};
% 
% fig = figure;
% ft_plot_topo(chanX,chanY,dat,opt{:});

evalc('chanlocs = readlocs(''/Users/Bauke/Matlab_Toolboxes/EEG/eeglab13_6_5b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'');');

[~, order] = ismember(chans, {chanlocs.labels});

fig = figure;
topoplot(dat, chanlocs(order), 'colormap', colormap('parula'), 'plotdisk', 'on', 'style', 'both', 'conv', 'on', 'gridscale', 1000);

set(gca, 'CLim', lim)
colorbar

axis equal
axis off