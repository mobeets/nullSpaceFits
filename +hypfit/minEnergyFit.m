function [Z,out] = minEnergyFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'grpName', 'thetaActualGrps', ...
        'noiseDistribution', 'poisson', 'pNorm', 2, ...
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
        assert(opts.pNorm == 2, 'best-mean assumed to use L2 norm');
        assert(~opts.fitInLatent);
%         mu_lts = [];
%         mu = findBestMean(Tr.spikes, Tr.NB_spikes, Tr.(opts.grpName), true);
        mu_lts = findBestMean(Tr.latents, Tr.NB, Tr.(opts.grpName), false);
        mu = tools.latentsToSpikes(mu_lts, dec, false, true);
        out.bestMean_lts = mu_lts;
        out.bestMean = mu;
        if any(mu < 0)
            warning(['Best mean has negative rates: ' num2str(mu)]);
        end
    else
        assert(false, ['Invalid minType for ' dispNm]);
    end
    sigma = opts.sigmaScale*dec.spikeCountStd;
    
    % set upper and lower bounds
    if opts.obeyBounds
        lb = 0.8*min(Y1); ub = 1.2*max(Y1);
    else
        lb = []; ub = [];
    end
    
    % solve minimization for each timepoint
    [nt, nu] = size(Y2);
    [U, isRelaxed] = hypfit.findAllMinNormFiring(Te, mu, ...
        lb, ub, dec, nu, opts.fitInLatent, opts.pNorm);
    nrs = sum(isRelaxed);
    if nrs > 0
        disp([dispNm ' relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoint(s).']);
    end

    % add noise
    nis = 0;
    if ~opts.fitInLatent && opts.addSpikeNoise
        U0 = U;
        if strcmpi(opts.noiseDistribution, 'gaussian')
            U = normrnd(U0, repmat(sigma, nt, 1));
        elseif strcmpi(opts.noiseDistribution, 'poisson')
            U = poissrnd(max(U0,0));
        else
            error('Invalid noise distribution');
        end
        if numel(lb) == 0
            lb = -inf(1, nu);
        end
        if numel(ub) == 0
            ub = inf(1, nu);
        end
        lbs = repmat(lb, nt, 1);
        ubs = repmat(ub, nt, 1);
        
        c = 0;
        ixBad = any(U < lbs, 2) | any(U > ubs, 2);
        while sum(ixBad) > 0 && c < 10
            nBad = sum(ixBad);
            if strcmpi(opts.noiseDistribution, 'gaussian')
                U(ixBad,:) = normrnd(U0(ixBad,:), repmat(sigma, nBad, 1));
            elseif strcmpi(opts.noiseDistribution, 'poisson')
                U(ixBad,:) = poissrnd(max(U0(ixBad,:),0));
            end
            ixBad = any(U < lbs, 2) | any(U > ubs, 2);
        end
        nis = sum(ixBad);
    end
    
%     nis = 0;
%     if ~opts.fitInLatent && opts.addSpikeNoise
%         for t = 1:nt
%             ut0 = U(t,:);
%             c = 0;
%             if strcmpi(opts.noiseDistribution, 'gaussian')
%                 ut = normrnd(ut0, sigma);
%             elseif strcmpi(opts.noiseDistribution, 'poisson')
%                 ut = poissrnd(max(ut0,0));
%             else
%                 error('Invalid noise distribution');
%             end
%             while numel(lb) > 0 && numel(ub) > 0 && ...
%                     (any(ut < lb) || any(ut > ub)) && c < 10
%                 if strcmpi(opts.noiseDistribution, 'gaussian')
%                     ut = max(normrnd(ut0, sigma), 0);
%                 elseif strcmpi(opts.noiseDistribution, 'poisson')
%                     ut = poissrnd(ut0);
%                 end
%                 c = c + 1;
%             end
%             if numel(lb) == 0 || numel(ub) == 0 || ...
%                     ~(any(ut < lb) || any(ut > ub))
%                 U(t,:) = ut;
%             else
%                 nis = nis + 1;
%             end
%         end
%     end
    if nis > 0
        disp([dispNm ' could not add noise to ' num2str(nis) ...
            ' timepoint(s)']);
    end 
    
    % count points out of bounds
    nlbs = 0; nubs = 0;
    if numel(lb) > 0
        nlbs = sum(any(U < repmat(lb, nt, 1), 2));
    end
    if numel(ub) > 0
        nubs = sum(any(U > repmat(ub, nt, 1), 2));
    end
    if nlbs > 0 || nubs > 0
        disp([dispNm ' hit lower bounds ' num2str(nlbs) ...
            ' time(s) and upper bounds ' num2str(nubs) ' time(s).']);
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
        makeOrthogonal = false; % orthogonal projection to preserve NB
        Z = tools.convertRawSpikesToRawLatents(dec, U', makeOrthogonal);
    end
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Zr = Te.latents*(RB2*RB2');
    Z = Z*(NB2*NB2') + Zr;
       
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
