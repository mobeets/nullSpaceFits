function D = addDecoders(D)

    nd = D.simpleData.nullDecoder;
    sd = D.simpleData.shuffles;
    nMap1 = nd.rawSpikes;
    nMap2 = sd.rawSpikes;
    
    [nMap1.NulM2, nMap1.RowM2] = io.getNulRowBasis(nMap1.M2);
    [nMap2.NulM2, nMap2.RowM2] = io.getNulRowBasis(nMap2.M2);
    
    fMap1 = getFactorNullDecoder(D.kalmanInitParams);
    fMap2 = getFactorShuffleDecoder(sd, nd, fMap1, D.kalmanInitParams);
    
    assert(numel(D.blocks) == 3);
    D.blocks(1).nDecoder = nMap1;
    D.blocks(2).nDecoder = nMap2;
    D.blocks(3).nDecoder = nMap1;
    D.blocks(1).fDecoder = fMap1;
    D.blocks(2).fDecoder = fMap2;
    D.blocks(3).fDecoder = fMap1;

end

function fm = getFactorNullDecoder(kalmanInitParams)

    [fm.M0, fm.M1, fm.M2, fm.k] = io.simplifyKalman2(kalmanInitParams);
    [fm.NulM2, fm.RowM2] = io.getNulRowBasis(fm.M2);
    % M0, M1 the same as in nd.normalizedSpikes

end

function fm = getFactorShuffleDecoder(sd, nd, fm1, kalmanInitParams)
    
    % some sessions have sd as a struct array, where sd(2) is for spikes
    if numel(sd) > 1
        sd = sd(1);
    end

    % shuffled Sigma_z (already in sd.shuffleMatrix)
    nshufs = numel(sd.shuffles);
    eta_f = zeros(nshufs);
    eta_f(sub2ind(size(eta_f), 1:nshufs, sd.shuffles)) = 1;
    Sigma_z = eta_f*diag(1./nd.FactorAnalysisParams.factorStd);
    
    fm.M0 = -fm1.k*kalmanInitParams.d; % = sd.normalizedSpikes.M0;
    fm.M1 = fm1.M1; % = sd.normalizedSpikes.M1;
    fm.M2 = fm1.k*Sigma_z;
    [fm.NulM2, fm.RowM2] = io.getNulRowBasis(fm.M2);
    
end
