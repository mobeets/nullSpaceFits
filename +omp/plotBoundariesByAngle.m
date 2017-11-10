%% multi-day OMP

dts = omp.getDates;
dtstr = dts{2}
[blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, true, false);

%% multi-day intuitive

dts = {'20150212', '20150308', '20160717'};
dtstr = dts{3};
[blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, true, false, true);

%% visualize cluster of pds

dec = decs(2);
plot.init;
for ii = 1:size(dec.M2,2)
    plot(dec.M2(1,ii), dec.M2(2,ii), 'rx');
end
plot(0,0,'k+');

%% visualize distance of points from manifold

dec = decs(2);
M1c = (eye(size(dec.M1)) - dec.M1);
proj = @(y) bsxfun(@plus, M1c\dec.M2*y', M1c\dec.M0)';
dsBase = omp.distanceFromManifold(blks(1).sps, ks);
normDist = @(d) (d - min(dsBase))/(max(dsBase) - min(dsBase));
dsClrs = cbrewer('div', 'RdBu', 21);
dsClrs = dsClrs(end:-1:1,:);

Yrc = [];
for ii = 1:(numel(blks)-1)
    Yrct = proj(blks(ii).sps);
    Yrc = [Yrc; Yrct(:,1:2)];
end
figure; [~, ctrs] = clouds.showHeatmap(Yrc); close;
mrg = 0;

grps = tools.thetaCenters;
thgrp = grps(8);

fig = plot.init;
binds = [1 2 numel(blks)-1];
% binds = 1:numel(blks);
for kk = 1%:16
    clf;   
    for ii = 1:numel(binds)
        subplot(1, numel(binds), ii); hold on;
        set(gca, 'ydir', 'normal');

        cblk = blks(binds(ii));
        ix = (cblk.tms == kk) & (cblk.thgrps == thgrp);
%         ix = cblk.tms <= 16;
        ix = cblk.tms >= 7;
        
        % ignore when cursor too close to target (starts at 125 away)
        dists = sqrt(sum((cblk.pos - cblk.trgpos).^2,2));
        ix = ix & (dists >= 15);
        
        csps = cblk.sps(ix,:);        
        Yr = proj(csps);
        
        % get color based on distance to manifold
        mu0 = mean(blks(1).sps(blks(1).tms <= 3,:));
        mu1 = mean(cblk.sps(cblk.tms <= 3,:));
        cspsshift = bsxfun(@plus, csps, mu0 - mu1);
%         cspsshift = csps;
        ds = normDist(omp.distanceFromManifold(cspsshift, ks));
        [~,bs] = histc(ds, linspace(0, 1, size(dsClrs,1)));
        bs(ds > 1) = size(dsClrs,1);
        bs(ds < 0) = 1;
        clrs = dsClrs(bs,:);
%         clrs((ds >= 0.05) | (ds <= 0.95),:) = repmat([0.5 0.5 0.5], sum((ds >= 0.05) | (ds <= 0.95)), 1);
        clrs(ds < 0,:) = repmat([0 0 1], sum(ds<0), 1);
        clrs(ds > 1,:) = repmat([1 0 0], sum(ds>1), 1);
        
%         clrs = cbrewer('div', 'RdYlGn', numel(grps));
%         clrs = omp.scaleToColor(cblk.thgrps/max(grps), clrs);
        
        % show boundary of landmarks
        [~,ind] = max(sum(csps.^2,2));
        spsrnd = [0*min(csps)];
        Yrm = proj(spsrnd);
        lclrs = cbrewer('qual', 'Set1', 8);
        for jj = 1:size(Yrm,1)
            plot(Yrm(jj,1), Yrm(jj,2), '+', 'Color', lclrs(jj,:));
        end

        % show pts during this block
        inds = randperm(size(Yr,1));
        scatter(Yr(inds,1), Yr(inds,2), 1, clrs(inds,:), '.');
        
        % show boundary during intuitive (with shifted baseline)
        muShift = cblk.spsBaseline - blks(1).spsBaseline;
        isps = bsxfun(@plus, blks(1).sps, muShift);
        Yri = proj(isps);        
%         k = convhull(Yri(:,1), Yri(:,2)); bs = Yri(k,:);
        [k, v] = omp.convhullpct(Yri, 0.98); bs = Yri(k,:);
        plot(bs(:,1), bs(:,2), '--', 'Color', [0.8 0.2 0.2], 'LineWidth', 2);
        
        % show current boundary (for all points)
        Yri = proj(cblk.sps);
%         k = convhull(Yri(:,1), Yri(:,2)); bs = Yri(k,:);
        [k, v] = omp.convhullpct(Yri, 0.98); bs = Yri(k,:);
        plot(bs(:,1), bs(:,2), '-', 'Color', [0.8 0.2 0.2], 'LineWidth', 2);
        
        % show origin and goal velocity
        plot(0, 0, 'y+', 'LineWidth', 2);
        r = max(ctrs{1});
%         plot([0 r*cosd(thgrp)], [0 r*sind(thgrp)], 'w-', 'LineWidth', 1);

        axis off;        
        xlim([min(ctrs{1})-mrg max(ctrs{1})+mrg]);
        ylim([min(ctrs{2})-mrg max(ctrs{2})+mrg]);        
        plot.setPrintSize(gcf, struct('width', 10, 'height', 3));
        axis equal;
        
        set(gcf, 'color', 'k');
        title([cblk.name ' through OMP, t=' num2str(kk)], 'Color', 'w');
    end
    continue;
    fnm = ['data/plots/omp/time/' dtstr '_' num2str(thgrp) '.gif'];
    if kk == 1
        gif(fnm, 'frame', fig, 'DelayTime', 0.2);
    else
        gif;
    end
%     export_fig(gcf, ['data/plots/omp/time/' dtstr '_' num2str(thgrp) '-' num2str(kk) '.pdf']);
end

%% distances from manifold

bins = linspace(0, 35);
plot.init;
pts = nan(numel(blks),2);
for ii = 1:numel(blks)
    cblk = blks(ii);
    subplot(1, numel(blks), ii); hold on;
    
    % filter
    ix = cblk.tms >= 5;
    ix = true(size(ix));
    csps = cblk.sps(ix,:);
    
    % baseline corretion
%     csps = bsxfun(@plus, csps, blks(1).spsBaseline - cblk.spsBaseline);
    
    % get distances
    ds = omp.distanceFromManifold(csps, ks);
    
    % plot
    cs = histc(ds, bins);
    pts(ii,:) = [mean(ds) var(ds)];
    plot(cs, bins, '-', 'Color', cblk.clr);
    plot([0 max(cs)], [mean(ds) mean(ds)], '-', 'Color', cblk.clr, ...
        'LineWidth', 2); 
    
    if ii == 1
        ylabel('distance from manifold');
        xlabel('# of timesteps');
    else
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
    end
    title(cblk.name);
end
plot.setPrintSize(gcf, struct('width', 1*numel(blks), 'height', 2));

%% visualize distribution of distances

dec = decs(2);
M1c = (eye(size(dec.M1)) - dec.M1);
proj = @(y) bsxfun(@plus, M1c\dec.M2*y', M1c\dec.M0)';
% proj = @(y) bsxfun(@plus, dec.M2*y', dec.M0)';

dsBase = omp.distanceFromManifold(blks(1).sps, ks);
normDist = @(d) (d - min(dsBase))/(max(dsBase) - min(dsBase));
dsClrs = cbrewer('div', 'RdBu', 21);
dsClrs = dsClrs(end:-1:1,:); % go from blue to red

grps = tools.thetaCenters;
% dsClrs = cbrewer('div', 'RdYlGn', numel(grps));

fig = plot.init;
binds = 1:numel(blks);
binds = [1 numel(blks)-1];
% nrows = floor(sqrt(numel(binds)));
% ncols = ceil(numel(binds)/nrows);

nrows = floor(sqrt(numel(grps)));
ncols = ceil(numel(grps)/nrows);
for kk = 1:numel(grps)
    for ii = 1:numel(binds)
        subplot(nrows, ncols, kk); hold on;
        cblk = blks(binds(ii));

%         ix = (cblk.tms == kk) & (cblk.thgrps == thgrp);
%         ix = cblk.tms <= 16;
        ix = cblk.tms >= 7;
%         ix = (cblk.tms >= 3) & (cblk.tms <= 10);
        ix = ix & (cblk.thgrps == grps(kk));
%         ix = ix & (cblk.trgs == grps(kk));
        
%         if cblk.dayInd == 8
%             ix = ix & (cblk.trs >= 348) & (cblk.trs <= 348+40);
%         end
        if sum(ix) == 0
            continue;
        end        

        % ignore when cursor too close to target (starts at 125 away)
%         dists = sqrt(sum((cblk.pos - cblk.trgpos).^2,2));
%         ix = ix & (dists >= 15);

        csps = cblk.sps(ix,:);
        
        % correct for baseline shift
%         csps = bsxfun(@plus, csps, blks(end-1).spsBaseline - cblk.spsBaseline);
        
        Yr = proj(csps);

        % get distances to manifold
        csps = cblk.sps(ix,:);
        cspsshift = bsxfun(@plus, csps, blks(1).spsBaseline - cblk.spsBaseline);
        cspsshift = bsxfun(@plus, csps, nanmean(blks(1).sps)- nanmean(cblk.sps));
%         cspsshift = csps;
        ds = normDist(omp.distanceFromManifold(cspsshift, ks));

        % get color based on day
        clrs = cblk.clr;

        bins = linspace(-0.3, 1.3, 21);
        Yrnrm = sqrt(sum(Yr.^2,2));
%         Yr = proj(cspsshift);
        Yrnrm = lstmat.getProgress([], cblk.pos(ix,:), cblk.trgpos(ix,:), [], Yr);

%         scatter(ds, Yrnrm, 1, clrs);
        xs = ds; ys = Yrnrm;
        [bp, mu, sigma] = plot.gauss2dcirc([xs ys], 2);
        plot(mu(1), mu(2), '.', 'Color', clrs);
        plot(bp(1,:), bp(2,:), '-', 'Color', clrs, 'LineWidth', 2);
        k = convhull(xs, ys);
%         plot(xs(k), ys(k), '-', 'Color', clrs);
        xlim([min(bins) max(bins)]);
        ylim([0 600]);
        ylim([-400 600]);
        
%         clrs = omp.scaleToColor(ds, dsClrs);
%         scatter(Yr(:,1), Yr(:,2), 1, clrs);
%         xs = Yr(:,1); ys = Yr(:,2);
%         k = convhull(xs, ys);
%         plot(xs(k), ys(k), '-', 'Color', cblk.clr);
%         xlim([-500 500]);
%         ylim(xlim);

        xlabel('dist. from manifold (normalized)');
        ylabel('progress');
        title([num2str(grps(kk)) '^\circ']);        
    end
end
plot.setPrintSize(gcf, struct('width', 2*ncols, 'height', 2*nrows));

%%

dec = decs(2);
maxTm = 10;

grps = tools.thetaCenters;
clrs = cbrewer('div', 'RdYlGn', numel(grps));

binds = [1 numel(blks)];
binds = 1:numel(blks);
nrows = floor(sqrt(numel(binds)));
ncols = ceil(numel(binds)/nrows);

plot.init;

for ii = 1:numel(binds)
    subplot(nrows, ncols, ii); hold on;
    cblk = blks(ii);
    
    ix = cblk.tms <= 10;
    gs = [cblk.tms(ix) cblk.trgs(ix)];
    ys = grpstats(cblk.sps(ix,:), gs);
    vs = dec.vfcn(ys')';
    xs = unique(gs, 'rows');
    
    ysAvg = grpstats(ys, xs(:,1));    
    
    for jj = 1:numel(grps)
        ixc = (xs(:,2) == grps(jj));
%         plot(vs(ixc,1), vs(ixc,2), '-', 'Color', clrs(jj,:));
        
        vsc = nan(maxTm,2);
        for t = 1:maxTm
            ysc = ys(ixc & (xs(:,1) == t),:) - (ysAvg(t,:) - cblk.spsBaseline);
%             ysc = ys(ixc & (xs(:,1) == t),:) - (ysAvg(t,:));
            vsc(t,:) = dec.vfcn(ysc')';
        end
        plot(vsc(:,1), vsc(:,2), '-', 'Color', clrs(jj,:));
    end
    
    axis equal;
%     xlim([-120 120]); ylim(xlim);    
end
plot.setPrintSize(gcf, struct('width', 3*ncols, 'height', 3*nrows));
