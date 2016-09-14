for i = 1:size(Ws,3)
    tmpW1 = Ws(:, :, i);
    for j = 1:size(Ws,3)
        currW1 = tmpW1;
        currW2 = Ws(:, :, j);
        
%         % find removed channels
%         rmChannels = cat(1,allSubjectResults.removedChannels{i}, allSubjectResults.removedChannels{j});
%         if ~isempty(rmChannels)
%             rmChanIndx = find(ismember(allSubjectResults.chanNames, rmChannels));
%             
%             currW1(rmChanIndx,:) = [];
%             currW1(:,rmChanIndx) = [];
%             currW2(rmChanIndx,:) = [];
%             currW2(:,rmChanIndx) = [];
%             
%         end
        
        [currR, currP] = correlateMatrices(currW1, currW2);
        R(i,j) = currR;
        P(i,j) = currP;
    end
end