%% load

dirNm = 'distsFromManif_noShift';

opts.doSave = true;
opts.saveDir = fullfile('data', 'plots', 'omp', dirNm);
opts.ext = 'pdf';

dts = omp.getDates;
isIntOnly = false;
prefix = '';

% dts = {'20150212', '20150308', '20160717'};
% isIntOnly = true;
% prefix = 'intOnly-';

avs = cell(numel(dts),1);
for ii = 1%:numel(dts)
    dtstr = dts{ii}
    try
        [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, ...
            true, false, isIntOnly);
    catch
        continue;
    end
    
%     opts.fnm = [prefix 'vels-' dtstr];
%     omp.plotVelsColoredByDistFromManif(blks, decs(2), ks(1), opts);
    
    opts.fnm = [prefix 'prog-' dtstr];
    vals = omp.plotProgsVsDistFromManif(blks, decs(2), ks(1), opts);
    avs{ii} = vals;
    close all;
%     continue;
    
    plot.init;
    clrs = cbrewer('div', 'RdYlGn', 8);
    xl = [-0.05 0.35];
    yl = [-180 180];
    plot([0 0], yl, '-', 'Color', 0.8*ones(3,1));
    plot(xl, [0 0], '-', 'Color', 0.8*ones(3,1));
    for jj = 1:size(vals,2)
        p1 = squeeze(vals(1,jj,:));
        p2 = squeeze(vals(2,jj,:));
        plot([p2(1)-p1(1)], [p2(2)-p1(2)], '.', ...
            'Color', clrs(jj,:), 'MarkerSize', 20);
    end
    xlabel('\Delta distance');
    ylabel('\Delta progress');
    xlim(xl);
    ylim(yl);
    title(dtstr);
    fnm = fullfile(opts.saveDir, ['change-' dtstr '.pdf']);
    export_fig(gcf, fnm);    
    
%     close all;
    
%     omp.progInNewDims;
%     omp.progressInstability;

%     prgs0 = omp.plotBlockProgs(blks, decs, 0, opts, dtstr);
%     prgs1 = omp.plotBlockProgs(blks, decs, 1, opts, dtstr);
%     prgs2 = omp.plotBlockProgs(blks, decs, 2, opts, dtstr);
%     close all;
end

%%

plot.init;
plot([0 0], yl, '-', 'Color', 0.8*ones(3,1));
plot(xl, [0 0], '-', 'Color', 0.8*ones(3,1));

clrs = cbrewer('seq', 'Reds', numel(avsInt)+1); clrs = clrs(2:end,:);
for ii = 3:numel(avsInt)
    vs = squeeze(diff(avsInt{ii}));
    h = plot(vs(:,1), vs(:,2), '.', 'Color', clrs(ii,:));
    mu = median(vs);
    plot(mu(1), mu(2), '.', 'MarkerSize', 20, 'Color', clrs(2,:));
end

clrs = cbrewer('seq', 'Blues', numel(avsP)+1); clrs = clrs(2:end,:);
for ii = 11:numel(avsP)
    vs = squeeze(diff(avsP{ii}));
    if isempty(vs)
        continue;
    end
    h = plot(vs(:,1), vs(:,2), '.', 'Color', clrs(ii,:));
    mu = median(vs);
    plot(mu(1), mu(2), '.', 'MarkerSize', 20, 'Color', clrs(10,:));
end
xlabel('\Delta distance');
ylabel('\Delta progress');
xlim(xl);
ylim(yl);

