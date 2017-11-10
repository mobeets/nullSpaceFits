function [B, normSps] = findSubspaceForDim(ks, blk, ...
    orthToManifold, orthToBaseline, muBaseline)
    if nargin < 3
        orthToManifold = true;
    end
    if nargin < 4
        orthToBaseline = true;
    end
    if nargin < 5
        muBaseline = 0;
    end

    dec = ks(1).kalmanInitParams;
    mu = dec.NormalizeSpikes.mean;
    [~, beta] = omp.spikesToLatents(dec, nan);
    
    if ~orthToManifold
        B = eye(size(beta,2));
    elseif ~orthToBaseline
        [beta_nb, ~] = io.getNulRowBasis(beta);
        B = beta_nb*beta_nb'; % find dim orthogonal to manifold
    else
    	baselineShift = getBaseline(blk) - muBaseline;
        [beta_nb, ~] = io.getNulRowBasis([baselineShift; beta]);
        B = beta_nb*beta_nb'; % find dim orth. to beta and baseline shift
    end
    normSps = @(sps) bsxfun(@minus, sps, mu);

end

function mu = getBaseline(blk)
    mu = blk.spsBaseline;
%     mu = mean(blk.sps);
end
