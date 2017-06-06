function [tsY, tsZ, muY, muZ] = pdsFromLtsOverTime(B, dec, binSz)
    if nargin < 3
        binSz = 50;
    end

    Y = B.spikes;
    Z = B.latents;
    Yz = tools.latentsToSpikes(Z, dec, false, true);
    
    grps = tools.thetaCenters;
    gs = tools.thetaGroup(B.thetas, grps);
    xs = B.trial_index;
    xs1 = min(xs):binSz:max(xs);
    xs2 = xs1(2:end);
    xs1 = xs1(1:end-1);
    
    tsY = cell(numel(xs1), 1);
    tsZ = tsY;
    muY = cell(numel(xs1), 1);
    muZ = muY;
    for ii = 1:numel(xs1)
        ix = xs >= xs1(ii) & xs < xs2(ii);
        [musY, thsY, ~] = tuning.getTuning(Y(ix,:), gs(ix), grps);
        [musZ, thsZ, ~] = tuning.getTuning(Yz(ix,:), gs(ix), grps);
        tsY{ii} = thsY;
        tsZ{ii} = thsZ;
        muY{ii} = musY;
        muZ{ii} = musZ;
    end
    
end
