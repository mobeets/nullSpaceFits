function [trgs, atrgs, ps] = findTargetsAndStartPos(blk)

    atrgs = unique(blk.trgpos, 'rows'); % each of 8 targets
    trgs = round(tools.computeAngles(bsxfun(@minus, atrgs, mean(atrgs))));
    trgs = mod(-trgs, 360);
    [trgs,ix] = sort(trgs);
    atrgs = atrgs(ix,:);
    ntrgs = numel(trgs);
    ps = repmat(mean(atrgs), ntrgs, 1); % starting position

end
