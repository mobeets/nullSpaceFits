function plotImeErrorsAll(dts, opts)
    if nargin < 1
        dts = io.getDates;
    end
    if nargin < 2
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots', ...
        'width', 5, 'height', 4, 'FontSize', 20, 'LineWidth', 2, ...
        'blkInd', 1, 'vmx', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    % load stats
    stats = [];
    for ii = 1:numel(dts)
        dtstr = dts{ii};
        stats = [stats; plot.plotImeErrors(dtstr)];
    end

    plot.init;
    if opts.blkInd == 1 % compare Blk1 with and without IME
        xs = stats(:,1);
        ys = stats(:,2);
        xlbl = '1st mapping';
        ylbl = '1st mapping (IME)';
    elseif opts.blkInd == 2 % compare Blk2 with and without IME
        xs = stats(:,3);
        ys = stats(:,4);
        xlbl = '2nd mapping';
        ylbl = '2nd mapping (IME)';    
    elseif opts.blkInd == 3 % compare Blk2 to Blk1, without IME
        xs = stats(:,1);
        ys = stats(:,3);
        xlbl = '1st mapping';
        ylbl = '2nd mapping';
    elseif opts.blkInd == 4 % compare Blk2 to Blk1, with IME
        xs = stats(:,2);
        ys = stats(:,4);
        xlbl = '1st mapping (IME)';
        ylbl = '2nd mapping (IME)';
    elseif opts.blkInd == 5 % compare Blk2 (IME) to Blk1 (no IME)
        xs = stats(:,1);
        ys = stats(:,4);
        xlbl = '1st mapping';
        ylbl = '2nd mapping (IME)';
    end
    mnks = io.getMonkeys;
    mnkNms = {};
    for ii = 1:numel(mnks)
        ix = io.getMonkeyDateFilter(dts, mnks(ii));
        plot(xs(ix), ys(ix), '.', 'MarkerSize', 25);
        mnkNms{ii} = ['Monkey ' mnks{ii}(1)];
    end

    if isnan(opts.vmx)
        vmx = max([xs; ys]);
    else
        vmx = opts.vmx;
    end
    xlim([0 vmx]);
    ylim(xlim);
    plot(xlim, ylim, 'k--', 'LineWidth', opts.LineWidth);

    set(gca, 'XTick', 0:5:vmx);
    set(gca, 'YTick', 0:5:vmx);

    xlabel({'Absolute angular error (deg),', xlbl});
    ylabel({'Absolute angular error (deg),', ylbl});
    axis square;
    set(gca, 'FontSize', opts.FontSize);
    set(gca, 'TickDir', 'out');
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);
    
    h = legend(mnkNms, 'Location', 'SouthEast');
%     set(h, 'EdgeColor', 'w');
    legend boxoff;
    
    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            ['imeErrsAll-' num2str(opts.blkInd) '.pdf']));
    end
end
