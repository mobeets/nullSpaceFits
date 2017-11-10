function vals = plotProgsVsDistFromManif(blks, dec, kc, opts)

    M1c = (eye(size(dec.M1)) - dec.M1);
    proj = @(y) bsxfun(@plus, M1c\dec.M2*y', M1c\dec.M0)';
    % proj = @(y) bsxfun(@plus, dec.M2*y', dec.M0)';

    dsBase = omp.distanceFromManifold(blks(1).sps, kc);
    normDist = @(d) (d - min(dsBase))/(max(dsBase) - min(dsBase));

    grps = tools.thetaCenters;
    
    fig = plot.init;
    binds = 1:numel(blks);
    binds = [1 numel(blks)-1];
    % nrows = floor(sqrt(numel(binds)));
    % ncols = ceil(numel(binds)/nrows);

    nrows = floor(sqrt(numel(grps)));
    ncols = ceil(numel(grps)/nrows);
    vals = nan(numel(binds), numel(grps), 2);
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
%             cspsshift = bsxfun(@plus, csps, nanmean(blks(1).sps)- nanmean(cblk.sps));
%             cspsshift = csps;
            ds = normDist(omp.distanceFromManifold(cspsshift, kc));

            % get color based on day
            clrs = cblk.clr;

            bins = linspace(-0.3, 1.3, 21);
            Yrnrm = sqrt(sum(Yr.^2,2));
    %         Yr = proj(cspsshift);
            Yrnrm = lstmat.getProgress([], cblk.pos(ix,:), cblk.trgpos(ix,:), [], Yr);

    %         scatter(ds, Yrnrm, 1, clrs);
            xs = ds; ys = Yrnrm;
            vals(ii,kk,:) = [mean(xs) mean(ys)];
            [bp, mu, sigma] = plot.gauss2dcirc([xs ys], 2);
            plot(mu(1), mu(2), '.', 'Color', clrs);
            plot(bp(1,:), bp(2,:), '-', 'Color', clrs, 'LineWidth', 2);
            k = convhull(xs, ys);
    %         plot(xs(k), ys(k), '-', 'Color', clrs);
            xlim([min(bins) max(bins)]);
            ylim([0 600]);
            ylim([-400 600]);

            xlabel('dist. from manifold (normalized)');
            ylabel('progress');
            title([num2str(grps(kk)) '^\circ']);        
        end
    end
    plot.setPrintSize(gcf, struct('width', 2*ncols, 'height', 2*nrows));
    if opts.doSave
        fnm = fullfile(opts.saveDir, [opts.fnm '.pdf']);
        export_fig(gcf, fnm);
    end
end
