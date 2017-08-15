function beta = getBetaFromFA(dec)
%
% function beta = getBetaFromFA(dec)
%
% dec is struct with fields 'FactorAnalysisParams'
% returns beta, the FA manifold with dimensions [nm x nn]
%   (nm = # of latent dims; nn = # neurons)
%
% using beta, you can convert spike vector u [nn x 1] to factor activity:
%   z = beta*(u - mu)
%         where mu is spike count mean (e.g., dec.spikeCountMean)
% 
    L = dec.FactorAnalysisParams.L;
    ph = dec.FactorAnalysisParams.ph;    
    sigmainv = diag(1./dec.spikeCountStd');
    if isfield(dec.FactorAnalysisParams, 'spikeRot')
        % rotate, if necessary, from orthonormalization
        R = dec.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    beta = L'/(L*L'+diag(ph));
    beta = R'*beta*sigmainv';
end
