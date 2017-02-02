function plotHist(H0, Hs, Xs, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('width', 3, 'height', 3, 'margin', 0.125, ...
        'HideText', false, ...
        'FontSize', 16, 'FontSizeTitle', 20, 'FontName', 'Helvetica', ...
        'TinyFontSize', 12, 'TextNoteFontSize', 16, ...
        'doSave', false, 'saveDir', 'data/plots', 'filename', 'hist', ...
        'ext', 'pdf', 'title', '', 'clrs', [], ...
        'xlbl', 'Activity (spikes/timebin)', 'ylbl', 'Selection frequency', ...
        'ymax', 1.0, 'LineWidth', 3, 'TextNote', '', 'grpNms', [], ...
        'LabelFontSize', 16, 'backClr', [0.8 0.8 0.8], ...
        'grpInds', [], 'dimInds', [], 'panelMargins', [2.0 0.2]);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    fig = plot.init(opts.FontSize, opts.FontName);
    
    xsa = Xs{1}(:,1);
    xmn = min(xsa);
    xmx = max(xsa);
    xgap = (xmx-xmn) + opts.panelMargins(1);
    ygap = opts.ymax + opts.panelMargins(2);
    xmnd = inf; xmxd = -inf; ymnd = 0; ymxd = -inf;
    notSinglePanel = numel(opts.grpInds) ~= 1 || numel(opts.dimInds) ~= 1;

    % show each dim and dir combo
    for ii = 1:numel(opts.grpInds)
        for jj = 1:numel(opts.dimInds)
            grpInd = opts.grpInds(numel(opts.grpInds)-ii+1);
            dimInd = opts.dimInds(jj);
            xs = Xs{grpInd}(:,dimInd);
            xs = xs + (jj-1)*xgap;
            ys0 = H0{grpInd}(:,dimInd) + (ii-1)*ygap;            

            plotSingleHist(xs, ys0, ...
                opts.LineWidth, opts.clrs(1,:), '-');
            for kk = 1:numel(Hs)
                H1 = Hs{kk};
                ys1 = H1{grpInd}(:,dimInd) + (ii-1)*ygap;
                plotSingleHist(xs, ys1, ...
                    opts.LineWidth, opts.clrs(kk+1,:), '-');
            end
            xmnd = min(min(xs), xmnd);
            xmxd = max(max(xs), xmxd);
%             ymnd = min((ii-1)*ygap, ymnd);
            ymxd = max((ii-1)*ygap + opts.ymax, ymxd);
%             if numel(opts.grpInds) ~= 1 || numel(opts.dimInds) ~= 1
%                 plot([min(xs) max(xs)], [(ii-1)*ygap, (ii-1)*ygap], 'k-');
%                 plot([min(xs) min(xs)], [(ii-1)*ygap, (ii-1)*ygap + opts.ymax], 'k-');
%             end
            if ii == numel(opts.grpInds) && notSinglePanel
                text(min(xs), (ii-1)*ygap + 1.2*opts.ymax, ...
                    [' Output-null\newline      dim. ' num2str(dimInd)], ...
                    'FontSize', opts.TinyFontSize);
            end
            if ii == numel(opts.grpInds) && jj == 1 && notSinglePanel
                hght = max([0.6*ygap max(ys1)-min(ys1)]);
%                 [0.6*ygap max(ys1)-min(ys1)]
                rpos = [min(xs) min(ys1) max(xs)-min(xs) hght];
                % 0.712 instead of 0.6 if SinglePanel
                rectangle('Position', rpos, 'EdgeColor', opts.backClr, ...
                    'LineWidth', opts.LineWidth);
%                     'FaceColor', opts.backClr);
            end
%             if jj == 1 && ~isempty(opts.grpNms) && notSinglePanel
%                 text(min(xs)-3, (ii-1)*ygap + opts.ymax/3, ...
%                     [num2str(opts.grpNms(grpInd)) '^\circ'], ...
%                     'FontSize', opts.TinyFontSize, 'Rotation', 90);
%             end
        end
    end
    if true%numel(opts.grpInds) == 1 && numel(opts.dimInds) == 1
        xlim([xmnd-0.05 xmxd+0.05]);
        ylim([ymnd ymxd]);
    end
    
    % format plot    
    if ~isempty(opts.title)
        title(opts.title, 'FontSize', opts.FontSizeTitle);
    end
    set(gca, 'TickDir', 'out');
%     set(gca, 'TickLength', [0 0]);
    set(gca, 'LineWidth', max(opts.LineWidth-1,1));
    box off;
    if numel(opts.grpInds) ~= 1 || numel(opts.dimInds) ~= 1
        axis off;        
    else
        xlabel(opts.xlbl, 'FontSize', opts.LabelFontSize);
        ylabel(opts.ylbl, 'FontSize', opts.LabelFontSize);
%         set(gca, 'Color', opts.backClr); % gray background
        
%         xmu = (xmn+xmx)/2; % xmn is zero, so subtract from that
%         set(gca, 'XTick', [xmu]);
%         set(gca, 'XTickLabel', {num2str(round(xmu - xmn))});
        set(gca, 'XTick', []);
        set(gca, 'XTickLabel', {});
        set(gca, 'YTick', []);
    end
    plot.setPrintSize(gcf, opts);
    
    if ~isempty(opts.TextNote)
        xl = xlim; yl = ylim;
        text(xl(1), 0.94*yl(2), ...
            opts.TextNote, 'FontSize', opts.TextNoteFontSize, ...
            'Color', [0.3 0.3 0.3]);
    end
    
    % label lines
    if ~notSinglePanel && ~opts.HideText
        xl = xlim; yl = ylim;
        
%         [~,ix] = max(ys0);
%         xsc = xs(ix)-0.5;
%         ysc = ys0(ix);
        xsc = mean(xl) - 0.1*diff(xl);
        ysc = mean(yl);
        text(xsc, ysc, 'Data', 'Color', opts.clrs(1,:), ...
            'FontSize', opts.FontSize);
%         [~,ix] = max(ys1);
%         xsc = xs(ix)-0.5;
%         ysc = ys1(ix);
        xsc = mean(xl) - 0.1*diff(xl);
        ysc = mean(yl) + 0.1*diff(yl);
        text(xsc, ysc, 'Prediction', 'Color', opts.clrs(2,:), ...
            'FontSize', opts.FontSize);
    end    
    
    if opts.HideText
        set(findall(gca, 'Type', 'text'), 'Color', [0.99 0.99 0.99]);
    end
    
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
    
end

function h = plotSingleHist(xs, ys, lw, clr, lnsty)
    h = plot(xs, ys, lnsty, 'Color', clr, 'LineWidth', lw);
end
