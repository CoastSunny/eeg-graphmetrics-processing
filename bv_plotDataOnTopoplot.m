function bv_plotDataOnTopoplot(W, labels)

if nargin < 1
    error('Input variable W not given')
end
if nargin < 2 
    error('Input variable labels not given')
end

fprintf('preparing layout...')

cfg = [];
cfg.channel  = labels;
cfg.layout   = 'EEG1010';
cfg.feedback = 'no';
cfg.skipcomnt  = 'yes';
cfg.skipscale  = 'yes';
evalc('lay = ft_prepare_layout(cfg);');
fprintf('done \n')

[~, indxSort] = ismember(lay.label, labels);
indxSort = indxSort(indxSort>0);
W = W(indxSort,:);
W = W(:,indxSort);

lay.pos = lay.pos(indxSort,:);
lay.label = lay.label(indxSort);
lay.width = lay.width(indxSort);
lay.height = lay.height(indxSort);

fprintf('creating figure...')

figure;
hold on

if sum(squareform(W))~=0

    W(W>0) = (mat2gray(W(W>0))+0.5).*2;
    
    
    for i = 1:size(W,1)
        for j = 1:size(W,2)
            if W(i,j)==0
                continue
            end
            x = lay.pos([i j],1);
            y = lay.pos([i j],2);
            line(x,y, 'LineWidth', round(W(i,j).*2))
        end
    end

end

scatter(lay.pos(:,1), lay.pos(:,2), 100, 'MarkerFaceColor', 'r')
labeloffset = 0.02;
text(double(lay.pos(:,1))+labeloffset, double(lay.pos(:,2)), lay.label , ...
    'fontsize',10,'fontname','helvetica', ...
    'interpreter','tex','horizontalalignment','left', ...
    'verticalalignment','middle','color','k');
line(lay.outline{1}(:,1), lay.outline{1}(:,2), 'LineWidth', 3)


axis equal
axis off
fprintf('done \n')

