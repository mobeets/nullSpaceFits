function ds = distanceFromManifold(Y, kc)

    kc = kc.kalmanInitParams;
    mu = kc.NormalizeSpikes.mean;
    normSps = @(sps) bsxfun(@minus, sps, mu);
    
    [~, beta] = omp.spikesToLatents(kc, nan);
    [~, beta_rb] = io.getNulRowBasis(beta);
    B = beta_rb*beta_rb';

    y = normSps(Y);
    yp = normSps(Y)*B;
    ds = sqrt(sum((y - yp).^2,2));
end
