function plotImeErrorsAll(dts, opts)
    if nargin < 1
        dts = io.getDates;
    end
    if nargin < 2
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots', ...
        'width', 5, 'height', 4, 'FontSize', 20, 'LineWidth', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    % load stats
    stats = [];
    for ii = 1:numel(dts)
        dtstr = dts{ii};
        stats = [stats; plot.plotImeErrors(dtstr)];
    end

    plot.init;
    xs = stats(:,3);
    ys = stats(:,4);
    mnks = io.getMonkeys;
    mnkNms = {};
    for ii = 1:numel(mnks)
        ix = io.getMonkeyDateFilter(dts, mnks(ii));
        plot(xs(ix), ys(ix), '.', 'MarkerSize', 25);
        mnkNms{ii} = ['Monkey ' mnks{ii}(1)];
    end

    vmx = max([xs; ys]);
    xlim([0 vmx]);
    ylim(xlim);
    plot(xlim, ylim, 'k--', 'LineWidth', opts.LineWidth);

    set(gca, 'XTick', 0:10:vmx);
    set(gca, 'YTick', 0:10:vmx);

    xlabel({'Absolute angular error (deg),', '2nd mapping'});
    ylabel({'Absolute angular error (deg),', '2nd mapping (IME)'});
    axis square;
    set(gca, 'FontSize', opts.FontSize);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);
    
    legend(mnkNms, 'Location', 'NorthWest');
    legend boxoff;
    
    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, 'imeErrsAll.pdf'));
    end
end
