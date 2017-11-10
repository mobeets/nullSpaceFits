function [newDims, normSps, Bn] = getNewDims(blk, ks, trgs, ...
    orthToBaseline, muBaseline)
    if nargin < 4
        orthToBaseline = true;
    end
    if nargin < 5
        muBaseline = 0;
    end
    newDims = cell(numel(trgs),1);
    [Bn, normSps] = omp.findSubspaceForDim(ks, blk, true, ...
        orthToBaseline, muBaseline);
    for ii = 1:numel(trgs)
        newDims{ii} = omp.getAvgActivityDim(blk, trgs(ii), normSps, Bn);
    end
end

