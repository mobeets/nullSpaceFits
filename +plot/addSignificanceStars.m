function addSignificanceStars(errs, baseCol, fig, starSize)
%
    if nargin < 3
        fig = gcf;
    end
    if nargin < 4
        starSize = 20;
    end
    
    [inds, lvls] = getSignificantDifferences(errs, baseCol);
    plot.sigstar(inds, lvls, 0, true);
    
    % edit star size
    h = findall(fig, 'Tag', 'sigstar_stars');
    for ii = 1:numel(h)
        h(ii).FontSize = starSize;
    end
    
end

function [inds, lvls] = getSignificantDifferences(errs, baseCol)
% returns something like {[5,6], [4,6], [3,6], [2,6], [1,6]}
    nd = size(errs,2);
    inds = {};
    lvls = [];
    for ii = 1:nd
        if ii == baseCol
            continue;
        end
        [H, lvl] = isSignificantlyDifferent(errs(:,ii), errs(:,baseCol));
        if H
            inds = [inds [ii baseCol]];
            lvls = [lvls lvl];
        end
    end
end

function [lastH, lastAlph] = isSignificantlyDifferent(errsA, errsB, alphas)
    if nargin < 3
        alphas = [0.05 1e-2 1e-3];
    end
    alphas = sort(alphas, 'descend');
    lastH = false; lastAlph = nan;
    for ii = 1:numel(alphas)
        alpha = alphas(ii);
        [P, H] = signrank(errsA, errsB, 'alpha', alpha);
        if ~H
            return;
        else
            lastH = H;
            lastAlph = alpha;
        end
    end
end
