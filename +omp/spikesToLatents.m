function [latents, beta] = spikesToLatents(dec, sps)
% Convert spikes to latents

    if isempty(sps)
        latents = [];
        return;
    end

    % FA params
    L = dec.FactorAnalysisParams.L;
    ph = dec.FactorAnalysisParams.Ph;    
    sigmainv = diag(1./dec.NormalizeSpikes.std');
    if isfield(dec.FactorAnalysisParams, 'spikeRot')
        % rotate, if necessary, from orthonormalization
        R = dec.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    beta = L'/(L*L'+diag(ph)); % See Eqn. 5 of DAP.pdf
    beta = R'*beta*sigmainv';
    mu = dec.NormalizeSpikes.mean';
    u = bsxfun(@plus, sps, -mu); % normalize
    latents = u'*beta';
end
