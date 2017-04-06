function plotSingleHistFig(hs1, hs2, xs, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('clr1', [0 0 0], 'clr2', [0.5 0.5 0.5], ...
        'width', 3, 'height', 3, 'margin', 0.125, ...
        'FontSize', 16, 'title', '', ...
        'xMult', 7, 'yMult', 0.6, ...
        'LineWidth', 3, 'LineStyle', 'k-', 'ymax', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % plot hists
    plot.init;
    plotSingleHist(xs, hs1, ...
        opts.LineWidth, opts.clr1, opts.LineStyle);
    plotSingleHist(xs, hs2, ...
        opts.LineWidth, opts.clr2, opts.LineStyle);

    % manage axes, set scale
    if ~isnan(opts.ymax)
        yl = ylim;
        ylim([yl(1) opts.ymax]);
    end
    xscale = opts.xMult*mode(diff(xs));
    yscale = opts.yMult*opts.ymax;
    xmrg = xscale/5;
    minx = min(xs) - xmrg;
    maxx = max(xs);
    xlim([minx maxx]);
    ymrg = yscale/5;
    yl = ylim; ylim([yl(1)-ymrg yl(2)]);

    % plot scale bars
    x = xlim; x1 = x(1);
    y = ylim; y1 = y(1);
    x = min(xs); y = 0;
    xtxtoffset = 0.2*xscale;
    ytxtoffset = 0.2*yscale;
    % xlabel
    plot([x x+xscale], [y1 y1], 'k-', 'LineWidth', opts.LineWidth-1);
    text(x, y1 - ytxtoffset, ...
        [num2str(xscale, '%0.0f') ' spikes/timestep'], ...
        'FontSize', opts.FontSize);
    % ylabel
    plot([x1 x1], [y y+yscale], 'k-', 'LineWidth', opts.LineWidth-1);
    text(x1 - xtxtoffset, y, ...
        'Frequency', 'Rotation', 90, ...
        'FontSize', opts.FontSize);

    % plot title
    if ~isempty(opts.title)
        xt = min(xs) + 0.2*range(xs);
        yl = ylim;
        yt = yl(2) - 2*ytxtoffset;
        text(xt, yt, opts.title, 'FontSize', opts.FontSize, ...
            'Color', [0.5 0.5 0.5]);
    end

    axis off;
    box off;
    plot.setPrintSize(gcf, opts);

end

function h = plotSingleHist(xs, ys, lw, clr, lnsty)
    h = plot(xs, ys, lnsty, 'Color', clr, 'LineWidth', lw);
end
