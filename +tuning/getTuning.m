function [mus, grps] = getTuning(Y, gs, NB, RB, grps)
    if nargin < 3
        NB = []; RB = [];
    end
    if nargin < 5
        grps = sort(unique(gs(~isnan(gs))));
    end
    if ~isempty(NB)        
        Y = [Y*RB Y*NB];
    end
    assert(size(gs,1) == size(Y,1));
    mus = nan(numel(grps), size(Y,2));
    for ii = 1:numel(grps)
        ix = gs == grps(ii);
        mus(ii,:) = nanmean(Y(ix,:));
    end
end
