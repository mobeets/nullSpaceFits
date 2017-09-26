function newDims = getAvgActivityDim(blk, ctrg, normSps, B, trStart, ...
    useCTAngle, nboots)
    if nargin < 2
        ctrg = nan;
    end
    if nargin < 5
        trStart = nan;
    end
    if nargin < 6
        useCTAngle = true;
    end
    if nargin < 7
        nboots = 5;
    end
        
    if useCTAngle
        grp = blk.thgrps;
    else
        grp = blk.trgs;
    end
    if ~isnan(ctrg)
        ix = grp == ctrg;
    else
        ix = true(size(grp));
    end
    if ~isnan(trStart)
        ix = ix & (blk.trs >= trStart) & (blk.trs <= trStart+80);
    end
    if sum(ix) == 0
        newDims = cell(nboots,1);
        newDims{1} = zeros(size(blk.sps,2),1);
        return;
    end
    bsps = omp.sampleTimestepsEvenly(blk.sps(ix,:), ...
        blk.trs(ix,:), nboots);
    
    newDims = cell(nboots,1);
    for ii = 1:nboots
        csps = normSps(squeeze(bsps(ii,:,:)));
        spsOffMan = mean(csps)*B;
        newDims{ii} = (spsOffMan/norm(spsOffMan))';
    end    
end
