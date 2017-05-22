function plotSSSEllipseSingle(YA, YB, CA, CB, opts)
    if nargin < 5
        opts = struct();
    end
    defopts = struct('width', 4, 'height', 4, 'margin', 0.125, ...
        'FontSize', 16, 'FontName', 'Helvetica', 'TextNoteA', '', ...
        'TextNoteB', '', ...
        'LineWidth', 3, 'TextNoteFontSize', 14, ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'SSS_ellipse', 'ext', 'pdf', ...
        'clrs', [], 'sigMult', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init(opts.FontSize, opts.FontName);
    
    % swap axes
%     YA(:,2) = -YA(:,2);
%     YB(:,2) = -YB(:,2);

    % mean-center data, because we just want to compare variance
    muA = mean(YA);
    muB = mean(YB);
    YA = bsxfun(@plus, YA, -muA);
    YB = bsxfun(@plus, YB, -muB);
    muA = mean(YA);
    muB = mean(YB);
    
    [bpA, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CA);
    [bpB, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CB);    

%     plot(YA(:,1), YA(:,2), 'o', 'Color', opts.clrs(1,:), 'MarkerSize', 4);
    plot(YA(:,1), YA(:,2), '.', 'Color', opts.clrs(1,:), 'MarkerSize', 8);
    plot(YB(:,1), YB(:,2), '.', 'Color', opts.clrs(2,:), 'MarkerSize', 8);
    
    bpA(1,:) = bpA(1,:) + muA(1);
    bpA(2,:) = bpA(2,:) + muA(2);
    bpB(1,:) = bpB(1,:) + muB(1);
    bpB(2,:) = bpB(2,:) + muB(2);
    plot(bpA(1,:), bpA(2,:), '-', 'Color', opts.clrs(1,:), 'LineWidth', 2);
%     plot(bpB(1,:), bpB(2,:), '-', 'Color', opts.clrs(2,:), 'LineWidth', 2);
    h = patch(bpB(1,:), bpB(2,:), opts.clrs(2,:));
    h.FaceAlpha = 0.5;
    h.EdgeColor = 'none';

    pad = 0.5;
    minx = min([bpA(1,:) bpB(1,:)]);
    miny = min([bpA(2,:) bpB(2,:)]);
    maxx = max([bpA(1,:) bpB(1,:)]);
    maxy = max([bpA(2,:) bpB(2,:)]);
    xlim([minx-pad maxx+pad]);
    ylim([miny-pad maxy+pad]);

%     xlabel({'Mean-centered activity,', 'dim. 1 (spikes/s)'});
%     ylabel({'Mean-centered activity,', 'dim. 2 (spikes/s)'});
    xlabel({'Activity, dim. 1', '(spikes/s, rel. to mean)'});
    ylabel({'Activity, dim. 2', '(spikes/s, rel. to mean)'});
    set(gca, 'XTick', [-1.5 0 1.5]);
    set(gca, 'YTick', [-1.5 0 1.5]);
    set(gca, 'TickDir', 'out');
    set(gca, 'LineWidth', max(opts.LineWidth-1,1));
    box off;
    axis equal;

    xl = xlim; yl = ylim;
    text(xl(1)+0.1, 0.9*yl(2), opts.TextNoteA, 'Color', opts.clrs(1,:), ...
        'FontSize', opts.TextNoteFontSize);
    text(xl(1)+0.1, 0.9*yl(2) - 0.3, opts.TextNoteB, 'Color', opts.clrs(2,:), ...
        'FontSize', opts.TextNoteFontSize);

    plot.setPrintSize(fig, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
