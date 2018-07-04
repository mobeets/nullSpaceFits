function fig = plotSingleSession(dtstr, fnm, fnm0, yl)
% plot behavior for single session
% if fnm0 is provided, it uses this to mark the included (red) trials
    if nargin < 3
        fnm0 = fnm;
    end
    if nargin < 4
        yl = nan;
    end
    
    d = load(fnm0);
    objs = d.objs{2};
    ixWMP = ismember({objs.datestr}, dtstr);
    B0 = objs(ixWMP);
    
    d = load(fnm);
    objsInt = d.objs{1};
    objs = d.objs{2};
    opts = d.opts;
    ixInt = ismember({objsInt.datestr}, dtstr);
    ixWMP = ismember({objs.datestr}, dtstr);
    A = objsInt(ixInt);
    B = objs(ixWMP);
    
    if strcmpi(opts.behavNm, 'isCorrect')
        scale = -100;
        if any(isnan(yl)) || isempty(yl)
            yl = [0 100];
        end
    else
        scale = 45/1000;
        if any(isnan(yl)) || isempty(yl)
            yl = [0 5];
        end
    end
    
    lw = 2;
    fig = plot.init;
    
    X = A;
    clr = 0.0*ones(3,1);
    xs = X.xsb(1:end-5);
    ys = X.ysSmoothMean(1:end-5);    
    plot(xs, scale*ys, 'Color', clr, 'LineWidth', lw);
    plot([max(X.xsb) max(X.xsb)], yl, '--', 'Color', 0.7*ones(3,1), ...
        'LineWidth', 1);
    
    X = B;
    clr = 0.9*ones(3,1);
    xs = X.xsb;
    ys = X.ysSmoothMean;    
    plot(xs, scale*ys, 'Color', clr, 'LineWidth', lw);
    
    X = B;
    clr = 0.6*ones(3,1);
    xs = X.xsb(1:50);
    ys = X.ysSmoothMean(1:50);
    plot(xs, scale*ys, 'Color', clr, 'LineWidth', lw);
    
    X = B; X0 = B0;
    clr = [0.8 0.2 0.2];
    xs = X.xsb(X0.ix);
    ys = X.ysSmoothMean(X0.ix);    
    plot(xs, scale*ys, 'Color', clr, 'LineWidth', lw);
    
    set(gca, 'LineWidth', 2);
    set(gca, 'FontSize', 18);
    ylim(yl);
    
    xlabel('Trial number');
    if strcmpi(opts.behavNm, 'isCorrect')
        ylabel('Success rate (%)');
    else
        scale = 45/1000;
        ylabel('Acquisition time (s)');
        set(gca, 'YTick', 0:round(yl(2)));
        ylim([0 yl(2)]);
    end
    set(gca, 'TickLength', [0 0]);
    
    plot.setPrintSize(gcf, struct('width', 5.5, 'height', 2.3));

end
