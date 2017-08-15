function h = showHeatmap(dat, ctrs)
    if nargin < 2
        nbins = 50;
        mns = min(dat);
        mxs = max(dat);
        ctrs = cell(2,1);
        for ii = 1:2
            ctrs{ii} = linspace(mns(ii), mxs(ii), nbins);
        end
    end
    mns = cellfun(@min, ctrs);
    mxs = cellfun(@max, ctrs);

    n = hist3(dat, ctrs); % default is to 10x10 bins
    n1 = n';
    n1(size(n,1) + 1, size(n,2) + 1) = 0;
    xb = linspace(mns(1), mxs(1), size(n,1)+1);
    yb = linspace(mns(2), mxs(2), size(n,1)+1);
    h = pcolor(xb,yb,n1);
    h.ZData = ones(size(n1)) * -max(max(n));
    colormap(hot) % heat map

end
