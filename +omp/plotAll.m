%% load

dirNm = 'CI/moreTime';

opts.doSave = false;
opts.saveDir = fullfile('data', 'plots', 'omp', dirNm);
opts.ext = 'pdf';

doMultiOMP = true;

dts = omp.getDates(doMultiOMP);
if doMultiOMP
    prefix = '';
else
    prefix = 'intOnly-';
end

for ii = 1%1:numel(dts)
    dtstr = dts{ii}
%     try
%         [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, ...
%             true, false, ~doMultiOMP);
%     catch
%         continue;
%     end
    
    if strcmpi(blks(end).name, 'Washout')
        blks = blks(1:end-1);
    end

    dec = decs(2);
    omp.plotConditionAveragedVels(blks, dec, opts);
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

