function D = prepSession(D, opts)
%
    if nargin < 2
        opts = struct();
    end
    defopts = struct('mapNm', 'fDecoder', 'thetaNm', 'thetas', ...
        'velNm', 'vel', 'trainBlk', 1, 'testBlk', 2, 'trainProp', 0.5);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    Tr = D.blocks(opts.trainBlk);
    Te = D.blocks(opts.testBlk);
    if opts.trainBlk == opts.testBlk
        ixTr = splitTrainAndTest(Tr, opts);
        ixTe = ~ixTr;
    else
        ixTr = true(size(Tr.time,1),1);
        ixTe = true(size(Te.time,1),1);
    end
    D.train = prepToFit(Tr, ixTr, opts);
    D.test = prepToFit(Te, ixTe, opts);

end

function ixTr = splitTrainAndTest(B, opts)
% cross-validate trials (not timepoints)
    ts = B.trial_index;
    Ts = unique(ts);
    cvobj = cvpartition(numel(Ts), 'HoldOut', opts.trainProp);
    ixTrTrain = cvobj.training(1);
    ixTr = ismember(ts, Ts(ixTrTrain));
end

function C = prepToFit(B, ix, opts)
    C.latents = B.latents(ix,:);
    C.spikes = B.spikes(ix,:);
    
    % cursor-target info
    ths = B.(opts.thetaNm);
    C.thetas = ths(ix,:);
    
    % velocity info
    vels = B.(opts.velNm);
    velNexts = B.([opts.velNm 'Next']);    
    B.vel = vels(ix,:);
    B.velNext = velNexts(ix,:);
    
    % add mapping and nul/row bases
    curMpg = B.(opts.mapNm);
    C.NB = curMpg.NulM2;
    C.RB = curMpg.RowM2;
    C.M0 = curMpg.M0;
    C.M1 = curMpg.M1;
    C.M2 = curMpg.M2;
end
