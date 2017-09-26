function [lts1, lts2, dEarly, dLate, pcsEarly, pcsLate] = ...
    findDimOfDeltaMeansSession(D, grpNm, trialBounds, minTm, maxTm)

    bind = 1;
    B = D.blocks(bind);
    gs = B.(grpNm);
    ix = ~isnan(gs) & B.time > minTm & B.time < maxTm;
    lts1 = grpstats(B.latents(ix,:), gs(ix));

    bind = 2;
    B = D.blocks(bind);
    gs = B.(grpNm);
    ix0 = ~isnan(gs) & B.time > minTm & B.time < maxTm;
    trs = B.trial_index;
    lts2 = cell(2,1);
    ts = grpstats(trs, trs);
    ix21 = ix0 & ismember(trs, ts(1:trialBounds(1))); % first trials listed
    lts2{1} = grpstats(B.latents(ix21,:), gs(ix21));
     
    ix22 = ix0 & ismember(trs, trialBounds(2):trialBounds(3));
    lts2{2} = grpstats(B.latents(ix22,:), gs(ix22));

    dEarly = lts2{1} - lts1;
    dLate = lts2{2} - lts2{1};
    [pcsEarly,~,~,~,~] = pca(dEarly, 'Centered', false);
    [pcsLate,~,~,~,~] = pca(dLate, 'Centered', false);
end

