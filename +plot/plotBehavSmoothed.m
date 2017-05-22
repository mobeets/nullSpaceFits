function pts = plotBehavSmoothed(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 6, 'height', 6, 'margin', 0.125, ...
        'LineWidth', 3, 'FontSize', 26, 'showWashout', false, ...
        'behavNm', 'isCorrect', 'binSz', 150, 'doPlot', true, ...
        'saveDir', 'data/plots/behav', 'doSave', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    if opts.doPlot
        plot.init(opts.FontSize);
    end
    if opts.showWashout
        maxbind = 3;
    else
        maxbind = 2;
    end
    
    pts = cell(maxbind,2);
    for ii = 1:maxbind
        B = D.blocks(ii);
        xs = B.trial_index;
        ys = B.(opts.behavNm);
        if strcmpi(opts.behavNm, 'isCorrect')
            ymn = 50;
            ys = 100*ys;
        else
            ymn = 0;
        end

        % avg by trial and smooth
        xsb = unique(xs);
        ysb = grpstats(ys, xs);
        ysb = smooth(xsb, ysb, opts.binSz);

        if strcmp(opts.behavNm, 'trial_length')
            ysb = (ysb*45)/1000; % convert to seconds
        end
        pts{ii,1} = xsb;
        pts{ii,2} = ysb;
        if ~opts.doPlot
            continue;
        end
        
        inds = 2:(numel(ysb)-1); % keep it from looking jumpy
        if ii == 3
            inds = 1:numel(ysb);
            inds = inds >= 0.3*range(inds);
        end
        plot(xsb(inds), ysb(inds), '-', 'LineWidth', opts.LineWidth, ...
            'Color', 'k');        

        % show dotted line when mapping changes
        if ii >= 2
            xmn = min(xsb);
            yl = ylim;
            yl(1) = ymn;
            yl(2) = 1.05*yl(2);
            plot([xmn xmn], yl, 'k--', 'LineWidth', 2);
        end
    end
    if ~opts.doPlot
        return;
    end

    xlabel('Trial #');
    if strcmp(opts.behavNm, 'trial_length')
        ylabel('Target acquisition time (sec)');
        ylim([ymn yl(2)]);
    elseif strcmp(opts.behavNm, 'isCorrect')
        ylabel('Percent correct');
        yl = ylim;
        ylim([ymn 100]);
        set(gca, 'YTick', ymn:10:100);
    end
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);

    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            ['lrnByTrial_' opts.behavNm '_' D.datestr '.pdf']));
    end
end
