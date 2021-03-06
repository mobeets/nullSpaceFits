function err = covErrorFcn(YNc, YN0, gs)
    grps = sort(unique(gs));
    errs = nan(numel(grps),1);
    for ii = 1:numel(grps)
        ix = grps(ii) == gs;
        errs(ii) = score.covErr(YNc(ix,:), YN0(ix,:));
    end
    err = nanmean(errs);
end
