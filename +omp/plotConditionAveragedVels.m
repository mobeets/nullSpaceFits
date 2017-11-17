function plotConditionAveragedVels(blks, dec, opts)
    if nargin < 3
        opts = struct('doSave', false);
    end

	grps = tools.thetaCenters;
    clrs = cbrewer('div', 'RdYlGn', numel(grps));

    vs0 = dec.vfcn(blks(1).sps(blks(1).tms <= 16,:)')';
    k0 = omp.convhullpct(vs0, 0.95);
    
    vmx = 0;
    plot.init;
    ncols = min(3, numel(blks));
    nrows = ceil(numel(blks)/ncols);
    for jj = 1:numel(blks)
        subplot(nrows, ncols, jj); hold on;
        b = blks(jj);
        ix = b.tms <= 16;
        xs = [b.trgs(ix) b.tms(ix)];
        xss = unique(xs, 'rows');
        if isempty(xss)
            continue;
        end
        tms = unique(xss(:,2));
        spsPerTrg = grpstats(b.sps(ix,:), xs);
        vs = dec.vfcn(spsPerTrg')';
        vmx = max([vmx max(abs(vs(:)))]);        
        
        % plot current vels
        vsc = dec.vfcn(b.sps(ix,:)')';
%         plot(vsc(:,1), vsc(:,2), '.', 'Color', 0.9*ones(3,1), ...
%             'MarkerSize', 1);
        
        % plot baseline hull
        plot(vs0(k0,1), vs0(k0,2), '--', 'Color', 0.2*ones(3,1));
        
        % plot current hull
        k = omp.convhullpct(vsc, 0.95);        
        plot(vsc(k,1), vsc(k,2), '-', 'Color', 0.5*ones(3,1));

        for kk = 1:numel(grps)
            ix = xss(:,1) == grps(kk);
            plot(vs(ix,1), vs(ix,2), '.-', 'Color', clrs(kk,:));
            if kk == numel(grps)
                xlabel('v_x through OMP');
                ylabel('v_y through OMP');
            end
        end
        title(b.name);
        plot(0, 0, 'k+');
        vb = dec.vfcn(b.spsBaseline')';
        plot(vb(1), vb(2), 'r+', 'LineWidth', 2);
    end
    vmx = 2*vmx;
    for jj = 1:numel(blks)
        subplot(nrows, ncols, jj); hold on;
        xlim([-vmx vmx]); ylim(xlim);
        set(gca, 'XTick', [-50 0 50]);
        set(gca, 'YTick', [-50 0 50]);
    end
        
    plot.setPrintSize(gcf, struct('width', 2*ncols, 'height', 1.7*nrows));
    
    if opts.doSave
        fnm = fullfile(opts.saveDir, [prefix dtstr '.pdf']);
        export_fig(gcf, fnm);
    end
end
