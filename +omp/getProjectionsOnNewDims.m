function projs = getProjectionsOnNewDims(blks, trgs, newDims, normSps, ...
    minTm, maxTm, doEvenSamples)
    if nargin < 5
        minTm = 5;
    end
    if nargin < 6
        maxTm = 10;
    end
    if nargin < 7
        doEvenSamples = false;
    end

    ntrgs = numel(trgs);
    nboots = numel(newDims{1});
    projs = cell(numel(blks), ntrgs, nboots);    
    
    for ii = 1:numel(blks)
        ix = (blks(ii).tms >= minTm) & (blks(ii).tms <= maxTm);
        if doEvenSamples
            bsps = omp.sampleTimestepsEvenly(blks(ii).sps(ix,:), ...
                blks(ii).trs(ix), nboots);
        else
            bsps = blks(ii).sps(ix,:);
            bsps = reshape(bsps, 1, size(bsps,1), size(bsps,2));
            bsps = repmat(bsps, nboots, 1);
        end
        for jj = 1:ntrgs
            for kk = 1:nboots
                projs{ii,jj,kk} = normSps(squeeze(bsps(kk,:,:)))*newDims{jj}{kk};
            end
        end
    end
end
