
dts = {'20160415', '20160505', '20160513', '20160529', ...
    '20160617', '20160628'};
doSave = false;

plot.init;
trgs = tools.thetaCenters;
for ii = 1:numel(dts)
    subplot(2,3,ii); hold on;
    dtstr = dts{ii};
    [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr);
    
    % show polar grid
    plot(0, 0, 'k+', 'HandleVisibility', 'off');
    ymx = 150;
    xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
%     plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
%         'HandleVisibility', 'off');
    for jj = 1:numel(trgs)
        plot([0 ymx*cosd(trgs(jj))], [0 ymx*sind(trgs(jj))], ...
            'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
    end
    
    % show actual progress
    dec = decs(2);
    clrs = [0.8 0.2 0.2; zeros(numel(blks)-3,3); 0.2 0.2 0.8; 0.8 0.2 0.2];
    xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
    lws = {1, 2};
    for jj = [1 numel(blks)-1 numel(blks)]
        cblk = blks(jj);
%         vels = dec.vfcn(cblk.sps')';
%         k = convhull(vels(:,1), vels(:,2));
        clr = clrs(jj,:);
%         plot(vels(k,1), vels(k,2), '-', 'Color', clr, ...
%             'LineWidth', lws{min(jj,2)});
%         continue;
        prgs = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, dec.vfcn);        
        ys = grpstats([prgs; -inf(numel(trgs),1)], [cblk.thgrps; trgs], 'nanmax');
        ys(ys < 0) = 0; ys = [ys; ys(1)];
%         clr = clrs(min(jj,2),:);
        plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clr, ...
            'LineWidth', lws{min(jj,2)});
    end
    axis off;
    axis equal;
    title(dtstr);
    continue;

    % show progress of min/max sps    
    clrs = cbrewer('qual', 'Set1', 8);
    lws = {1, 2};
    ssps = {blks(1).sps, blks(end-1).sps};
    cblks = blks([1 end-1]);
%     mus = {blks(1).spsBaseline, blks(end-1).spsBaseline};
    for jj = [2 1]
        sps = ssps{jj};        
        lts = zeros(10,1); lts(2) = 10;
        ksc = ks(1).kalmanInitParams;
        ksc.FactorAnalysisParams.ph = ksc.FactorAnalysisParams.Ph;
        ksc.spikeCountMean = ksc.NormalizeSpikes.mean;
        ksc.spikeCountStd = ksc.NormalizeSpikes.std;
        spsf = tools.latentsToSpikes(lts', ksc, false, false);
        
        cblk = cblks(jj);
        lts = omp.spikesToLatents(ks(1).kalmanInitParams, cblk.sps');
%         [~,maxind] = max(lts(:,1));
%         lts = bsxfun(@minus, lts, mean(lts));
        [~,maxind] = max(sum(lts.^2,2));
        spsf1 = cblk.sps(maxind,:);
        
%         sps1 = bsxfun(@minus, ssps{jj}, mus{jj});
        [~,maxind] = max(sum(sps.^2,2));
        [~,minind] = min(sum(sps.^2,2));
        csps = [0*min(sps); sps(minind,:); sps(maxind,:); spsf1];
        vs = dec.vfcn(csps')';
        for kk = 1:size(vs,1)
            plot([0 vs(kk,1)], [0 vs(kk,2)], '-', ...
                'LineWidth', lws{jj}, 'Color', clrs(kk+1,:));
        end
    end
%     legend({'Intuitive', ...
%         ['OMP-d' num2str(blks(end-1).dayInd)], ...
%         '0-firing', 'min-norm firing', 'max-norm firing'}, ...
%         'Location', 'BestOutside');
%     legend boxoff;
    
    axis off;
    axis equal;
    title(dtstr);
%     title([dtstr ': OMP max progress']);
%     plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
%     if doSave
%         export_fig(gcf, ['data/plots/omp/minmaxprog/prg-' dtstr '.pdf']);
%     end
end
plot.setPrintSize(gcf, struct('width', 8, 'height', 5));
if doSave
    export_fig(gcf, ['data/plots/omp/minmaxprog/vel-wash-int.pdf']);
end
