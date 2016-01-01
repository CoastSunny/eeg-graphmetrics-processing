function varargout = gr_calculateMetrics(Ws, edgeType, graphMetric)

n = size(Ws,4);
m = size(Ws,5);

for iGrph = 1:length(graphMetric)
    grMetric = graphMetric{iGrph};
    
    fprintf('\t Calculating %s ... ', grMetric)
    
    for i = 1:n
        for j = 1:m
            currWs = Ws(:,:,:,i,j);
            
            switch grMetric
                case 'CC'
                    lng = printPercDone(n*m, i);
                    varargout{iGrph}(:,i,j) = calculateClusteringWs(currWs, edgeType);
                    fprintf(repmat('\b', 1, lng))

                    
                case 'CPL'
                    lng = printPercDone(n*m, i);
                    varargout{iGrph}(:,i,j) = calculatePathlengthWs(currWs, edgeType);
                    fprintf(repmat('\b', 1, lng))
                case 'S'
%                     lng = printPercDone(n*m, i);
                    CCIndx = find(ismember(graphMetric, 'CC'));
                    CPLIndx = find(ismember(graphMetric, 'CPL'));
                    
                    currCC = varargout{CCIndx}(:,i,j);
                    currCPL = varargout{CPLIndx}(:,i,j);
                    
                    varargout{iGrph}(:,i,j) = ...
                        calculateSmallworldnessWs(currWs, currCPL, currCC, edgeType);            
%                     fprintf(repmat('\b', 1, lng))
            end
        end
    end
    fprintf('done! \n')
end
