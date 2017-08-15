function showHeatmapSubset(D, bind, trg, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('trBinSz', 0, 'makeSubplots', false, ...
        'timeRange', [7 nan], ...
        'showCurBoundary', false, 'doSave', false, ...
        'width', 4, 'height', 4, 'margin', 0.125, ...
        'saveDir', 'data/plots/clouds', 'savePrefix', '', 'savePostfix', '');
    
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);    
    
    tss = D.blocks(bind).trial_index;
    trgs = round(D.blocks(bind).targetAngle);
    tsas = unique(tss(trgs == trg));
    ix0 = D.blocks(bind).isCorrect;
    tms = D.blocks(bind).time;
    dat = D.dat{bind};
    
    ntrgs = numel(tools.thetaCenters);
    ncols = ceil(ntrgs/2);
    nrows = ceil(ntrgs/ncols);
    clrs = cbrewer('div', 'RdYlGn', ntrgs);
    clr = clrs(trg == tools.thetaCenters, :);
    
    ii = 0;
    nt = numel(tsas);
    if opts.trBinSz == 0
        opts.trBinSz = nt;
    end
    trsts = 1:opts.trBinSz:nt;
    for tst = trsts
        ii = ii + 1;
        if opts.makeSubplots
            subplot_tight(ncols, nrows, ii, 0); hold on;
        else
            plot.init;
        end
        cts = tsas(tst:min(tst+opts.trBinSz, nt));
        ix = ismember(tss, cts);
        if ~isnan(opts.timeRange(1))
            ix = ix & tms >= opts.timeRange(1);
        end
        if ~isnan(opts.timeRange(2))
            ix = ix & tms < opts.timeRange(2);
        end
        if ~isempty(ix0)
            ix = ix & ix0;
        end
                
        h = clouds.showHeatmap(dat(ix,:), D.ctrs);
        set(gca, 'ydir', 'normal');
        
        % show all total boundaries
        for jj = 1:numel(D.bnd)
            bnd = D.bnd(jj);
            bclr = ones(3,1);
            if bind ~= jj
                bclr = 0.3*bclr;
            end
            plot(bnd.x, bnd.y, '-', 'Color', bclr);
        end
        if opts.showCurBoundary
            bnd = clouds.getBoundary(dat(ix,:));
            plot(bnd.x, bnd.y, '-', 'Color', clr);
        end
        
        % set limits based on ctrs
        xmn = min(D.ctrs{1}); xmx = max(D.ctrs{1});
        ymn = min(D.ctrs{2}); ymx = max(D.ctrs{2});
        xlim([xmn xmx]); ylim([ymn ymx]);
        
        acqTm = mean(grpstats(tss(ix), tss(ix), @numel)*45/1000);
        xl = xlim; yl = ylim;
        if opts.makeSubplots
            text(mean(xl), prctile(yl, 40), sprintf('%0.2f', acqTm), ...
                'Color', 'w');
        else
            title(sprintf(['blk %d (%d of %d), trg %d, avg atm = %0.2f'], ...
                bind, ii, numel(trsts), trg, acqTm), 'FontSize', 12);
        end
        axis off;
                
        if ~opts.makeSubplots
            finishFig(bind, trg, [num2str(ii)], opts);
        end        
    end
    if opts.makeSubplots
        finishFig(bind, trg, 'all', opts);
    end

end

function finishFig(bind, trg, nm, opts)
    plot.setPrintSize(gcf, opts);
    if opts.doSave
        fnm = [opts.savePrefix '-trg' num2str(trg) ...
            '-blk' num2str(bind) '-' nm opts.savePostfix '.pdf'];
        export_fig(gcf, fullfile(opts.saveDir, fnm));
    end
end
