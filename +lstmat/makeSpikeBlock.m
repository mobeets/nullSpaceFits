function [Sps, alltms, alltrs] = makeSpikeBlock(sps, tms, trs)
    alltms = unique(tms);
    alltrs = unique(trs);
    nd = size(sps,2);
    Sps = nan(numel(alltrs), numel(alltms), nd);
    for ii = 1:numel(alltrs)
        csps = sps(trs == alltrs(ii),:);
        ctms = tms(trs == alltrs(ii));
        Sps(ii,ctms,:) = csps;
    end
end
