%% find range of factor activity possible in first two dims
% subject to non-negative firing

inControlPlane = false;

% [Ss,Fs] = plot.getScoresAndFits('Int2Pert_nIme');
% saveDir = 'data/plots/boundaries2';
saveDir = '';
exflgs = nan(numel(Fs), 2);
for ii = 1%1:numel(Fs)
    F = Fs(ii);
    Tr = F.train;
    Te = F.test;
    
    gstr = tools.thetaGroup(Tr.thetas, tools.thetaCenters);
    gste = tools.thetaGroup(Te.thetas, tools.thetaCenters);
    mutr = grpstats(Tr.spikes, gstr);
    mute = grpstats(Te.spikes, gste);
    lb = min(mutr);
    ub = max(mutr);
    
    M2 = Tr.M2_spikes;
    beta = speed.getBetaFromFA(F.dec);
    mu = F.dec.spikeCountMean;
    [vv, fval, exflg] = speed.findMaxProgress(M2', [1 0]', beta', mu', lb', ub');
    exflgs(ii,1) = exflg;
    exflgs(ii,2) = mean((lb <= mu) & (mu <= ub));
    continue;
    
%     lb = min([Tr.spikes; Te.spikes]); % [1 x 88]
%     ub = max([Tr.spikes; Te.spikes]); % [1 x 88]
    
    mu = F.dec.spikeCountMean; % [1 x 88]
    beta = speed.getBetaFromFA(F.dec); % [10 x 88]
    M2 = Tr.M2_spikes; % [2 x 88]
    M0 = Tr.M0_spikes; % [2 x 1]

    angs = linspace(0, 360, 100)';
    
    if inControlPlane
        progM = speed.findAllMaxProgress(angs, M2, M0, beta, mu, lb, ub, true);
        progA = speed.findAllMaxProgress(angs, M2, M0, beta, mu, lb, ub, false);
        Z1 = bsxfun(@plus, Tr.spikes*M2', M0');
        Z2 = bsxfun(@plus, Te.spikes*M2', M0');
        zero = M0';
        lbls = {'Control plane, dim 1', 'Control plane, dim 2'};
    else
        progM = speed.findMaxFactorActivity(angs, beta, mu, lb, ub, true);
        progA = speed.findMaxFactorActivity(angs, beta, mu, lb, ub, false);
        Z1 = F.train.latents;
        Z2 = F.test.latents;
        [v,ix] = min(F.train.latents(:,1));
        z = F.train.spikes(ix,:)*beta' - mu*beta';
        zero = -mu*beta';
        lbls = {'Factor activity, dim 1', 'Factor activity, dim 2'};
    end
    
    nms = {'Boundary (any)', ...
        'Boundary (in-manifold)', ...
        'Intuitive', 'Perturbation', 'Zero firing'};
    speed.plotMaxFactorActivity({progA, progM}, ...
        {Z1, Z2, zero}, nms, [F.datestr '-int'], lbls, saveDir);
    if ~isempty(saveDir)
        close all;
    end
end
