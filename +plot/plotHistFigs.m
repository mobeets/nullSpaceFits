function plotHistFigs(fitName, dt, hypNms, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots', ...
        'saveExt', 'pdf', 'ymax', nan, ...
        'doPca', true, 'grpInds', 1:8, 'dimInds', 1:3);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % load output-null activity
    [S,F] = plot.getScoresAndFits(fitName, {dt});    
    NB = F.test.NB;
    Y0 = F.test.latents;
    mu = nanmean(Y0*NB);
    if opts.doPca
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
    [H0, Hs, xs, ymx] = filterHists(H0, Hs, Xs, opts);
    if isnan(opts.ymax)
        opts.ymax = ymx;
    end

    if numel(opts.grpInds) == 1 && numel(opts.dimInds) == 1
        plotSingleton(H0, Hs, xs, hypNms, fitName, opts);
    else
        plotGrid(H0, Hs, xs, hypNms, fitName, S, opts);
    end
end

function plotGrid(H0, Hs, xs, hypNms, fitName, S, opts)

    % plot hists
    opts.clr1 = plot.hypColor('data');
    for jj = 1:numel(Hs)        
        Hc = Hs{jj};
        opts.clr2 = plot.hypColor(hypNms{jj});
        ix = strcmp(hypNms{jj}, {S.scores.name});
        opts.histError = 100*S.scores(ix).histError;
        plot.plotGridHistFig(H0, Hc, xs, opts);
        if opts.doSave
            fnm = ['margHist_' hypNms{jj} '_' fitName];
            export_fig(gcf, fullfile(opts.saveDir, ...
                [fnm '.' opts.saveExt]));
        end
    end
end

function plotSingleton(hs1, Hs, xs, hypNms, fitName, opts)
    
    % plot and save all hists
    opts.clr1 = plot.hypColor('data');
    opts.title = ['Output-null dim. ' num2str(opts.dimInds)];
    for ii = 1:numel(Hs)
        hs2 = Hs{ii};
        opts.clr2 = plot.hypColor(hypNms{ii});
        plot.plotSingleHistFig(hs1, hs2, xs, opts);        
        if opts.doSave
            fnm = ['margHistSingle_' hypNms{ii} '_' fitName];
            export_fig(gcf, fullfile(opts.saveDir, ...
                [fnm '.' opts.saveExt]));
        end
    end
end

function [H0a, Hsa, xs, ymx] = filterHists(H0, Hs, Xs, opts)
    xs = Xs{1}(:,1); % xs is the same everywhere anyway
    nx = numel(xs);

    % init to empty
    H0a = nan(numel(opts.grpInds), nx, numel(opts.dimInds));
    Hsa = cell(numel(Hs), 1);
    for jj = 1:numel(Hs)
        Hsa{jj} = H0a;
    end

    % fill with filtered hists
    ymx = -inf;
    for ii = 1:numel(opts.grpInds)
        H0a(ii,:,:) = H0{opts.grpInds(ii)}(:,opts.dimInds);
        ymx = max(ymx, nanmax(H0a(:)));
        for jj = 1:numel(Hs)
            Hsa{jj}(ii,:,:) = Hs{jj}{opts.grpInds(ii)}(:,opts.dimInds);
            ymx = max(ymx, nanmax(Hsa{jj}(:)));
        end
    end
end

