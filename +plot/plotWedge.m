function plotWedge(wedgeToHighlight, opts)
    if nargin < 2
        opts = struct();
    end
%     assert(wedgeToHighlight <= nwedges, 'Invalid args.');
%     assert(wedgeToHighlight > 0, 'Invalid args.');
    defopts = struct('width', 3, 'height', 3, 'margin', 0.5, ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'wedge_', 'ext', 'pdf', ...
        'LineWidth', 2, 'MarkerSize', 70, 'nwedges', 8, ...
        'wedgeClr', [0.2 0.8 0.2], 'circClr', [0 0 0], ...
        'arrowClr', [0.2 0.5 0.2]);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init;

    th = nan;
    for ii = 1:opts.nwedges
        c1 = (ii-1)*pi/(opts.nwedges/2);
        c2 = ii*pi/(opts.nwedges/2);
        c1 = c1 - pi/opts.nwedges; % so 0 is within a wedge, e.g.
        c2 = c2 - pi/opts.nwedges;
        h = plot_arc(c1, c2, 0, 0, 1);
        if ii == wedgeToHighlight
            set(h, 'FaceColor', opts.wedgeClr);
            th = mean([c1 c2]);
        end
        set(h, 'EdgeColor', [0.5 0.5 0.5]);
        set(h, 'LineWidth', opts.LineWidth);
    end
    
    if false%~isnan(th)
        % 'arrow' from Matlab FileExchange
        arrow([0 0], 0.99*[cos(th) sin(th)], 10, ...
            'LineWidth', 2*opts.LineWidth, ...
            'EdgeColor', opts.arrowClr, 'BaseAngle', 20);
    end
    
    plot(0, 0, '.', 'Color', opts.circClr, 'MarkerSize', opts.MarkerSize);
    box off; axis off;
    plot.setPrintSize(fig, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename num2str(wedgeToHighlight) '.' opts.ext]));
    end
end

function P = plot_arc(a, b, h, k, r)
% Plot a circular arc as a pie wedge.
% a is start of arc in radians, 
% b is end of arc in radians, 
% (h,k) is the center of the circle.
% r is the radius.
% Try this:   plot_arc(pi/4,3*pi/4,9,-4,3)
% Author:  Matt Fig

    t = linspace(a,b);
    x = r*cos(t) + h;
    y = r*sin(t) + k;
    x = [x h x(1)];
    y = [y k y(1)];
    P = fill(x, y, 'w');
    axis([h-r-1 h+r+1 k-r-1 k+r+1]) 
    axis square;

end
