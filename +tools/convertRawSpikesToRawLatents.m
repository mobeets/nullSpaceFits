function [latents, beta] = convertRawSpikesToRawLatents(dec, sps, makeOrthogonal)
% Convert spikes to latents

    if nargin < 3
        makeOrthogonal = false;
    end
    if isempty(sps)
        latents = [];
        return;
    end

    % FA params
    L = dec.FactorAnalysisParams.L;
    ph = dec.FactorAnalysisParams.ph;
    mu = dec.spikeCountMean';
    sigmainv = diag(1./dec.spikeCountStd');
    if isfield(dec.FactorAnalysisParams, 'spikeRot')
        % rotate, if necessary, from orthonormalization
        R = dec.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    beta = L'/(L*L'+diag(ph)); % See Eqn. 5 of DAP.pdf
    beta = R'*beta*sigmainv';
    if makeOrthogonal
        % make beta an orthogonal projection
        [beta,~,~] = svd(beta', 'econ');
        beta = beta';
    end
    u = bsxfun(@plus, sps, -mu); % normalize
    latents = u'*beta';
end
