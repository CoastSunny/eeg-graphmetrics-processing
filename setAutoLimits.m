function setAutoLimits

h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes

data = dataObjs.CData;
mindata = min(nansquareform(data));
maxdata = max(nansquareform(data));

set(gca, 'CLim', [mindata maxdata]);
