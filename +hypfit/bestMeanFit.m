function [Z, mu] = bestMeanFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('grpName', 'thetaActualGrps', 'addNoise', true, ...
        'obeyBounds', true, 'nanIfOutOfBounds', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    Z1 = Tr.latents;
    Z2 = Te.latents;
    NB2 = Te.NB;
    RB2 = Te.RB;
    nt = size(Z2,1);
    
    % first, find best mean
    mu = findBestMean(Z1, Tr.NB, Tr.(opts.grpName), ...
        0, 1.2*max(Tr.spikes));    

    % next, predict this mean as constant in NB
    Zr = Z2*(RB2*RB2');    
    Zn = repmat(mu, nt, 1)*(NB2*NB2');
    Z = Zr + Zn; Z0 = Z;
    
    % add noise
    if opts.addNoise
        sigma = dec.FactorAnalysisParams.factorStd;
        nse = randn(nt, numel(sigma))*diag(sigma);
        Z = Z + nse;
    end
    
    % correct to be within bounds if noise was added
    if opts.obeyBounds && opts.addNoise
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z); % might be fixed by resampling noise
        
        n0 = sum(ixOob);
        maxC = 10;
        c = 0;        
        while sum(ixOob) > 0 && c < maxC
            nse = randn(sum(ixOob), numel(sigma))*diag(sigma);
            Z(ixOob,:) = Z0(ixOob,:) + nse;
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            disp(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' bestMeanFit sample(s) to lie within bounds']);
        end        
    end
    if opts.obeyBounds && opts.nanIfOutOfBounds
        isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, false);
        ixOob = isOutOfBounds(Z);
        Z(ixOob,:) = nan;
    end
    
    Z = Z*(NB2*NB2') + Zr; % maintain same output-potent value
end

function mu = findBestMean(Z, NB, gs, sps_min, sps_max)
    % ZNc is prediction with constant mean, which we're searching over
    [nt, nd] = size(Z);
    ZN = Z*NB;
    obj = @(mu) score.meanErrorFcn(repmat(mu, nt, 1)*NB, ZN, gs);
    
    % need to constrain to be non-negative spikes
    Aeq = []; beq = []; lb = []; ub = [];
%     [A, b] = getSpikeBounds(dec, nd, sps_min, sps_max);    
    A = []; b = []; Aeq = []; beq = []; lb = 0.8*min(Z); ub = 1.2*max(Z);
    
    options = optimset('Display', 'off');
    mu0 = zeros(1,nd);
    mu = fmincon(obj, mu0, A, b, Aeq, beq, lb, ub, [], options);
end

function mu = findBestMean0(Z, NB, gs, sps_min, sps_max)
    grps = sort(unique(gs));
    ZN = Z*NB;
    nd = size(ZN,2);
    mu = nan(numel(grps), nd);
    for ii = 1:numel(grps)
        mu(ii,:) = nanmean(ZN(gs == grps(ii),:));
    end    
    % objective now for prediction muh is:
    %   sum_i || muh - mu(ii,:) ||^2
    % = sum_i 0.5*muh'*muh - muh'*mu(ii,:) + const
    % = (nd/2)*muh'*muh - sum_i muh'*mu(ii,:)
    % = (nd/2)*muh'*muh - muh'*sum(mu);
    % -> quadprog
    
    f = -sum(mu);
    H = eye(nd);
    A = []; b = []; Aeq = []; beq = [];
    lb = 0.8*min(Z); ub = 1.2*max(Z);
    options = optimset('Display', 'iter');
    [mu, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
            lb, ub, [], options);
    assert(~exitflag);
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
