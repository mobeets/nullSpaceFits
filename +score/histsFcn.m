function [Hs, Xs] = histsFcn(Ys, gs, useFirstForRange)
% make histograms for Ys across a common range
%
% n.b. when making hists for display,
%   we will want to restrict range of Xs to only the first hyp,
%   and also we will want to have first rotated the NB via PCA
% 
    if nargin < 3
        useFirstForRange = false;
    end
    nbins = score.optimalBinCount(Ys{1}, gs);
    Xs = getHistRange(Ys, nbins, gs, useFirstForRange);
    Hs = cell(numel(Ys),1);
    for ii = 1:numel(Ys)
        Hs{ii} = score.marginalHist(Ys{ii}, gs, Xs);
    end
end

function Xs = getHistRange(Ys, nbins, gs, useFirstForRange)
    grps = sort(unique(gs));
    ngrps = numel(grps);
    nfeats = size(Ys{1},2);
    
    % find range of points to include
    if useFirstForRange
        mns = inf(nfeats,1); mxs = -inf(nfeats,1);
        for ii = 1:numel(Ys)
            mns(ii) = min(mns(ii), min(Ys{ii}));
            mxs(ii) = max(mxs(ii), max(Ys{ii}));
        end
    else
        mns = min(Ys{1});
        mxs = max(Ys{1});
    end
    
    Xs = cell(ngrps,1);
    for jj = 1:ngrps        
        Xs{jj} = nan(nbins, nfeats);
        for ii = 1:nfeats            
            Xs{jj}(:,ii) = linspace(mns(ii), mxs(ii), nbins);
        end
    end
end
