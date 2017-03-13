function plotCursorTrace(dtstr, bind, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('LineWidth', 1, 'targetSize', 100, ...
        'maxTracesPerTarget', 40, 'marginAroundTargs', 0.2, ...
        'targetColor', [0.2 0.2 0.8], 'traceColor', [0.5 0.5 0.5]);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    D = pred.loadSession(dtstr);
    B = D.blocks(bind);
    cur_ts = unique(B.trial_index);
    grps = sort(unique(D.simpleData.targetAngles));

    plot.init;

    % plot traces
    isOk = D.simpleData.trialStatus;
    trgCur = D.simpleData.targetAngles;
    ts = 1:numel(trgCur);
    isGoodTs = ismember(ts, cur_ts)';
    for jj = 1:numel(grps)
        ix = trgCur == grps(jj) & isOk & isGoodTs;
        X = D.simpleData.decodedPositions(ix);
        for kk = 1:min(opts.maxTracesPerTarget, numel(X))
            x = X{kk};
            plot(x(:,1), x(:,2), '-', 'LineWidth', opts.LineWidth, ...
                'Color', opts.traceColor);
        end    
    end
    
    % plot targets
    trgPos = unique(D.simpleData.targetLocations, 'rows');
    for jj = 1:size(trgPos,1)
        plot(trgPos(jj,1), trgPos(jj,2), '.', ...
            'MarkerSize', opts.targetSize, 'Color', opts.targetColor);
    end
    
    % adjust range shown around targets
    mrg = opts.marginAroundTargs;
    xmn = min(trgPos(:,1)); xmx = max(trgPos(:,1)); xmrg = mrg*(xmx-xmn);
    ymn = min(trgPos(:,2)); ymx = max(trgPos(:,2)); ymrg = mrg*(ymx-ymn);
    xlim([xmn-xmrg xmx+xmrg]); ylim([ymn-ymrg ymx+ymrg]);

    axis off;
    axis equal;
end
