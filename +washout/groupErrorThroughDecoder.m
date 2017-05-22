function errs = groupErrorThroughDecoder(es, gs, grps)
    if nargin < 3
        grps = tools.thetaCenters;
    end
    
    % confirm gs are angles between 0 and 360
%     assert(min(gs) >= 0);
%     assert(max(gs) <= 360);
%     assert(abs(range(gs) - 360) <= 45);
    
    % error is average angular error from gs, per group    
    gsa = tools.thetaGroup(gs, grps);
    errs = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = gsa == grps(ii);
        errs(ii,:) = nanmean(es(ix));
    end
end
