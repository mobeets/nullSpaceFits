function plotSSSEllipseSingle(YA, YB, CA, CB, opts)
    if nargin < 5
        opts = struct();
    end
    defopts = struct('width', 4, 'height', 4, 'margin', 0.125, ...
        'FontSize', 16, 'FontName', 'Helvetica', 'TextNote', '', ...
        'LineWidth', 3, 'TextNoteFontSize', 14, ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'SSS_ellipse', 'ext', 'pdf', ...
        'clrs', [], 'sigMult', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init(opts.FontSize, opts.FontName);
    
    % mean-center data, because we just want to compare variance
    muA = mean(YA);
    muB = mean(YB);
    YA = bsxfun(@plus, YA, -muA);
    YB = bsxfun(@plus, YB, -muB);
    muA = mean(YA);
    muB = mean(YB);
    
    [bpA, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CA);
    [bpB, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CB);

    plot(YA(:,1), YA(:,2), '.', 'Color', opts.clrs(1,:));
    plot(YB(:,1), YB(:,2), '.', 'Color', opts.clrs(2,:));
    % plot(muA(1), muB(2), '.', 'Color', opts.clrs(1,:), ...
    %     'MarkerSize', 40);
    % plot(muB(1), muB(2), '.', 'Color', opts.clrs(2,:), ...
    %     'MarkerSize', 40);

    bpA(1,:) = bpA(1,:) + muA(1);
    bpA(2,:) = bpA(2,:) + muA(2);
    bpB(1,:) = bpB(1,:) + muB(1);
    bpB(2,:) = bpB(2,:) + muB(2);
    plot(bpA(1,:), bpA(2,:), '-', 'Color', opts.clrs(1,:), 'LineWidth', 2);
    plot(bpB(1,:), bpB(2,:), '-', 'Color', opts.clrs(2,:), 'LineWidth', 2);

    pad = 0.5;
    minx = min([bpA(1,:) bpB(1,:)]);
    miny = min([bpA(2,:) bpB(2,:)]);
    maxx = max([bpA(1,:) bpB(1,:)]);
    maxy = max([bpA(2,:) bpB(2,:)]);
    xlim([minx-pad maxx+pad]);
    ylim([miny-pad maxy+pad]);

    xlabel('Activity, dim. 1 (spikes/timebin)');
    ylabel('Activity, dim. 2 (spikes/timebin)');
    set(gca, 'XTick', [0]);
    set(gca, 'YTick', [0]);
    set(gca, 'TickDir', 'out');
    set(gca, 'LineWidth', max(opts.LineWidth-1,1));
    box off;
    axis equal;

    xl = xlim; yl = ylim;
    text(0.3*xl(2), 0.95*yl(2), 'Data', 'Color', opts.clrs(1,:), ...
        'FontSize', opts.TextNoteFontSize);
    text(0.3*xl(2), 0.95*yl(2) - 0.3, opts.TextNote, 'Color', opts.clrs(2,:), ...
        'FontSize', opts.TextNoteFontSize);

    plot.setPrintSize(fig, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end