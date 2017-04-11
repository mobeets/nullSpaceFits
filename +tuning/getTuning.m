function [mus, ths, grps] = getTuning(Y, gs, grps)
% find mean activity per group, then fit cosine tuning curve to each dim
    if nargin < 3
        grps = sort(unique(gs(~isnan(gs))));
    end
    assert(size(gs,1) == size(Y,1));
    mus = nan(numel(grps), size(Y,2));
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        mus(ii,:) = nanmean(Y(ix,:));
    end
    ths = nan(size(Y,2), 3);
    for ii = 1:size(Y,2)
        ths(ii,:) = tuning.cosFit(grps, mus(:,ii));
    end
end
