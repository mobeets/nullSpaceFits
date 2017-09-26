function [vmu, vse] = bootstrapStats(fcn, vs, maxn, nboots)
    if nargin < 4
        nboots = 1000;
    end
    inds = randi(size(vs,1), [maxn nboots]);
    vsa = fcn(vs(inds));
    vmu = mean(vsa,2);
    vse = std(vsa,[],2)/sqrt(nboots);
end

