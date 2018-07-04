function plotAllThreshTrials(fnm, opts)
% plot grid of all behavior
% if byMonkey=true, group by monkey; otherwise, each panel is a session
% 
% fnm = 'data/sessions/goodTrials_trial_length_v2.mat';
% 
    if nargin < 2
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots/trials', ...
        'byMonkey', false, 'kind', 'Mean', 'showNormalized', false, ...
        'skipBads', true, 'xmx', 1500, 'ymx', 5, 'xtick', 1000, ...
        'sameMinX', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    xmx = opts.xmx; ymx = opts.ymx;
    sameMinX = opts.sameMinX;
    lw = 1;
    scale = 45/1000; % 45/1000 for acquisition time
    kind = opts.kind;
    byMonkey = opts.byMonkey;
    showNormalized = opts.showNormalized;
    skipBads = opts.skipBads;
    
    % load data
    d = load(fnm);
    objsInt = d.objs{1};
    objs = d.objs{2};
    fopts = d.opts;
    
    if strcmpi(fopts.behavNm, 'isCorrect')
        scale = -100; % flip axis and scale to be %
    end

    if skipBads
        n = sum([objs.isGood]);
    else
        n = numel(objs);
    end

    if byMonkey
        ncols = 3; nrows = 1;
    else
        ncols = ceil(sqrt(n));
        nrows = ceil(n/ncols);
    end

    c = 1;
    plot.init;
    for ii = 1:numel(objs)
        dtyr = objs(ii).datestr(1:4);
        if byMonkey
            if strcmpi(dtyr, '2012')
                c = 1;
                sameMinX = 450;
            elseif strcmpi(dtyr, '2013')
                c = 2;
                sameMinX = 350;
            else
                c = 3;
                sameMinX = 200;
            end
        end    
        subplot(nrows, ncols, c); hold on;
        if byMonkey
            set(gca, 'FontSize', 14);
            xlabel('Trials');
            ylabel({'Avg. target', 'acquisition time (s)'});
        end

        obj = objs(ii);
        objInt = objsInt(ismember({objsInt.datestr}, obj.datestr));
        if ~obj.isGood && skipBads
            continue;
        end
        if isempty(objInt)
            continue;
        end
        xsb = objInt.xsb;
        xsb = xsb - min(xsb);
        if showNormalized
            ysb = objInt.(['ysSmooth' kind 'Norm']);        
        else
            ysb = scale*objInt.(['ysSmooth' kind]);
        end
        clr = 0.6*ones(3,1);
        plot(xsb(2:end-10), ysb(2:end-10), '-', 'Color', clr, 'LineWidth', lw);
        xIntMax = max(xsb);    

        ix = obj.ix;
        xsb = obj.xsb;
        if ~isnan(sameMinX)
            xsb = xsb - min(xsb) + sameMinX;
        end
        if showNormalized
            ysb = obj.(['ysSmooth' kind 'Norm']);        
        else
            ysb = scale*obj.(['ysSmooth' kind]);
        end
        inds = 2:(numel(ysb)-1);
        xsb = xsb(inds); ysb = ysb(inds); ix = ix(inds);

        if obj.isGood
            clr = 'k';
        else
            clr = 0.8*ones(3,1);
        end

        if showNormalized
            plot([0 xmx], [fopts.muThresh fopts.muThresh], ...
                '-', 'Color', 0.8*ones(3,1), 'LineWidth', lw);
            yl = [0 1.01];
            set(gca, 'YTick', [0 1.0]);
        else
            if ~isnan(ymx)
                yl = [0 ymx];
                set(gca, 'YTick', [0 ymx]);
            end
        end

        plot(xsb(2:end-1), ysb(2:end-1), '-', 'Color', clr, 'LineWidth', lw);
        plot(xsb(ix), ysb(ix), 'r-', 'LineWidth', lw);

        if isnan(ymx)
            ymx = ceil(max(ylim));
            yl = [0 ymx];
            set(gca, 'YTick', [0 ymx]);
        end
    %     if sum(ix) > 0
    %         plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
    %             'r-', 'LineWidth', lw);
    %     end
    %     xlabel('Trial #');

        if c == ncols+1
            if strcmpi(fopts.behavNm, 'isCorrect')
                ylabel('Success rate(%)');                
            else
                ylabel('Acquisition time (s)');
            end
        end
        ylim(yl);
        if ~isnan(sameMinX)
            xIntMax = sameMinX;
        end
        plot([xIntMax xIntMax], ylim, '--', 'Color', 0.0*ones(3,1));
        xlim([min(xsb) max(xsb)]);
    %     set(gca, 'LineWidth', lw);    
        xlim([0 xmx]);

        if byMonkey
            set(gca, 'XTick', [sameMinX sameMinX+500]);
            set(gca, 'XTickLabel', [0 500]);
            set(gca, 'TickDir', 'out');
            mnks = {'Jeffy', 'Lincoln', 'Nelson'};
            title(mnks{c});        
        else
            set(gca, 'XTick', opts.xtick);
            title(obj.datestr);        
        end    
        c = c + 1;
    end

    if byMonkey
        plot.setPrintSize(gcf, struct('width', 9, 'height', 2.5));
    else
        plot.setPrintSize(gcf, struct('width', 7, 'height', 6));
    end

    if opts.doSave
        if ~exist(opts.saveDir, 'dir')
            mkdir(opts.saveDir);
        end
        pnm = fullfile(opts.saveDir, ...
            ['goodTrials_' opts.behavNm '_' kind '.pdf']);
        export_fig(gcf, pnm);
    end

end
