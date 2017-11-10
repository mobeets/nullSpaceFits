function allprgs = plotBlockProgs(blks, decs, decoderNumber, opts, fnm)
    if nargin < 3
        decoderNumber = 0; % use actual decoder in each block
    end
    if nargin < 4
        opts = struct('doSave');
    end    
    if nargin < 5
        fnm = '';
    end    
    plot.init;
    clrs = cbrewer('seq', 'Blues', numel(blks)-1);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];

    ps = lstmat.getProgress(blks(1).sps, blks(1).pos, blks(1).trgpos, ...
        decs(1).vfcn);
    ymx = max(grpstats(ps, blks(1).trs));
    ps = lstmat.getProgress(blks(2).sps, blks(2).pos, blks(2).trgpos, ...
        decs(2).vfcn);
    ymn = min(0, min(grpstats(ps, blks(2).trs)));
    
    if decoderNumber > 0
        vfcn = decs(decoderNumber).vfcn;
    end    
    trgs = tools.thetaCenters;
    allprgs = cell(numel(blks), numel(trgs));
    for jj = 1:numel(trgs)
        subplot(2,4,jj); hold on;
        ctrg = trgs(jj);
        x_last = 0;
        for ii = 1:numel(blks)    
            cblk = blks(ii);
            if decoderNumber == 0 % use actual decoder
                if ii == 1 || ii == numel(blks)
                    vfcn = decs(1).vfcn;
                else
                    vfcn = decs(2).vfcn;
                end
            end
            ix = cblk.trgs == ctrg;
            prgs = lstmat.getProgress(cblk.sps(ix,:), cblk.pos(ix,:), ...
                cblk.trgpos(ix,:), vfcn);
            xs = unique(cblk.trs(ix));
            xsa = unique(cblk.trs);
            if isempty(xs)
                x_last = x_last + max(xsa) - min(xsa);
                continue;
            end
            xs = xs - min(xsa);        
            ys = grpstats(prgs, cblk.trs(ix));
%             ys = smooth(ys, 10);
            plot(xs + x_last + 1, ys, '-', 'Color', clrs(ii,:));
%             plot(xs + x_last + 1, nanmedian(ys)*ones(size(ys)), ...
%                 '-', 'Color', clrs(ii,:));
            x_last = x_last + max(xsa) - min(xsa);
            plot([x_last x_last], [ymn ymx], '-', 'Color', 0.8*ones(3,1));
            allprgs{ii,jj} = [xs ys];
            if min(ys) < ymn
                ymn = min(ys);
            end
            if max(ys) > ymx
                ymx = max(ys);
            end
        end
        ylim([ymn ymx]);
        xlabel('trial #');
        ylabel('avg. progress');
        title([num2str(ctrg) '^\circ']);
    end
    for jj = 1:numel(trgs)
        subplot(2,4,jj); hold on;
        ylim([ymn ymx]);
    end

    plot.setPrintSize(gcf, struct('width', 11, 'height', 3));
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [fnm '_d' num2str(decoderNumber) '.' opts.ext]));
    end
end
