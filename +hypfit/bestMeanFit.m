function [Z, mu] = bestMeanFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('grpName', 'thetaActualGrps', 'addNoise', true, ...
        'obeyBounds', true, 'boundsType', 'spikes');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    Z2 = Te.latents;
    NB2 = Te.NB;
    RB2 = Te.RB;
    nt = size(Z2,1);
    
    % first, find best mean
    mu = findBestMean(Tr.latents, Tr.NB, Tr.(opts.grpName), ...
        0, 2*max(Tr.spikes));

    % next, predict this mean as constant in NB
    Zr = Z2*(RB2*RB2');    
    Zn = repmat(mu, nt, 1)*(NB2*NB2');
    Z = Zr + Zn;
    
    % add noise
    if opts.addNoise
        sigma = dec.FactorAnalysisParams.factorStd;
        nse = normrnd(zeros(nt, numel(sigma)), repmat(sigma, nt, 1));
        Z = Z + nse;
    end
    
    % correct to be within bounds
    if opts.obeyBounds
        error('Not obeying bounds yet.');
    end
    
    Z = Z*(NB2*NB2') + Zr;
end

function mu = findBestMean(Z, NB, gs, sps_min, sps_max)
    % ZNc is prediction with constant mean, which we're searching over
    [nt, nd] = size(Z);
    ZN = Z*NB;
    obj = @(mu) score.meanErrorFcn(repmat(mu, nt, 1)*NB, ZN, gs);
    
    % need to constrain to be non-negative spikes
    Aeq = []; beq = []; lb = []; ub = [];
    [A, b] = getSpikeBounds(dec, nd, sps_min, sps_max);    
%     A = []; b = []; Aeq = []; beq = []; lb = min(ZN); ub = max(ZN);
    
    mu0 = zeros(1,nd);
    mu = fmincon(obj, mu0, A, b, Aeq, beq, lb, ub);    
end

function [A, b] = getSpikeBounds(dec, nd, sps_min, sps_max)
    if isfield(dec.FactorAnalysisParams, 'spikeRot')
        R = dec.FactorAnalysisParams.spikeRot;
    else
        R = eye(nd);
    end
    L = decoder.FactorAnalysisParams.L;
    ph = decoder.FactorAnalysisParams.ph;
    mu = decoder.spikeCountMean;
    sigma = decoder.spikeCountStd;
    L = L + diag(ph)/L';
%     U = (Z/R)*L';
%     spikes = U*diag(sigma) + mu;
%     spikes = Z*(R\L'*diag(sigma)) + mu;

    % spikes = Z*Aeq + mu;
    % Bmin <= spikes <= Bmax
    % Bmin - mu <= Z*Aeq
    % mu - Bmax <= -Z*Aeq
    A0 = (R\L'*diag(sigma))';
    b1 = sps_min - mu;
    b2 = mu - sps_max;
    A = [A0; A0]; b = [b1 b2]; % want AX <= B
    
end
