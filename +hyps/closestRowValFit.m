function [Z, inds] = closestRowValFit(Tr, Te, ~, opts)
% aka cloud
% 
    if nargin < 4
        opts = struct();
    end
    defopts = struct('kNN', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Z1 = Tr.latents;
    Z2 = Te.latents;
    
    ds = pdist2(Z2*RB2, Z1*RB2);
    if isnan(opts.kNN)
        [~, inds] = min(ds, [], 2);
    else
        % sample inds from kNN nearest neighbors
        inds = sampleFromCloseInds(ds, opts.kNN);
    end
    Zsamp = Z1(inds,:);
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');

end

function inds = sampleFromCloseInds(ds, k)
    [~,ix] = sort(ds, 2);
    ix = ix(:,1:k);
    sampInd = randi(k, size(ds,1), 1);
    ixSamp = sub2ind(size(ds), 1:size(ds,1), sampInd');
    inds = ix(ixSamp)';
end
