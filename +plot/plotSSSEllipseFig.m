function plotSSSEllipseFig(CA, CB, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('width', 8, 'height', 6, 'margin', 0.125, ...
        'FontSize', 24, 'FontName', 'Helvetica', ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'SSS_ellipses', 'ext', 'pdf', ...
        'clrs', [], 'sigMult', 2, 'dstep', 5.5);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init(opts.FontSize, opts.FontName);
    
    [nexps, ngrps] = size(CA);
    minx = inf; miny = inf;
    for ii = 1:nexps
        for jj = 1:ngrps
    %         [bpA, ~, ~] = plot.gauss2dcirc([], sigMult, C1s{ii,jj});
            [bpA, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CA{ii,jj});
            [bpB, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CB{ii,jj});
            bpA(1,:) = bpA(1,:) + (ii-1)*opts.dstep;
            bpB(1,:) = bpB(1,:) + (ii-1)*opts.dstep;
            bpA(2,:) = bpA(2,:) - (jj-1)*opts.dstep;
            bpB(2,:) = bpB(2,:) - (jj-1)*opts.dstep;
            minx = min([bpA(1,:) bpB(1,:) minx]);
            miny = min([bpA(2,:) bpB(2,:) miny]);

            plot(bpA(1,:), bpA(2,:), '-', 'Color', opts.clrs(1,:));
            plot(bpB(1,:), bpB(2,:), '-', 'Color', opts.clrs(2,:));
        end
    end

    xt = minx-5; yt = miny-2; pad = 2;
    text(xt, yt+pad, 'Cursor directions \rightarrow', 'Rotation', 90, ...
        'FontSize', opts.FontSize);
    text(xt+pad, yt, 'Sessions \rightarrow', ...
        'FontSize', opts.FontSize);

    box off; axis off;
    plot.setPrintSize(fig, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
end
