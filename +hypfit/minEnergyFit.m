function [Z,out] = minEnergyFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'grpName', 'thetaActualGrps', ...
        'noiseDistribution', 'poisson', ...
        'obeyBounds', true, 'sigmaScale', 1.0, 'addSpikeNoise', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    dispNm = ['minEnergyFit (' opts.minType ')'];
        
    if opts.fitInLatent
        Y1 = Tr.latents;
        Y2 = Te.latents;
    else
        Y1 = Tr.spikes;
        Y2 = Te.spikes;
    end

    % set upper and lower bounds
    if opts.obeyBounds
        lb = 0.8*min(Y1); ub = 1.2*max(Y1);
    else
        lb = []; ub = [];
    end
    
    % set minimum, in latent or spike space
    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = dec.spikeCountMean;
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(Tr.spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(dec, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = [];
    elseif strcmpi(opts.minType, 'best')
        assert(~opts.fitInLatent);
        mu_lts = [];
        mu = findBestMean(Tr.spikes, Tr.NB_spikes, Tr.(opts.grpName), true);
        
%         mu_lts = findBestMean(Tr.latents, Tr.NB, Tr.(opts.grpName), false);
%         mu = tools.latentsToSpikes(mu_lts, dec, false, true);
        
        out.bestMean_lts = mu_lts;
        out.bestMean = mu;
        if any(mu < 0)
            warning(['Best mean has negative rates: ' num2str(mu)]);
        end
    else
        assert(false, ['Invalid minType for ' dispNm]);
    end
    sigma = opts.sigmaScale*dec.spikeCountStd;
    maxSps = 2*max(Tr.spikes(:));

    [nt, nu] = size(Y2);
    U = nan(nt,nu);
    nrs = 0; nlbs = 0; nubs = 0; nis = 1;
    for t = 1:nt        
        if mod(t, 500) == 0
            disp([dispNm ': ' num2str(t) ' of ' num2str(nt)]);
        end
        [U(t,:), isRelaxed] = hypfit.quadFireFit(Te, t, -mu, ...
            opts.fitInLatent, lb, ub, dec);
        nrs = nrs + isRelaxed;
        
        if ~opts.fitInLatent && opts.addSpikeNoise
            ut0 = U(t,:);
            c = 0;
            if strcmpi(opts.noiseDistribution, 'gaussian')
                ut = normrnd(ut0, sigma);
            elseif strcmpi(opts.noiseDistribution, 'poisson')
                ut = poissrnd(ut0);
            else
                error('Invalid noise distribution');
            end
            while (any(ut < 0) || any(ut > 2*maxSps)) && c < 10
                if strcmpi(opts.noiseDistribution, 'gaussian')
                    ut = max(normrnd(ut0, sigma), 0);
                elseif strcmpi(opts.noiseDistribution, 'poisson')
                    ut = poissrnd(ut0);
                end
                c = c + 1;
            end
            if ~(any(ut < 0) || any(ut > 2*maxSps))
                U(t,:) = ut;
            else
                nis = nis + 1;
            end
        end
        
        if numel(lb) > 0 && any(U(t,:) < lb - 1e-5)
            nlbs = nlbs + 1;
        end
        if numel(ub) > 0 && any(U(t,:) > ub + 1e-5)
            nubs = nubs + 1;
        end
    end    
    if opts.fitInLatent        
        Z = U;
        if opts.addSpikeNoise
            % project to spikes, then infer latents
            sps = tools.latentsToSpikes(Z, dec, true, true);
            Z = tools.convertRawSpikesToRawLatents(dec, sps');
        end
    else        
        if opts.obeyBounds && opts.nanIfOutOfBounds
            isOutOfBounds = tools.boundsFcn(Tr.spikes, 'spikes', dec, true);
            ixOob = isOutOfBounds(U);
            U(ixOob,:) = nan;
        end
        out.U = U;
        Z = tools.convertRawSpikesToRawLatents(dec, U');
%         Z = Z/Dc.FactorAnalysisParams.spikeRot;
    end
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Zr = Te.latents*(RB2*RB2');
    Z = Z*(NB2*NB2') + Zr;
    
    if nrs > 0
        disp([dispNm ' relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoint(s).']);
    end
    if nlbs > 0 || nubs > 0
        disp([dispNm ' hit lower bounds ' num2str(nlbs) ...
            ' time(s) and upper bounds ' num2str(nubs) ' time(s).']);
    end
    if nis > 0
        disp([dispNm ' could not add noise to ' num2str(nis) ...
            ' timepoint(s)']);
    end    
end


function mu = findBestMean0(U, NB, gs)
    % ZNc is prediction with constant mean, which we're searching over
    [nt, nd] = size(U);
    obj = @(mu) score.meanErrorFcn(repmat(mu, nt, 1)*NB, U*NB, gs);
    
    A = []; b = []; Aeq = []; beq = []; lb = 0.8*min(U); ub = 1.2*max(U);
    options = optimset('Display', 'off');
%     mu0 = zeros(1,nd);
    mu0 = mean(U);
    mu = fmincon(obj, mu0, A, b, Aeq, beq, lb, ub, [], options);
end

function mu = findBestMean(Z, NB, gs, isInSpikes)
    grps = sort(unique(gs));
    ZN = Z*NB;
    nd = size(ZN,2);
    mu = nan(numel(grps), nd);
    for ii = 1:numel(grps)
        mu(ii,:) = nanmean(ZN(gs == grps(ii),:));
    end    
    % objective now for prediction muh is:
    % = sum_i || muh - mu(ii,:) ||^2
    % = sum_i 0.5*muh'*muh - muh'*mu(ii,:) + const
    % = (nd/2)*muh'*muh - sum_i muh'*mu(ii,:)
    % = (nd/2)*muh'*muh - muh'*sum(mu);
    % -> quadprog
    
    f = -nansum(mu);
    H = eye(nd);
    A = []; b = []; Aeq = []; beq = [];
    if isInSpikes
        % A,b enforce non-negativity of spike solution
        A = -eye(nd);
        b = zeros(nd,1);
    end
    lb = 0.8*min(ZN); ub = 1.2*max(ZN);
    options = optimset('Display', 'off');
    [mu, ~, exitflag] = quadprog(H, f, A, b, Aeq, beq, ...
            lb, ub, [], options);
    assert(exitflag == 1);
    mu = mu'*NB'; % project null-space value back up to latent/spike space
end
