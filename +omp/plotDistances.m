dts = {'20150212', '20150308', '20160717'};
isIntOnly = true;

dts = omp.getDates;
isIntOnly = false;

pts = nan(numel(dts), numel(blks), 3);

for jj = 1:numel(dts)
    dtstr = dts{jj}
    try
        [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, true, false, isIntOnly);
    catch
        continue;
    end

    bins = linspace(0, 35);
%     plot.init;
%     title(dtstr);
    for ii = 1:numel(blks)
        cblk = blks(ii);
%         subplot(1, numel(blks), ii); hold on;

        % filter
        ix = cblk.tms >= 5;
        ix = true(size(ix));
        csps = cblk.sps(ix,:);
        if sum(ix) == 0
            continue;
        end

        % baseline corretion
    %     csps = bsxfun(@plus, csps, blks(1).spsBaseline - cblk.spsBaseline);

        % get distances
        ds = omp.distanceFromManifold(csps, ks);
        n = sum(~isnan(ds));
        pts(jj,ii,:) = [nanmean(ds) nanvar(ds) nanstd(ds)/sqrt(n)];
        continue;

        % plot
        cs = histc(ds, bins);        
        plot(cs, bins, '-', 'Color', cblk.clr);
        plot([0 max(cs)], [mean(ds) mean(ds)], '-', 'Color', cblk.clr, ...
            'LineWidth', 2); 

        if ii == 1
            ylabel('distance from manifold');
            xlabel('# of timesteps');
        else
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
        end
        title(cblk.name);
    end
%     plot.setPrintSize(gcf, struct('width', 1*numel(blks), 'height', 2));

end

%%

% plot.init;

cpts = ptsI; clrNm = 'Reds'; clr = [0.8 0.2 0.2];
dts = {'20150212', '20150308', '20160717'};

% cpts = ptsP; clrNm = 'Blues'; dts = omp.getDates; clr = [0.2 0.2 0.8];

% clrs = cbrewer('seq', clrNm, size(cpts,1)+1); clrs = clrs(2:end,:);

for ii = 1:size(cpts,1)
    subplot(5, 4, ii+16); hold on;
    cp = squeeze(cpts(ii,:,:));
    if any(cp(:) == 0)
        nd = find(cp(:,1) == 0, 1, 'first')-1;
    else
        nd = size(cp,1);
    end
    plot(1:nd, cp(1:nd,1), '.-', 'Color', clr);
    for jj = 1:nd
%         plot(jj, cp(jj,1), '.');
        plot([jj jj], [cp(jj,1) - cp(jj,3) cp(jj,1) + cp(jj,3)], '-', ...
            'Color', clr);
    end
    ylim([0 40]);
    xlim([0 15]);
    title(dts{ii});
end

%%

doOMP = true;

dts1 = omp.getDates(true);
dts2 = omp.getDates(false);

c = 0;
plot.init;
for kk = 0:1
    ix1 = cellfun(@isempty, strfind(dts1, '2016'));
    ix2 = cellfun(@isempty, strfind(dts2, '2016'));
    mkr = 's';
    if kk == 1
        ix1 = ~ix1;
        ix2 = ~ix2;
        mkr = 'o';
    end
%     Ds = {D1, D2};
%     Ds = {D1a, D2a};
    Ds = {D1d, D2d};
    Dts = {dts1, dts2};
    Ix = {ix1, ix2};
    
    for ll = 1:numel(Dts)
        dts = Dts{ll};
        ix = Ix{ll};
        D = Ds{ll};
        
        for ii = 1:numel(dts)
            if ~ix(ii)
                continue;
            end
            c = c + 1;
            subplot(5,4,c); hold on; set(gca, 'FontSize', 16);

            ys = D.avs{ii};
            xs = D.day{ii};
            ns = D.nms{ii};
            plot(xs, ys, '-', 'Color', 'k', 'LineWidth', 2);
            for jj = 1:numel(xs)
                if isempty(strfind(ns{jj}, 'OMP'))
                    clr = [0.8 0.2 0.2];
                else
                    clr = [0.2 0.2 0.8];
                end
                plot(xs(jj), ys(jj), mkr, 'Color', clr, ...
                    'MarkerFaceColor', clr);
            end
            if c == 9
                ylabel('Dist. of baseline from session-3 baseline');        
            end
            if c == 17
                xlabel('Day #');
            end
            title(dts{ii});            
            if kk == 0
                xlim([0 20]);
                ylim([0 10]);
            else
                xlim([0 10]);
                ylim([0 15]);
            end
        end
    end
end
