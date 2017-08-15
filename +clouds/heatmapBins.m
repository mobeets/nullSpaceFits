function ctrs = heatmapBins(dat, nbins)
    if nargin < 2
        nbins = 50;
    end
    mns = min(dat);
    mxs = max(dat);
    ctrs = cell(2,1);
    for ii = 1:2
        ctrs{ii} = linspace(mns(ii), mxs(ii), nbins);
    end
end
