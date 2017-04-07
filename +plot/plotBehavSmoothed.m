function plotBehavSmoothed(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 4, 'height', 6, 'margin', 0.125, ...
        'LineWidth', 3, 'FontSize', 22, ...
        'behavNm', 'isCorrect', 'binSz', 50, ...
        'saveDir', 'data/plots', 'doSave', false);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    plot.init(opts.FontSize);
    for ii = 1:2
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

        inds = 2:(numel(ysb)-1); % keep it from looking jumpy    
        plot(xsb(inds), ysb(inds), '-', 'LineWidth', opts.LineWidth, ...
            'Color', 'k');

        if ii == 2
            xmn = min(xsb);
            yl = ylim;
            yl(1) = ymn;
            yl(2) = 1.05*yl(2);
            plot([xmn xmn], yl, 'k--', 'LineWidth', 2);
        end
    end

    xlabel('Trial #');
    if strcmp(opts.behavNm, 'trial_length')
        ylabel('Target acquisition time (sec)');
        ylim([ymn yl(2)]);
    elseif strcmp(opts.behavNm, 'isCorrect')
        ylabel('Percent correct');
        yl = ylim;
        ylim([ymn 100]);
    end
    set(gca, 'Ticklength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);

    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            ['lrnByTrial_' opts.behavNm '_' dtstr '.pdf']));
    end
end
