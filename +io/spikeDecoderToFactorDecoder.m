function df = spikeDecoderToFactorDecoder(dn, dec, sps, lts)
% dn = spike decoder
% returns df, the factor decoder
% n.b. we just need simpleDataDecoder for the factor analysis params
% 

    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);
    mu = dec.spikeCountMean;
    
%     df.M2 = findM2(dn, sps, lts);
%     df.M2 = dn.M2'\beta';
%     df.M2 = dn.M2*beta';
    df.M2 = dn.M2/beta;
    df.M1 = dn.M1;
    df.M0 = dn.M0 + dn.M2*mu';
    
    spsE = tools.latentsToSpikes(lts, dec, false, true);
    Yr = sps*dn.M2';
    Yrh = spsE*dn.M2';
    
    RB = orth(df.M2');
    RBs = orth(dn.M2');
    NBs = null(dn.M2);
    mapAngle = @(a, b) rad2deg(subspace(a, b));
    mapAngle(beta'*df.M2', dn.M2')
    [mapAngle(beta'*df.M2', RBs) mapAngle(beta'*df.M2', NBs)]
    [mapAngle(beta'*RB, RBs) mapAngle(beta'*RB, NBs)]
    
end

function M2 = findM2(dn, sps, lts)    
    % we want M2 such that:
    %   M2s*sps = M2*lts = M2*beta*(sps - mu)
    vs = dn.M2*sps';
    M2 = vs/lts;
    vsh = M2*lts;
    max(sum((vs' - vsh').^2,2))    
end
