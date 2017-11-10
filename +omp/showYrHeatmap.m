dtstr = '20160617';
[blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, true, false);

%%

dec = decs(2);
% proj = @(y) y*dec.RB;
M1c = (eye(size(dec.M1)) - dec.M1);
proj = @(y) bsxfun(@plus, M1c\dec.M2*y', M1c\dec.M0)';

dimInds = 1:2;
fitFA = false;

if fitFA
    bsps = omp.sampleTimestepsEvenly(blks(end-1).sps, blks(end-1).trs, 1);
    csps = squeeze(bsps(1,:,:));
%     params = omp.fitFA(csps, 10);
    newDec = params{1};
    proj = @(y) omp.spikesToLatents(newDec, y', true);    
else
%     proj = @(y) omp.spikesToLatents(ks(1).kalmanInitParams, y', true);
end

Yrc = [];
for ii = 1:numel(blks)
    Yrct = proj(blks(ii).sps);
    Yrc = [Yrc; Yrct(:,dimInds)];
end
figure; [~, ctrs] = clouds.showHeatmap(Yrc); close;

mrg = 1;

thgrp = 45;

plot.init;
for kk = 1:16
    clf;    
    for ii = 1:numel(blks)
        subplot(2, ceil(numel(blks)/2), ii); hold on;

        cblk = blks(ii);
        ix = (cblk.tms == kk) & (cblk.thgrps == thgrp);
        [bsps, newinds] = omp.sampleTimestepsEvenly(cblk.sps(ix,:), ...
            cblk.trs(ix), 2);
        bsps = [bsps(1,:,:) bsps(2,:,:)];
        csps = squeeze(bsps(1,:,:));
        Yr = proj(csps);
        Yr = Yr(:,dimInds);    

        % show heatmap
        h = clouds.showHeatmap(Yr, ctrs);
        set(gca, 'ydir', 'normal');

        % show boundary of landmarks
        [~,ind] = max(sum(csps.^2,2));
        [~,minind] = min(sum(csps.^2,2));
        spsrnd = [0*min(csps); median(csps); csps(ind,:); csps(minind,:)];
        Yrm = proj(spsrnd);
        Yrm = Yrm(:,dimInds);
        clrs = cbrewer('qual', 'Set1', 8);
        for jj = 1:size(Yrm,1)
            plot(Yrm(jj,1), Yrm(jj,2), '+', 'Color', clrs(jj,:));
        end

        % show boundary during intuitive (with shifted baseline)
        muShift = cblk.spsBaseline - blks(1).spsBaseline;
        isps = bsxfun(@plus, blks(1).sps, muShift);
    %     isps = blks(1).sps;
        Yri = proj(isps);
        Yri = Yri(:,dimInds);
        k = convhull(Yri(:,1), Yri(:,2)); bs = Yri(k,:);
        plot(bs(:,1), bs(:,2), '-', 'Color', 0.5*ones(3,1));

        % show boundary during this block
        k = convhull(Yr(:,1), Yr(:,2)); bs = Yr(k,:);
        plot(bs(:,1), bs(:,2), 'w-');

        % show origin
        plot(0, 0, 'w+');

        axis off;
    %     axis equal;
        xlim([min(ctrs{1})-mrg max(ctrs{1})+mrg]);
        ylim([min(ctrs{2})-mrg max(ctrs{2})+mrg]);
        set(gcf, 'color', 'k');
        title([cblk.name ' dims ' num2str(dimInds)], 'Color', 'w');
    %     title([cblk.name ' vel. through OMP'], 'Color', 'w');
    end
    export_fig(gcf, ['data/plots/omp/time/' dtstr '_' num2str(thgrp) '-' num2str(kk) '.pdf']);
end

%%

plot.init;
ns = nan(numel(blks),2);
nboots = 10;
for ii = 1:numel(blks)
    subplot(2, ceil(numel(blks)/2), ii); hold on;
    set(gca, 'FontSize', 16);
    
    % current block activity
    cblk = blks(ii);
    [bsps, newinds] = omp.sampleTimestepsEvenly(cblk.sps, cblk.trs, nboots);
    
    % intuitive block activity (mean-shifted)
    muShift = cblk.spsBaseline - blks(1).spsBaseline;
    isps = bsxfun(@plus, blks(1).sps, muShift);
%     isps = blks(1).sps;
    Yri = proj(isps);
    Yri = Yri(:,dimInds);
    k = convhull(Yri(:,1), Yri(:,2));

    prgs = nan(nboots, 4);
    for jj = 1:nboots
        csps = squeeze(bsps(jj,:,:));
        Yr = proj(csps);
        Yr = Yr(:,dimInds);
        isIns = inpolygon(Yr(:,1), Yr(:,2), Yri(k,1), Yri(k,2));

        indsIn = unique(newinds(isIns));
        indsOut = unique(newinds(~isIns));
        ns(ii,:) = [numel(indsIn) numel(indsOut)];

        prgs(jj,1) = nanmean(lstmat.getProgress(cblk.sps(indsIn,:), cblk.pos(indsIn,:), ...
            cblk.trgpos(indsIn,:), decs(1).vfcn));
        prgs(jj,2) = nanmean(lstmat.getProgress(cblk.sps(indsOut,:), cblk.pos(indsOut,:), ...
            cblk.trgpos(indsOut,:), decs(1).vfcn));
        prgs(jj,3) = nanmean(lstmat.getProgress(cblk.sps(indsIn,:), cblk.pos(indsIn,:), ...
            cblk.trgpos(indsIn,:), decs(2).vfcn));
        prgs(jj,4) = nanmean(lstmat.getProgress(cblk.sps(indsOut,:), cblk.pos(indsOut,:), ...
            cblk.trgpos(indsOut,:), decs(2).vfcn));
    end
    mus = nanmean(prgs);
    mus(isnan(mus)) = 0;
    bar(1, mus(1), 'EdgeColor', [0.8 0.2 0.2], 'FaceColor', 'w');
    bar(2, mus(2), 'EdgeColor', [0.8 0.2 0.2], 'FaceColor', 'w', 'HandleVisibility', 'off');
    bar(3, mus(3), 'EdgeColor', [0.2 0.2 0.8], 'FaceColor', 'w');
    bar(4, mus(4), 'EdgeColor', [0.2 0.2 0.8], 'FaceColor', 'w');
    
    ses = nanstd(prgs)/sqrt(nboots);
    plot([1 1], mus(1) + [-ses(1) ses(1)], '-', 'Color', [0.8 0.2 0.2]);
    plot([2 2], mus(2) + [-ses(2) ses(2)], '-', 'Color', [0.8 0.2 0.2]);
    plot([3 3], mus(3) + [-ses(3) ses(3)], '-', 'Color', [0.2 0.2 0.8]);
    plot([4 4], mus(4) + [-ses(4) ses(4)], '-', 'Color', [0.2 0.2 0.8]);
    
    ylim([0 70]);
    set(gca, 'XTick', 1:4);
    set(gca, 'XTickLabel', {'inside hull', 'outside hull', ...
        'inside hull', 'outside hull'});
    set(gca, 'XTickLabelRotation', 45);
    if ii == 1
        legend({'intuitive dec.', 'OMP dec.'});
        legend boxoff;
    end
    ylabel('avg progress');
end
