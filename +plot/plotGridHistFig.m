function plotGridHistFig(H1, H2, xs, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('clr1', [0 0 0], 'clr2', [0.5 0.5 0.5], ...
        'width', 4, 'height', 6, 'margin', 0.125, ...
        'FontSize', 12, 'title', '', ...
        'xMult', 7, 'yMult', 0.6, ...
        'histError', nan, ...
        'LineWidth', 2, 'LineStyle', 'k-', 'ymax', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    xgap = 1.2*range(xs);
    ygap = 1.2*opts.ymax;

    % plot hists in grid with specified gaps
    plot.init;
    [nrows,~,ncols] = size(H1);
    for ii = 1:nrows        
        for jj = 1:ncols
            if ii == nrows
                colTitle = {'Output-null', ['     dim. ' num2str(jj)]};
                x = min(xs) + (jj-1)*xgap;
                y = ygap + (ii-1)*ygap;
                text(x, y, colTitle, 'FontSize', opts.FontSize, ...
                    'Color', [0.5 0.5 0.5]);
            end
            hs1 = squeeze(H1(ii,:,jj)) + (ii-1)*ygap;
            hs2 = squeeze(H2(ii,:,jj)) + (ii-1)*ygap;
            xsc = xs + (jj-1)*xgap;
            plotSingleHist(xsc, hs1, opts.LineWidth, opts.clr1, ...
                opts.LineStyle);
            plotSingleHist(xsc, hs2, opts.LineWidth, opts.clr2, ...
                opts.LineStyle);
        end
    end

    % plot scale bars
    xscale = opts.xMult*mode(diff(xs));
    yscale = opts.yMult*opts.ymax;
    x1 = min(xs) - 0.5*xscale;
    y1 = -0.3*yscale;
    x = min(xs); y = 0;
    xtxtoffset = 0.4*xscale;
    ytxtoffset = 0.4*yscale;
    % xlabel
    plot([x x+xscale], [y1 y1] + (ii-1)*ygap, 'k-', ...
        'LineWidth', opts.LineWidth-1);
    text(x, y1 - ytxtoffset + (ii-1)*ygap, ...
        [num2str(xscale, '%0.0f') ' spikes/timestep'], ...
        'FontSize', opts.FontSize);
    % ylabel
    plot([x1 x1], [y y+yscale] + (ii-1)*ygap, 'k-', ...
        'LineWidth', opts.LineWidth-1);
    text(x1 - xtxtoffset, y  + (ii-1)*ygap, ...
        'Freq.', 'Rotation', 90, ...
        'FontSize', opts.FontSize);

    
    % plot hist error
    if ~isempty(opts.histError)
        msg = ['Avg. histogram error: ' ...
            num2str(opts.histError, '%0.0f') '%'];
        xt = min(xs) + 0.7*xgap;
        yt = -0.4*yscale;
        text(xt, yt, msg, 'Color', opts.clr2, ...
            'FontSize', opts.FontSize);
    end

    axis off;
    box off;
    plot.setPrintSize(gcf, opts);
end

function h = plotSingleHist(xs, ys, lw, clr, lnsty)
    h = plot(xs, ys, lnsty, 'Color', clr, 'LineWidth', lw);
end
