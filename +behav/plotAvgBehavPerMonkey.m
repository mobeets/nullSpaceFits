function fig = plotAvgBehavPerMonkey(fnm, showLegend)
    if nargin < 2
        showLegend = false;
    end

    d = load(fnm);
    opts = d.opts;
    objsInt = d.objs{1};
    objs = d.objs{2};
    
    ys = cell(3,3);
    for ii = 1:numel(objs)
        obj = objs(ii);    

        if ~obj.isGood
            continue;
        end
        dtyr = obj.datestr(1:4);
        if strcmpi(dtyr, '2012')
            c = 1;
        elseif strcmpi(dtyr, '2013')
            c = 2;
        else
            c = 3;
        end
        yc = nanmean(obj.ysb(1:50));
        ys{c,2} = [ys{c,2} yc];

        yc = nanmean(obj.ysb(obj.ix));
%         yc = min(obj.ysb(obj.ix));
        ys{c,3} = [ys{c,3} yc];

        obj = objsInt(ismember({objsInt.datestr}, obj.datestr));
        yc = nanmean(obj.ysb);
        ys{c,1} = [ys{c,1} yc];
    end
    scale = 45/1000;
    if strcmpi(opts.behavNm, 'isCorrect')
        scale = -100;
    end
    mus = cellfun(@nanmean, ys);
    ses = cellfun(@(y) nanstd(y)/sqrt(numel(y)), ys);
    
    fig = plot.init;
    h = bar(scale*mus, 'FaceColor', 'none', ...
        'BarWidth', 0.8, 'EdgeColor', 'none', 'LineWidth', 2);
    for ii = 1:size(ys,2)
        for jj = 1:size(ys,1)
            xc = jj + 0.23*(ii-2);
            cmu = mus(jj,ii);
            cse = ses(jj,ii);
            plot([xc xc], scale*[cmu-cse cmu+cse], '-', ...
                'Color', 0.2*ones(3,1), 'LineWidth', 2);
        end
    end
    
    h(1).FaceColor = 'k';
    h(2).FaceColor = 0.6*ones(3,1);
    h(3).FaceColor = [0.8 0.2 0.2];
    if showLegend
        l = legend({'Intuitive', 'WMP: First 50 trials', ...
            'WMP: Selected trials'}, ...
            'Location', 'BestOutside');
        legend boxoff;
    end
    set(gca, 'FontSize', 18);
    set(gca, 'XTick', 1:3);
    set(gca, 'XTickLabel', {'Monkey J', 'Monkey L', 'Monkey N'});
    set(gca, 'XTickLabelRotation', 45);
    set(gca, 'TickLength', [0 0]);    
    set(gca, 'LineWidth', 2);
    xlim([0.5 3.5]);
    
    if strcmpi(opts.behavNm, 'isCorrect')
        ylabel({'Success rate (%)', 'all sessions'});
        set(gca, 'YTick', [50 75 100]);
        ylim([50 100]);
    else
        ylabel({'Acquisition time (s)', 'all sessions'});
        set(gca, 'YTick', 0:3);
        ylim([0 3.01]);
    end

    plot.setPrintSize(gcf, struct('width', 3, 'height', 2.3));
    
end
