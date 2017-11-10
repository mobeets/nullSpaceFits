function [newDims, dimNorms, varExp] = getAvgActivityDim(blk, ctrg, ...
    normSps, B, trStart, useCTAngle, nboots, doNorm, minTm, maxTm, ...
    doEvenSamples)
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
        nboots = 20;
    end
    if nargin < 8
        doNorm = true;
    end
    if nargin < 9
        minTm = 5;
    end
    if nargin < 10
        maxTm = 10;
    end
    if nargin < 11
        doEvenSamples = false;
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
        dimNorms = [];
        varExp = [];
        return;
    end
    ix = ix & (blk.tms >= minTm) & (blk.tms <= maxTm);
    
    if doEvenSamples
        bsps = omp.sampleTimestepsEvenly(blk.sps(ix,:), ...
            blk.trs(ix,:), nboots);
    else
        bsps = blk.sps(ix,:);
        bsps = reshape(bsps, 1, size(bsps,1), size(bsps,2));
        bsps = repmat(bsps, nboots, 1);
    end
    
    newDims = cell(nboots,1);
    dimNorms = cell(nboots,1);
    varExp = cell(nboots,1);
    for ii = 1:nboots
        csps = normSps(squeeze(bsps(ii,:,:)));
%         csps = normSps(blk.sps(ix,:));
        spsOffMan = mean(csps)*B;
        dimNorms{ii} = norm(spsOffMan);
        if doNorm
            newDims{ii} = (spsOffMan/norm(spsOffMan))';
        else
            newDims{ii} = spsOffMan';
        end
        varExp{ii} = norm(mean(csps)*B)/norm(mean(csps));
    end
end
