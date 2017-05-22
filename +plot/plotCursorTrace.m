function plotCursorTrace(dtstr, bind, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('LineWidth', 1, 'targetSize', 100, ...
        'showIncorrects', false, 'startAtEnd', false, ...
        'maxTracesPerTarget', 40, 'marginAroundTargs', 0.2, ...
        'targetColor', [0.2 0.2 0.8], 'traceColors', [0.5 0.5 0.5]);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if isa(dtstr, 'struct')
        D = dtstr;
    else
        D = io.loadPrepDataByDate(dtstr);
%         params = io.setUnfilteredDefaults;
%         params.REMOVE_INCORRECTS = false;
%         D = io.quickLoadByDate(dtstr, params);
    end
    B = D.blocks(bind);
    cur_ts = unique(B.trial_index(B.isCorrect == 1));    
    if opts.showIncorrects
        % note that D must have been loaded to include incorrects
        cur_ts = unique(B.trial_index);
    end
    grps = sort(unique(D.simpleData.targetAngles));

    plot.init;

    % plot traces
    trgCur = D.simpleData.targetAngles;
    ts = 1:numel(trgCur);
    curBlkTs = ismember(ts, cur_ts)';
    for jj = 1:numel(grps)
        ix = trgCur == grps(jj) & curBlkTs;
        X = D.simpleData.decodedPositions(ix);
        if size(opts.traceColors,1) >= numel(grps)
            clr = opts.traceColors(jj,:);
        else
            clr = opts.traceColors;
        end
        if opts.startAtEnd
            inds = numel(X):-1:max(numel(X)-opts.maxTracesPerTarget+1, 1);
        else
            inds = 1:min(opts.maxTracesPerTarget, numel(X));
        end
        for kk = inds
            x = X{kk};
            plot(x(:,1), x(:,2), '.-', 'LineWidth', opts.LineWidth, ...
                'Color', clr);
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
