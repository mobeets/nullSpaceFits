function plotVelsColoredByDistFromManif(blks, dec, kc, opts)

    M1c = (eye(size(dec.M1)) - dec.M1);
    proj = @(y) bsxfun(@plus, M1c\dec.M2*y', M1c\dec.M0)';
    dsBase = omp.distanceFromManifold(blks(1).sps, kc);
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
%             ix = ix & (dists >= 15);

            csps = cblk.sps(ix,:);        
            Yr = proj(csps);

            % get color based on distance to manifold
            mu0 = blks(1).spsBaseline;
            mu1 = cblk.spsBaseline;
            cspsshift = bsxfun(@plus, csps, mu0 - mu1);
%             cspsshift = csps;
            ds = normDist(omp.distanceFromManifold(cspsshift, kc));
            [~,bs] = histc(ds, linspace(0, 1, size(dsClrs,1)));
            bs(ds > 1) = size(dsClrs,1);
            bs(ds < 0) = 1;
            clrs = dsClrs(bs,:);
            clrs(ds < 0,:) = repmat([0 0 1], sum(ds<0), 1);
            clrs(ds > 1,:) = repmat([1 0 0], sum(ds>1), 1);

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
            [k, v] = omp.convhullpct(Yri, 0.98); bs = Yri(k,:);
            plot(bs(:,1), bs(:,2), '--', 'Color', [0.8 0.2 0.2], 'LineWidth', 2);

            % show current boundary (for all points)
            Yri = proj(cblk.sps);
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
    if opts.doSave
        fnm = fullfile(opts.saveDir, [opts.fnm '.pdf']);
        export_fig(gcf, fnm);
    end
end
