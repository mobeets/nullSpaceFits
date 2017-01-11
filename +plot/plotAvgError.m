function plotAvgError(errs, nms, opts)    
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 6, 'height', 6, 'margin', 0.125, ...
        'FontSize', 24, 'FontSizeTitle', 32, 'FontName', 'helvetica', ...
        'doSave', false, 'saveDir', 'data/plots', 'filename', 'avgErr', ...
        'ext', 'pdf', 'title', '', 'clrs', [], ...
        'ylbl', 'Avg. error', 'showStars', true, ...
        'starBaseName', 'Constant-cloud', ...
        'LineWidth', 2, 'ymax', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % show plot
    plot.init(opts.FontSize, opts.FontName);
    makeBoxPlot(errs, opts.clrs, opts.LineWidth);
%     makeBarPlot(errs, opts.clrs, opts.LineWidth);
    
    % format x-axis
    if ~isempty(nms)
        set(gca, 'XTick', 1:numel(nms));
        set(gca, 'XTickLabel', nms);    
        xlim([0.25 numel(nms)+0.75]);
        if max(cellfun(@numel, nms)) > 3 % if longest name > 3 chars
            set(gca, 'XTickLabelRotation', 45);
        end
    end
        
    % format y-axis
    if ~isnan(opts.ymax)
        yl = [0 opts.ymax];
        ylim(yl);
%         set(gca, 'YTick', 0:opts.ymax);
    else
        yl = ylim;
        yl = [0 yl(2)];
        ylim(yl);
    end
    ylabel(opts.ylbl);
    
    if opts.showStars
        bInd = find(ismember(nms, opts.starBaseName));
        plot.addSignificanceStars(errs, bInd);
        ylim(yl);
    end    
    
    % format plot
    title(opts.title, 'FontSize', opts.FontSizeTitle);
    set(gca, 'TickDir', 'out');
    set(gca, 'TickLength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);
    box off;
    plot.setPrintSize(gcf, opts);    
        
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
end

function makeBoxPlot(pts, clrs, lw)
    bp = boxplot(pts, 'Colors', clrs, ...
        'Symbol', '.', 'OutlierSize', 12);
    set(bp, 'LineWidth', lw);
    set(findobj(gcf, 'LineStyle', '--'), 'LineStyle', '-');
end

function makeBarPlot(pts, clrs, lw)
    ms = mean(pts);
    bs = 2*std(pts)/sqrt(size(pts,1));
    for ii = 1:size(pts,2)
        plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
            'Color', 'k', 'LineWidth', lw);
        plot([ii-0.5 ii+0.5], [ms(ii) ms(ii)], '-', ...
            'Color', clrs(ii,:), 'LineWidth', 2*lw);
    end
end
