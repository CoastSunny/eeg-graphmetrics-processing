cfg = [];
cfg.length = 1;
cfg.overlap = 0;
data = ft_redefinetrial(cfg, data);


cfg = [];
cfg.badPartsMatrix  = artefactdef.badPartsMatrix;
cfg.horzLim         = 10;
cfg.triallength     = 1;
cfg.scroll          = 1;
cfg.visible         = 'on';
scrollPlot          = scrollPlotData(cfg, data);