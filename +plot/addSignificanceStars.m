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

function [inds, lvls] = getSignificantDifferences(errs, baseCol, alphas)
% returns something like {[5,6], [4,6], [3,6], [2,6], [1,6]}
    if nargin < 3
        alphas = [0.05 1e-2 1e-3];
    end
    nd = size(errs,2);
    alphas = alphas/(nd-1); % Bonferroni correction
    inds = {};
    lvls = [];
    for ii = 1:nd
        if ii == baseCol
            continue;
        end
        [H, lvl] = isSignificantlyDifferent(errs(:,ii), ...
            errs(:,baseCol), alphas);
        if H
            inds = [inds [ii baseCol]];
            lvls = [lvls lvl];
        end
    end
end

function [lH, lAlph] = isSignificantlyDifferent(errsA, errsB, alphas)
    alphas = sort(alphas, 'descend');
    lH = false; lAlph = nan;
    for ii = 1:numel(alphas)
        alpha = alphas(ii);
        [P, H] = signrank(errsA, errsB, 'alpha', alpha, 'tail', 'right');
        if ~H
            return;
        else
            lH = H;
            lAlph = alpha;
        end
    end
end
