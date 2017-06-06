function [m, C, f] = findBestNeuronMean(Z, NB, RB, gs, dec, ubs)
% Z is latent activity
% NB, RB are null and row space bases in latent space
% gs are groups with which we will bin timesteps
% ubs are upperbounds per neuron
%

    nu = dec.spikeCountMean';
    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);    

    % mean null and potent activity per bin
    [Zn, Zr] = meanFactorNullActivityPerGroup(Z, NB, RB, gs);

    A = RB'*beta; % nrow x ns
    A2 = A'/(A*A');
    C = NB'*beta - NB'*beta*A2*A; % nnull x ns
    d = A2*(-A*nu - nanmean(Zr)'); % ns x 1
    f = nanmean(Zn)' - NB'*beta*(d - nu); % nnull x 1

    % note: this problem is underconstrained because C ~ 8 x 86, f ~ 8 x 1
    %   and we're essentially finding m to minimize || Cm - f ||_2

    % note: I add the eps term because C'*C is not invertible
%     m = (C'*C + eps*eye(numel(nu)))\(C'*f); % ns x 1
%     m = max(m, 0);
%     m = quadprog(C'*C, C'*f, [], [], [], [], zeros(numel(nu),1));

%     m - A2*(A*m - A*nu - r) = m - A2*A*m + A2*(A*nu + r) >= 0
%     (I - A2*A)m >= -A2*(A*nu + r)
    Aleq = []; bleq = [];
    for jj = 1:size(Zr,1)
        % mean spike prediction for bin j must be non-neg: Aleq*m <= bleq
        Ac = A2*A - eye(numel(nu));
        bc = A2*(A*nu + Zr(jj,:)');
        Aleq = [Aleq; Ac];
        bleq = [bleq; bc];
    end
    m = quadprog(C'*C, C'*f, Aleq, bleq, [], [], zeros(numel(nu),1), ubs);

end

function [Zn, Zr] = meanFactorNullActivityPerGroup(Z, NB, RB, gs)
    ZN = Z*NB;
    ZR = Z*RB;
    grps = sort(unique(gs));
    grps = grps(~isnan(grps));
    Zn = nan(numel(grps), size(NB,2));
    Zr = nan(numel(grps), size(RB,2));
    for ii = 1:numel(grps)
        Zn(ii,:) = nanmean(ZN(gs == grps(ii),:));
        Zr(ii,:) = nanmean(ZR(gs == grps(ii),:));
    end
end
