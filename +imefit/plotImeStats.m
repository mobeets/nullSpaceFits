function fig = plotImeStats(D, bind, mdlErrs, cErrs, by_trial)

    trialNo = 1;
%     imefit.plotWhiskers(D, bind, trialNo, doLatents);
    
    fig = plot.init;
    
    % scatter of cursor and ime errors
    subplot(1,2,1); hold on; set(gca, 'FontSize', 18);
    plot(mdlErrs, cErrs, '.');
    xlabel('internal model error (deg)');
    ylabel('cursor error (deg)');
    title([D.datestr ' Blk' num2str(bind)]);
    xlim([0 180]); ylim(xlim);
    set(gca, 'XTick', 0:45:180);
    set(gca, 'YTick', 0:45:180);
    axis square;
    
    % bar plot of average angular errors
    scale = 2/sqrt(numel(by_trial.cErrs));
    cErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    cErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    
    subplot(1,2,2); hold on; set(gca, 'FontSize', 18);
    bar(1:2, [cErrAvg, mErrAvg], 'FaceColor', [1 1 1], ...
        'EdgeColor', [0 0 0], 'LineWidth', 1);
    plot([1 1], [cErrAvg-cErrStd cErrAvg+cErrStd], 'k-');
    plot([2 2], [mErrAvg-mErrStd mErrAvg+mErrStd], 'k-');
    nms = {'cursor', 'ime'};
    set(gca, 'XTickLabel', nms, 'XTick', 1:numel(nms));
    ymx = ceil(max([cErrAvg+cErrStd, mErrAvg+mErrStd]));
    ylim([0 ymx]);
    ytcks = unique(round(get(gca, 'YTick')));
    set(gca, 'YTick', ytcks);
    ylabel('absolute angular error (deg)');
    title([D.datestr ' Blk' num2str(bind)]);
    axis square;

end
