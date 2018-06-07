function [t1, t2, behs, ts] = identifyTopLearningRange(B, binSize, ...
    grpNm, fcn, minTm, maxTm)
    if nargin < 6
        maxTm = inf;
    end

    beh = B.(grpNm);
    trs = B.trial_index;
    ts = grpstats(trs, trs);
    
    tssts = min(ts):binSize:max(ts);
    behs = nan(numel(tssts)-1,1);    
    for ii = 1:(numel(tssts)-1)
        t1 = tssts(ii);
        t2 = tssts(ii+1);
        ix = ismember(trs, t1:t2) & B.time >= minTm & B.time <= maxTm;
%         behc = grpstats(beh(ix), trs(ix));
        behc = beh(ix);
        behs(ii) = nanmean(behc);        
    end
%     plot.init; plot(tssts(1:end-1), behs, '-');
    [~,ind] = fcn(behs);
    t1 = tssts(ind);
    t2 = tssts(ind+1);
    ts = tssts(1:end-1)';
    
end
