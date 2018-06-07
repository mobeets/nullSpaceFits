%% load

dirNm = 'nullSpace/2';

opts.doSave = false;
opts.saveDir = fullfile('data', 'plots', 'omp', dirNm);
opts.ext = 'pdf';

doMultiOMP = true;

dts = omp.getDates(doMultiOMP);
if doMultiOMP
    prefix = '';
else
    prefix = 'intOnly-';
end

doDebug = true;
ignoreWashout = false;

vols = [];
for ii = 8%1:numel(dts)
    dtstr = dts{ii}
    if ~doDebug
        try
            [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, ...
                true, false, ~doMultiOMP);
        catch
            continue;
        end
    end
    
    if ignoreWashout && strcmpi(blks(end).name, 'Washout')
        blks = blks(1:end-1);
    end

    dec = decs(1);
    
    nrows = 1; ncols = 2;
    blkinds = 1:numel(blks);
    blkinds = [numel(blks)-1];
    
    b0 = blks(1);
    dsBase = omp.distanceFromManifold(b0.sps, ks(1));
    normDist = @(d) (d - min(dsBase))/(max(dsBase) - min(dsBase));
    dsClrs = cbrewer('div', 'RdBu', 21);
    dsClrs = dsClrs(end:-1:1,:);
    
    plot.init;
    for jj = blkinds
        b = blks(jj);
        Y = b.sps(b.tms <= 10,:);
        if isempty(Y)
            continue;
        end
        
        Ys = bsxfun(@plus, Y, b0.spsBaseline - b.spsBaseline);
        vs1 = dec.vfcn(Y')';
        ds1 = normDist(omp.distanceFromManifold(Ys, ks(1)));
        ds = ds1;
        [~,bs] = histc(ds, linspace(0, 1, size(dsClrs,1)));
        bs(ds > 1) = size(dsClrs,1);
        bs(ds < 0) = 1;
        clrs1 = dsClrs(bs,:);
        clrs1(ds < 0,:) = repmat([0 0 1], sum(ds<0), 1);
        clrs1(ds > 1,:) = repmat([1 0 0], sum(ds>1), 1);
        
        mu = ks(1).kalmanInitParams.NormalizeSpikes.mean;
%         mu = nanmean(Y);
        grps = tools.thetaCenters;
%         Y = [];
%         for kk = 1:numel(grps)
%             for ll = 1:10
%                 ixc = (b.tms == ll) & (b.trgs == grps(kk));            
%                 mu = nanmean(b.sps(ixc,:));
%                 nc = sum(b.trgs(b.tms == ll) == grps(kk));
%                 Yc = poissrnd(repmat(mu, nc, 1));
%                 Y = [Y; Yc];
%             end
%         end
%         for ll = 1:10
%             ixc = (b.tms == ll);
%             mu = mean(grpstats(b.sps(ixc,:), b.trgs(ixc)));
% %             mu = nanmean(b.sps(ixc,:));
%             nc = sum(ixc);
%             Yc = poissrnd(repmat(mu, nc, 1));
%             Y = [Y; Yc];
%         end
        Y = poissrnd(repmat(mu, size(Y,1), 1));
        Ys = Y;
%         Ys = bsxfunn(@plus, Y, b0.spsBaseline - b.spsBaseline);        
        vs2 = dec.vfcn(Y')';
        ds2 = normDist(omp.distanceFromManifold(Ys, ks(1)));
        ds = ds2;
        [~,bs] = histc(ds, linspace(0, 1, size(dsClrs,1)));
        bs(ds > 1) = size(dsClrs,1);
        bs(ds < 0) = 1;
        clrs2 = dsClrs(bs,:);
        clrs2(ds < 0,:) = repmat([0 0 1], sum(ds<0), 1);
        clrs2(ds > 1,:) = repmat([1 0 0], sum(ds>1), 1);
        
        k = omp.convhullpct(vs1, 0.95);
        
        subplot(nrows, ncols, 1); hold on;
        plot(vs1(k,1), vs1(k,2), 'k-');
        scatter(vs1(:,1), vs1(:,2), 5, clrs1, '.');
        plot(0, 0, 'k+');
        xl = xlim; yl = ylim;
        xlim(xl); ylim(yl);
        
        subplot(nrows, ncols, 2); hold on;        
        plot(vs1(k,1), vs1(k,2), 'k-');
        scatter(vs2(:,1), vs2(:,2), 5, clrs2, '.');
        plot(0, 0, 'k+');
        xlim(xl); ylim(yl);
        
    end
    plot.setPrintSize(gcf, struct('width', 3*ncols, 'height', 2.7*nrows));
    if opts.doSave
        fnm = fullfile(opts.saveDir, [prefix dtstr '.pdf']);
        export_fig(gcf, fnm);
    end
    
%     omp.plotConditionAveragedVels(blks, dec, opts);
end

%%

plot.init;
xs = unique(vols(:,1));
for ii = 1:numel(xs)
    subplot(1,4,ii); hold on;
    ix = (vols(:,1) == xs(ii)) & (~vols(:,3));
    vs = vols(ix,:);
    
    mu = vols(vols(:,1) == xs(ii) & vols(:,2) == 1,:);
    vs = bsxfun(@minus, vs, mu);
    
%     ylim([-500 200]);
    xlim([-1e4 1.5e4]);
    
    ylim([-400 300]);
%     xlim([-2e4 2e4]);
    plot(xlim, [0 0], '-', 'Color', 0.8*ones(3,1));
    plot([0 0], ylim, '-', 'Color', 0.8*ones(3,1));
    
    plot(vs(1,4), vs(1,5), 'k+');
    plot(vs(:,4), vs(:,5), '.-');
    plot(vs(end,4), vs(end,5), 'ko');
    xlabel('\Delta row space vol');
    ylabel('\Delta null space vol');
    title(dts{ii});
    
end

%%

plot.init;
plot([0 0], yl, '-', 'Color', 0.8*ones(3,1));
plot(xl, [0 0], '-', 'Color', 0.8*ones(3,1));

clrs = cbrewer('seq', 'Reds', numel(avsInt)+1); clrs = clrs(2:end,:);
for ii = 3:numel(avsInt)
    vs = squeeze(diff(avsInt{ii}));
    h = plot(vs(:,1), vs(:,2), '.', 'Color', clrs(ii,:));
    mu = median(vs);
    plot(mu(1), mu(2), '.', 'MarkerSize', 20, 'Color', clrs(2,:));
end

clrs = cbrewer('seq', 'Blues', numel(avsP)+1); clrs = clrs(2:end,:);
for ii = 11:numel(avsP)
    vs = squeeze(diff(avsP{ii}));
    if isempty(vs)
        continue;
    end
    h = plot(vs(:,1), vs(:,2), '.', 'Color', clrs(ii,:));
    mu = median(vs);
    plot(mu(1), mu(2), '.', 'MarkerSize', 20, 'Color', clrs(10,:));
end
xlabel('\Delta distance');
ylabel('\Delta progress');
xlim(xl);
ylim(yl);

