function stats = plotImeErrors(dtstr, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('doSave', false, 'doPlot', false, ...
        'width', 5, 'height', 4, 'FontSize', 20, 'LineWidth', 2, ...
        'saveDir', 'data/plots');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    d = load(io.pathToIme(dtstr));

    % intuitive stats
    by_trial = d.Stats{1}.by_trial;
    scale = 1.96/sqrt(numel(by_trial.cErrs));
    iErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    iErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    jErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    jErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));

    % perturbation stats
    by_trial = d.Stats{2}.by_trial;
    scale = 1.96/sqrt(numel(by_trial.cErrs));
    cErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    cErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    stats = [iErrAvg jErrAvg cErrAvg mErrAvg ...
                iErrStd jErrStd cErrStd mErrStd];

    if ~opts.doPlot        
        return;
    end

    % plot bars
    plot.init;
    xts = [1 3 5 7];
    bar(xts, [iErrAvg jErrAvg cErrAvg, mErrAvg], 'FaceColor', [1 1 1], ...
        'EdgeColor', [0 0 0], 'LineWidth', lw);
    plot([xts(1) xts(1)], [iErrAvg-iErrStd iErrAvg+iErrStd], 'k-');
    plot([xts(2) xts(2)], [jErrAvg-jErrStd jErrAvg+jErrStd], 'k-');
    plot([xts(3) xts(3)], [cErrAvg-cErrStd cErrAvg+cErrStd], 'k-');
    plot([xts(4) xts(4)], [mErrAvg-mErrStd mErrAvg+mErrStd], 'k-');
    nms = {'1st mapping', '1st mapping (IME)', ...
        '2nd mapping', '2nd mapping (IME)'};
    ylabel('Abs. angular cursor error (deg)');

    % adjust plot formatting
    set(gca, 'XTickLabel', nms, 'XTick', xts, 'XTickLabelRotation', 45);
    ymx = 10;
    ylim([0 ymx]);
    set(gca, 'YTick', 0:5:ymx);
    axis square;
    set(gca, 'FontSize', opts.FontSize);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);

    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            ['imeAvgPerf_' dtstr '.pdf']));
    end
end
