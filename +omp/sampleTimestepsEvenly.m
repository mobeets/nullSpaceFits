function [vsnew, newinds] = sampleTimestepsEvenly(vs, trs, nboots, maxPerTrial)
% samples an equal number of timesteps in vs from each trial    
    alltrs = unique(trs);
    if nargin < 3
        nboots = 5;
    end
    if nargin < 4
        cs = histc(trs, alltrs);
        maxPerTrial = round(median(cs));
    end
    vsnew = nan(nboots, numel(alltrs)*maxPerTrial, size(vs,2));
    newinds = nan(nboots, numel(alltrs)*maxPerTrial);
    for kk = 1:numel(alltrs)        
        ix = trs == alltrs(kk);
        cinds = 1:size(vs,1); cinds = cinds(ix);
        cvs = vs(ix,:);
        inds = randi(size(cvs,1), [nboots*maxPerTrial 1]);
        cvsnew = reshape(cvs(inds,:), nboots, maxPerTrial, []);
        cinds = reshape(cinds(inds), nboots, maxPerTrial);
        assert(~any(isnan(cvsnew(:))));
        startInd = (kk-1)*maxPerTrial + 1;
        vsnew(:,startInd:(startInd+maxPerTrial-1),:) = cvsnew;
        newinds(:,startInd:(startInd+maxPerTrial-1)) = cinds;
    end
end
