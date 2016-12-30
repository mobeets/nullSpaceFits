function [Z,U] = minEnergyFit(Tr, Te, dec, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
        
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
    else
        assert(false, 'Invalid minType for minEnergyFit');
    end
    sigma = dec.spikeCountStd;
    maxSps = 2*max(Tr.spikes(:));

    [nt, nu] = size(Y2);
    U = nan(nt,nu);
    nrs = 0; nlbs = 0; nubs = 0;
    for t = 1:nt        
        if mod(t, 500) == 0
            disp(['minEnergyFit: ' num2str(t) ' of ' num2str(nt)]);
        end
        [U(t,:), isRelaxed] = hyps.quadFireFit(Te, t, -mu, ...
            opts.fitInLatent, lb, ub, dec);
        nrs = nrs + isRelaxed;
        
        if ~opts.fitInLatent && opts.addSpikeNoise
            ut0 = U(t,:);
            c = 0;
            ut = normrnd(ut0, sigma);
            while (any(ut < 0) || any(ut > 2*maxSps)) && c < 10
                ut = normrnd(ut0, sigma);
                c = c + 1;
            end
            if ~(any(ut < 0) || any(ut > 2*maxSps))
                U(t,:) = ut;
            end
        end
        
        if numel(lb) > 0 && any(abs(U(t,:) - lb) < 1e-5)
            nlbs = nlbs + 1;
        end
        if numel(ub) > 0 && any(abs(U(t,:) - ub) < 1e-5)
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
        Z = tools.convertRawSpikesToRawLatents(dec, U');
%         Z = Z/Dc.FactorAnalysisParams.spikeRot;
    end
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Zr = Te.latents*(RB2*RB2');
    Z = Z*(NB2*NB2') + Zr;
    
    if nrs > 0
        warning(['minEnergyFit relaxed non-negativity constraints ' ...
            'and bounds for ' num2str(nrs) ' timepoints.']);
    end
    if nlbs > 0 || nubs > 0
        warning(['minEnergyFit hit lower bounds ' num2str(nlbs) ...
            ' times and upper bounds ' num2str(nubs) ' times.']);
    end
    if opts.nanIfOutOfBounds && opts.obeyBounds
        opts.isOutOfBounds = tools.boundsFcn(Y1, opts.boundsType, dec);
        isOut = arrayfun(@(t) opts.isOutOfBounds(Z(t,:)), 1:nt);
        Z(isOut,:) = nan;
        c = sum(isOut);
        if c > 0
            warning(['minEnergyFit ignoring ' num2str(c) ...
                ' points outside of bounds.']);
        end
    end    
end
