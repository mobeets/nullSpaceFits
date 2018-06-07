function plotHistFigs(fitName, dt, hypNms, opts, latents)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots/hists', ...
        'saveExt', 'pdf', 'ymax', nan, 'rowStartInd', nan, ...
        'doPca', true, 'grpInds', 1:8, 'dimInds', 1:3);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % load output-null activity
    [S,F] = plot.getScoresAndFits(fitName, {dt});
    Sa = plot.getScoresAndFits(fitName, io.getDates);
    errs = plot.getScoreArray(Sa, 'histError');
    errs = mean(errs(~any(isinf(errs),2),:));
    
    NB = F.test.NB;
    Y0 = F.test.latents;
    mu = nanmean(Y0*NB);
    if opts.doPca
        [coeff, ~] = pca(Y0*NB);
    else
        coeff = eye(size(mu,2));
    end
    
    % find scales of each axis based on how many neurons contribute
%     scs = nan(size(coeff,2),1);
%     [~, beta] = tools.convertRawSpikesToRawLatents(F.dec, F.test.spikes');
%     for ii = 1:size(coeff,2)
%         v = beta'*NB*coeff(:,ii);
%         scs(ii) = tools.lengthOfHypercubeIntersector(v);
%     end
%     opts.dimScales = (1000/45)./scs; % convert to sps/sec
    opts.dimScale = 1000/45;
    
    ix = ~isnan(S.gs);
    YN0 = bsxfun(@plus, bsxfun(@minus, Y0(ix,:)*NB, mu)*coeff, mu);
    YNc = cell(numel(hypNms),1); 
    err = nan(numel(hypNms),1);
    for ii = 1:numel(hypNms)
        Yc = F.fits(strcmp({F.fits.name}, hypNms{ii})).latents(ix,:);
        YNc{ii} = bsxfun(@plus, bsxfun(@minus, Yc*NB, mu)*coeff, mu);
        err(ii) = errs(strcmp({S(1).scores.name}, hypNms{ii}));
    end
    
%     sps = F.test.spikes(ix,:);
%     nse = rand(size(sps));
%     nse = nse - 0.5;
%     [lts, bta] = tools.convertRawSpikesToRawLatents(F.dec, sps' + nse');
%     [~,S] = pca(lts);
%     plot.init; plot(S(:,1), S(:,2), 'k.');

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
        plotGrid(H0, Hs, xs, hypNms, fitName, err, opts);
    end
end

function plotGrid(H0, Hs, xs, hypNms, fitName, err, opts)

    % plot hists
    opts.clr1 = plot.hypColor('data');
    for jj = 1:numel(Hs)        
        Hc = Hs{jj};
        opts.clr2 = plot.hypColor(hypNms{jj});
%         ix = strcmp(hypNms{jj}, {S.scores.name});
%         opts.histError = 100*S.scores(ix).histError;
        opts.histError = 100*err(jj);
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
    opts.title = ['Output-null activity, dim. ' num2str(opts.dimInds)];
%     opts.dimScale = opts.dimScales(opts.dimInds);
    for ii = 1:numel(Hs)
        hs2 = Hs{ii};
        opts.clr2 = plot.hypColor(hypNms{ii});
        if strcmpi(hypNms{ii}, 'habitual-corrected')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [-1.36 0.3];
        elseif strcmpi(hypNms{ii}, 'constant-cloud')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [-1.5 0.27];
        elseif strcmpi(hypNms{ii}, 'minimum')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [-7.5 0.27];
        elseif strcmpi(hypNms{ii}, 'best-mean')
            opts.lbl1 = [3 0.1];
            opts.lbl2 = [1 0.27];
        elseif strcmpi(hypNms{ii}, 'uncontrolled-uniform')
            opts.lbl1 = [0.0 0.2];
            opts.lbl2 = [5 0.15];
        elseif strcmpi(hypNms{ii}, 'uncontrolled-empirical')
            opts.lbl1 = [0.6 0.2];
            opts.lbl2 = [4.5 0.1];
        end
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

