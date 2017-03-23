function plotHistFig(fitName, dt, hypNms, doPca, opts)
    if nargin < 4
        doPca = true;
    end
    if nargin < 5
        opts = struct();
    end
    
    % load output-null activity
    [S,F] = plot.getScoresAndFits(fitName, {dt});    
    NB = F.test.NB;
    Y0 = F.test.latents;
    mu = nanmean(Y0*NB);
    if doPca
        [coeff, ~] = pca(Y0*NB);
    else
        coeff = eye(size(mu,2));
    end
    
    ix = ~isnan(S.gs);
    YN0 = bsxfun(@plus, bsxfun(@minus, Y0(ix,:)*NB, mu)*coeff, mu);
    YNc = cell(numel(hypNms),1);    
    for ii = 1:numel(hypNms)
        Yc = F.fits(strcmp({F.fits.name}, hypNms{ii})).latents(ix,:);
        YNc{ii} = bsxfun(@plus, bsxfun(@minus, Yc*NB, mu)*coeff, mu);
    end

    useDataOnlyForRange = false; % false -> use data and preds to set range
    [Hs, Xs, ~] = score.histsFcn([YN0; YNc], ...
        S.gs(ix), useDataOnlyForRange);
    H0 = Hs{1}; Hs = Hs(2:end);
    hypnms = ['data' hypNms];
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');
    
    if numel(opts.grpInds) == 1 && numel(opts.dimInds) == 1        
        ttl = ['            Output-null dim. ' num2str(opts.dimInds(1))];
        txtnt = ttl;
        ttl = '';
        lw = 3;
        fnm = ['margHistSingle_' [hypNms{:}] '_' fitName];
    else
        ttl = '';
        txtnt = '';
        lw = 2;
        fnm = ['margHist_' [hypNms{:}] '_' fitName];
    end
    
    % display
    defopts = struct('ymax', 0.5, ...
        'grpNms', S.grps, ...
        'clrs', hypClrs, ...
        'height', max(2.2, 0.7*numel(opts.grpInds)), ...
        'width', max(3, 0.7*numel(opts.dimInds)), ...
        'title', ttl, ...
        'LineWidth', lw, ...
        'filename', fnm, ...
        'TextNote', txtnt);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    plot.plotHist(H0, Hs, Xs, opts);
    
end
