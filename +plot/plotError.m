function plotError(errs, nms, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 6, 'height', 6, 'margin', 0.125, ...
        'FontSize', 24, 'FontSizeTitle', 28, 'FontName', 'Helvetica', ...
        'doSave', false, 'saveDir', 'data/plots', 'filename', 'avgErr', ...
        'ext', 'pdf', 'title', '', 'clrs', [], 'doBox', true, ...
        'ylbl', 'Avg. error', 'starBaseName', '', ...
        'showZeroBoundary', false, 'nSEs', 1, ...
        'LineWidth', 2, 'ymin', 0, 'ymax', nan, 'TextNote', '');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    if numel(errs) == numel(nms)
        error('Must provide multiple errors per hyp.');
    end
    
    % show plot
    plot.init(opts.FontSize, opts.FontName);
    if opts.doBox
        makeBoxPlot(errs, opts.clrs, opts.LineWidth);
    else
        makeBarPlot(errs, opts.clrs, opts.LineWidth, opts.nSEs);
    end
    
    % format x-axis
    if ~isempty(nms)
        set(gca, 'XTick', 1:numel(nms));
        set(gca, 'XTickLabel', nms);    
        xlim([0.25 numel(nms)+0.75]);
        if max(cellfun(@numel, nms)) > 1 % if longest name > 3 chars
            set(gca, 'XTickLabelRotation', 45);
        end
    end
        
    % format y-axis
    yl = ylim;
    if ~isnan(opts.ymax)
        ymx = opts.ymax;
    else
        ymx = yl(2);
    end
    if ~isnan(opts.ymin)
        ymn = opts.ymin;
    else
        ymn = yl(1);
    end
    ylim([ymn ymx]);
    h = ylabel(opts.ylbl);
    set(h, 'interpreter', 'tex'); % funky bug somehow caused by boxplot

    if ~isempty(opts.starBaseName)
        bInd = find(ismember(nms, opts.starBaseName));
        plot.addSignificanceStars(errs, bInd);
        ylim(yl);
    end    
    
    if opts.showZeroBoundary
        plot(xlim, [0 0], 'k-', 'LineWidth', opts.LineWidth);
    end
    
    % format plot
    if ~isempty(opts.title)
        title(opts.title, 'FontSize', opts.FontSizeTitle);
    end
    set(gca, 'TickDir', 'out');
    set(gca, 'TickLength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);
    box off;
    plot.setPrintSize(gcf, opts);
    ylim([ymn ymx]);
    
    if ~isempty(opts.TextNote)
        xl = xlim; yl = ylim;
        text(0.65*xl(2), 0.95*yl(2), ...
            opts.TextNote, 'FontSize', opts.FontSize);
    end
        
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
end

function makeBoxPlot(pts, clrs, lw)
    bp = boxplot(pts, 'Colors', clrs, ...
        'Symbol', '.', 'OutlierSize', 8, 'widths', 0.7);
%     return;
    h = findobj(gcf,'tag','Upper Adjacent Value');
    for jj = 1:numel(h)
        h(jj).Color = 'w';
    end
    h = findobj(gcf,'tag','Lower Adjacent Value');
    for jj = 1:numel(h)
        h(jj).Color = 'w';
    end
    
    h = findobj(gcf,'tag','Box');
%     for jj = 1:numel(h)
%         patch(get(h(jj),'XData'), get(h(jj),'YData'), get(h(jj), 'Color'), ...
%             'FaceAlpha', 1.0, 'EdgeColor', 'none');
%     end
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
    set(bp, 'LineWidth', lw);
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
end

function makeBarPlot(pts, clrs, lw, nSEs)
    ms = mean(pts);
    bs = nSEs*std(pts)/sqrt(size(pts,1));
    for ii = 1:size(pts,2)        
%         bar(ii, ms(ii), 'EdgeColor', 'k', 'FaceColor', clrs(ii,:), ...
%             'LineWidth', lw);
        bar(ii, ms(ii), 'EdgeColor', clrs(ii,:), 'FaceColor', 'w', ...
            'LineWidth', lw);
%         plot([ii-0.5 ii+0.5], [ms(ii) ms(ii)], '-', ...
%             'Color', clrs(ii,:), 'LineWidth', 2*lw);
%         plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
%             'Color', 'k', 'LineWidth', lw);
        plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
            'Color', clrs(ii,:), 'LineWidth', lw);
    end
end
