function D = prepSession(D, opts)
%
    if nargin < 2
        opts = struct();
    end
    defopts = struct('mapNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'velNm', 'vel', 'velNextNm', 'velNext', ...
        'trainBlk', 1, 'testBlk', 2, 'trainProp', 0.5, ...
        'fieldsToAdd', {});
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    Tr = D.blocks(opts.trainBlk);
    Te = D.blocks(opts.testBlk);
    if opts.trainBlk == opts.testBlk
        ixTr = splitTrainAndTest(Tr, opts);
        ixTe = ~ixTr;
    else
        ixTr = true(numel(Tr.time),1);
        ixTe = true(numel(Te.time),1);
    end
    D.train = prepToFit(Tr, ixTr, opts.trainBlk, opts);
    D.test = prepToFit(Te, ixTe, opts.testBlk, opts);

end

function ixTr = splitTrainAndTest(B, opts)
% cross-validate trials (not timepoints)
    ts = B.trial_index;
    Ts = unique(ts);
    cvobj = cvpartition(numel(Ts), 'HoldOut', opts.trainProp);
    ixTrTrain = cvobj.training(1);
    ixTr = ismember(ts, Ts(ixTrTrain));
end

function C = prepToFit(B, ix, blkInd, opts)
    C.latents = B.latents(ix,:);
    C.spikes = B.spikes(ix,:);
    
    % cursor-target info
    ths = B.(opts.thetaNm);
    C.thetas = ths(ix,:);
    
    % velocity info
    vels = B.(opts.velNm);
    velNexts = B.(opts.velNextNm);
    C.vel = vels(ix,:);
    C.velNext = velNexts(ix,:);    
    
    % add mapping and nul/row bases
    curMpg = B.(opts.mapNm);
    C.NB = curMpg.NulM2;
    C.RB = curMpg.RowM2;
    C.M0 = curMpg.M0;
    C.M1 = curMpg.M1;
    C.M2 = curMpg.M2;
    
    C.blkInd = blkInd;
    C.ix = ix;
    
    if isempty(opts.fieldsToAdd)
        return;
    end
    for ii = 1:numel(opts.fieldsToAdd)
        fldNm = opts.fieldsToAdd{ii};
        vs = B.(fldNm);
        C.(fldNm) = vs(ix,:);
    end
end
