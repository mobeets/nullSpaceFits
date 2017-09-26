function vsnew = sampleTimestepsEvenly(vs, trs, nboots, maxPerTrial)
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
    
    for kk = 1:numel(alltrs)
        cvs = vs(trs == alltrs(kk),:);
        inds = randi(size(cvs,1), [nboots*maxPerTrial 1]);
        cvsnew = reshape(cvs(inds,:), nboots, maxPerTrial, []);
        assert(~any(isnan(cvsnew(:))));
        startInd = (kk-1)*maxPerTrial + 1;
        vsnew(:,startInd:(startInd+maxPerTrial-1),:) = cvsnew;
    end
end
