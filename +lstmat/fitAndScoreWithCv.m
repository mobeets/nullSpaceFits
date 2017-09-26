function [rsq, rsqse, rsqv, mdl] = fitAndScoreWithCv(X, Y, Xv, Yv, kfold, ind)
    if nargin < 6
        ind = nan;
    end
    
    cvinds = crossvalind('Kfold', size(Y,1), kfold);
    rsqs = nan(kfold,1);
    mdls = cell(kfold,1);
    p = size(X,2);
    for ii = 1:kfold
        ixte = cvinds == ii;
        ixtr = ~ixte;
        Xtr = X(ixtr,:);
        Ytr = Y(ixtr,:);
        Xte = X(ixte,:);
        Yte = Y(ixte,:);
        
        if ~isnan(ind)
            Xtrind = Xtr(:,ind);
            Xteind = Xte(:,ind);
            Ytr = Ytr - Xtrind;
            Yte = Yte - Xteind;
            Xtr(:,ind) = 0;
            Xte(:,ind) = 0;
        end
        
        mdl = fitlm(Xtr, Ytr);
        Yteh = mdl.predict(Xte);
        if isnan(ind)
            rsqs(ii) = lstmat.rsq_adj(Yte, Yteh, p);
        else
            rsqs(ii) = lstmat.rsq_adj(Yte + Xteind, Yteh + Xteind, p);
        end
        mdls{ii} = mdl;
    end
    rsq = nanmean(rsqs);
    rsqse = nanstd(rsqs)/sqrt(sum(~isnan(rsqs)));
    clear mdl;
    
    if ~isempty(Xv)
        if ~isnan(ind)
            Xind = X(:,ind);
            Xvind = Xv(:,ind);
            Y = Y - Xind;
            Yv = Yv - Xvind;
            X(:,ind) = 0;
            Xv(:,ind) = 0;
        end
        mdl = fitlm(X, Y);
        Yvh = mdl.predict(Xv);
        if isnan(ind)
            rsqv = lstmat.rsq_adj(Yv, Yvh, p);
        else
            rsqv = lstmat.rsq_adj(Yv + Xvind, Yvh + Xvind, p);
        end
    else
        rsqv = [];
        mdl = [];
    end

end
