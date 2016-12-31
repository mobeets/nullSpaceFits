function err = covErrorFcn(YNc, YN0, gs)
    grps = sort(unique(gs));
    errs = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        errs(ii) = covErr(YNc(ix,:), YN0(ix,:));
    end
    err = nanmean(errs);
end

function err = covErr(D1, D2)
% src: "A simple procedure for the comparison of covariance matrices"
% http://bmcevolbiol.biomedcentral.com/articles/10.1186/1471-2148-12-222
%
    if any(any(isnan(cov(D1)))) || any(any(isnan(cov(D2))))
        err = nan; return;
    end
    [u1,v11,~] = svd(nancov(D1), 'econ');
    [u2,v22,~] = svd(nancov(D2), 'econ');
    v11 = diag(v11)'; % var(D1*u1);
    v22 = diag(v22)'; % var(D2*u2);
    v21 = nanvar(D2*u1);
    v12 = nanvar(D1*u2);
    err = 2*sum((v11 - v21).^2 + (v12 - v22).^2);
end
