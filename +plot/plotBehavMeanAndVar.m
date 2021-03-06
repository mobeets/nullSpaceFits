function plotBehavMeanAndVar(D, opts, popts)
    if nargin < 2
        opts = struct();
    end
    if nargin < 3
        popts = struct();
    end
    defpopts = struct('width', 6, 'height', 4, 'margin', 0.125, ...
        'FontSize', 26, 'LineWidth', 3, 'saveDir', 'data/plots/behav', ...
        'doSave', false);
    popts = tools.setDefaultOptsWhenNecessary(popts, defpopts);
    
    [~, ixs, xsb, ysb, ysv, opts, ysv2] = io.assessBehavior(D, opts);
    if isempty(ysb)
        return;
    end
    ix = ixs{1};

    behNm = opts.behavNm;
    if strcmp(opts.behavNm, 'trial_length')
        behNm = 'acquisition time (normalized)';
        behNm = 'Acq. time, normalized';
    elseif strcmp(opts.behavNm, 'angErrorAbs')
        behNm = 'Abs. angular cursor error';
    end

    plot.init(popts.FontSize);
    plot(xsb, ysb, 'k-', 'LineWidth', popts.LineWidth);
    plot([min(xsb) max(xsb)], [opts.muThresh opts.muThresh], 'k--', ...
        'LineWidth', popts.LineWidth);
    %     plot(xsb(ixs{1}), ysb(ixs{1}), 'r-', 'LineWidth', lw);
    yl = [0 1.01];
    plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
        'r-', 'LineWidth', popts.LineWidth);
    xlabel('trial #');
    ylabel(behNm);
    ylim(yl);
    % xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', popts.LineWidth);

    plot.setPrintSize(gcf, popts);
    if popts.doSave
        export_fig(gcf, fullfile(popts.saveDir, ...
            ['lrnCritMean_' D.datestr '.pdf']));
    end

    plot.init(popts.FontSize);
    plot(xsb, ysv, 'k-', 'LineWidth', popts.LineWidth);
    plot([min(xsb) max(xsb)], [opts.varThresh opts.varThresh], 'k--', ...
        'LineWidth', popts.LineWidth);
    plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
        'r-', 'LineWidth', popts.LineWidth);
    xlabel('trial #');
    ylabel(['Var. of ' behNm]);
    ylim(yl);
    % xlim([min(xs) max(xs)]);
    set(gca, 'YTick', [0 0.5 1.0]);
    set(gca, 'LineWidth', popts.LineWidth);

    plot.setPrintSize(gcf, popts);
    if popts.doSave
        export_fig(gcf, fullfile(popts.saveDir, ...
            ['lrnCritVar_' D.datestr '.pdf']));
    end
end
