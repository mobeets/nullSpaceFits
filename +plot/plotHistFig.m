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
%     mu = nanmean(Y0);
    if doPca
%         Yc = bsxfun(@minus, Y0, mu);
        [~,~,v] = svd(Y0*NB, 'econ');
        NB = NB*v;
    end
    ix = ~isnan(S.gs);
%     YN0 = bsxfun(@minus, Y0(ix,:), mu)*NB;
    YN0 = Y0(ix,:)*NB;
    YNc = cell(numel(hypNms),1);    
    for ii = 1:numel(hypNms)
        Yc = F.fits(strcmp({F.fits.name}, hypNms{ii})).latents(ix,:);
%         Yc = bsxfun(@minus, Yc, mu);
        YNc{ii} = Yc*NB;
    end

    useDataOnlyForRange = false; % false -> use data and preds to set range
    [Hs, Xs, nbins] = score.histsFcn([YN0; YNc], ...
        S.gs(ix), useDataOnlyForRange);
    H0 = Hs{1}; Hs = Hs(2:end);
    hypnms = ['data' hypNms];
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');
    
    if numel(opts.grpInds) == 1 && numel(opts.dimInds) == 1        
        ttl = ['            Output-null dim. ' num2str(opts.dimInds(1))];
%         ttl = [ttl ', Cursor dir. ' ...
%             num2str(S.grps(opts.grpInds(1))) '^\circ'];
%         ttl = [ttl '\newline    Cursor dir. ' ...
%             num2str(S.grps(opts.grpInds(1))) '^\circ'];
        
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
