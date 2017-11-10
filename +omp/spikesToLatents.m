function [latents, beta] = spikesToLatents(dec, sps, doOrtho)
% Convert spikes to latents
    if nargin < 3
        doOrtho = false;
    end

    % FA params
    L = dec.FactorAnalysisParams.L;
    if doOrtho
        [U,S,V] = svd(L, 'econ');
        Lrot = U;
        spikeRot = V*S;
        if det(spikeRot) < 0
            spikeRot(:,1) = -spikeRot(:,1);
        end
    else
        spikeRot = eye(size(L,2));
    end
    
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
    if isempty(sps)
        latents = [];
        return;
    end
    mu = dec.NormalizeSpikes.mean';
    u = bsxfun(@plus, sps, -mu); % normalize
    latents = u'*beta';
    latents = latents*spikeRot;
end
