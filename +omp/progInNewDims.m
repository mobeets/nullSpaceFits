%% plot opts

opts.doSave = false;
opts.saveDir = fullfile('data', 'plots', 'omp', 'progress');
opts.ext = 'pdf';

%% plot progress per trial for all blocks

prgs0 = omp.plotBlockProgs(blks, decs, 0, opts, dtstr);
prgs1 = omp.plotBlockProgs(blks, decs, 1, opts, dtstr);
prgs2 = omp.plotBlockProgs(blks, decs, 2, opts, dtstr);

%% find basis for manifold

dec = ks(1).kalmanInitParams;
mu = dec.NormalizeSpikes.mean;
sdev = dec.NormalizeSpikes.std;
[~, beta] = omp.spikesToLatents(dec, nan);
[beta_nb, beta_rb] = io.getNulRowBasis(beta);
normSps = @(sps) bsxfun(@minus, sps, mu);
Bn = beta_nb*beta_nb'; % find dim orthogonal to manifold
B = eye(size(Bn)); % find avg-activity dim
% B = beta_rb*beta_rb'; % find dim in manifold

baselineShift = mean(blks(end-1).sps) - mu;
[beta_nb, beta_rb] = io.getNulRowBasis([baselineShift; beta]);
Bn = beta_nb*beta_nb';

%% prep

[trgs, atrgs, ps] = omp.findTargetsAndStartPos(blks(1));

%% find dimension per target-angle

showOffManDims = true;

% best 40 trials for each OMP, start trial:
% trStarts = [nan 220 47 199 348 nan];
% cblk = blks(1); vfcn = decI.vfcn;
vfcn = decs(2).vfcn;

plot.init;
% axis off; axis equal;
% for kk = 1:ntrgs
%     subplot_tight(2,4,kk); hold on;

% find new dimension for all target-angles
newDimsN = cell((numel(blks)-1), ntrgs);
dimNormsN = newDimsN;
newDimsM = newDimsN;

% inds = 2:(numel(blks)-1);
inds = [1 2 numel(blks)-1 numel(blks)];
% inds = 1:numel(blks);

for jj = inds
    for ii = 1:ntrgs
        ctrg = trgs(ii); % fit one dim per angle
%         ctrg = trgs(kk); % fit one dim across session
        
        [Bn, normSps] = omp.findSubspaceForDim(ks, blks(jj), true, true);
        [newDimsN{jj,ii}, dimNormsN{jj,ii}] = omp.getAvgActivityDim(...
            blks(jj), ctrg, normSps, Bn, nan, true, 20);
        [newDimsM{jj,ii}, dimNormsM{jj,ii}] = omp.getAvgActivityDim(...
            blks(jj), ctrg, normSps, B, nan, true, 20);
    end
end
[beta_nb, beta_rb] = io.getNulRowBasis(beta);
Bn = beta_nb*beta_nb'; % reset for later use

% plot polar grid
ymx = 70;
plot(0, 0, 'k+', 'HandleVisibility', 'off');
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.8*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

% clrs = cbrewer('seq', 'Blues', numel(blks));
clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
% clrs = cbrewer('qual', 'Set1', (numel(blks)-1));
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
prgsN = cell(numel(blks)-1,1);
prgsM = cell(numel(blks)-1,1);

for jj = inds
    
    % find progress off-manifold
    prgs_pred = nan(ntrgs, ntrgs);    
    for ii = 1:ntrgs
        pc = nan(numel(dimNormsN{jj,ii}), ntrgs);
        for kk = 1:numel(dimNormsN{jj,ii})
            cDim = dimNormsN{jj,ii}{kk}*newDimsN{jj,ii}{kk};
            nD = repmat(cDim' + mu, ntrgs, 1); % new dim
            pc(kk,:) = lstmat.getProgress(nD, ps, atrgs, vfcn);
        end
        prgs_pred(ii,:) = mean(pc);
    end
    prgsN{jj} = prgs_pred;
    
    % find progress
    prgs_pred = nan(ntrgs, ntrgs);    
    for ii = 1:ntrgs
        pc = nan(numel(dimNormsM{jj,ii}), ntrgs);
        for kk = 1:numel(dimNormsM{jj,ii})
            cDim = dimNormsM{jj,ii}{kk}*newDimsM{jj,ii}{kk};
            nD = repmat(cDim' + mu, ntrgs, 1); % new dim
            pc(kk,:) = lstmat.getProgress(nD, ps, atrgs, vfcn);
        end
        prgs_pred(ii,:) = mean(pc);
    end
    prgsM{jj} = prgs_pred;
    
    if showOffManDims
        cprgs = prgsN;
    else
        cprgs = prgsM;
    end
    
    ys = diag(cprgs{jj}); ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
if showOffManDims
    title('progress of new dims (off-manifold)');
else
    title('progress of total dims');
end
% title(['dim: ' num2str(trgs(kk)) '^\circ']);

fnm = 'progs-newdims';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% compare progress in- vs. off-manifold

plot.init;

% plot polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 100;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for yc = [25 50 75 100]
    plot(yc*xs(:,1), yc*xs(:,2), '-', 'Color', 0.9*ones(3,1), ...
        'HandleVisibility', 'off');
end
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.9*ones(3,1), 'HandleVisibility', 'off');
end

% clrs = cbrewer('seq', 'Blues', numel(blks));
clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
% clrs = cbrewer('qual', 'Set1', (numel(blks)-1));
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];

% inds = 2:(numel(blks)-1);
inds = [1 2 numel(blks)-1 numel(blks)];
% inds = 1:numel(blks);

for jj = inds
    % find progress of each dimension
    pso = prgsN{jj};
    pst = prgsM{jj};
    ys = 100*diag(pso)./diag(pst); ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
%     ys(ys > 150) = 150; % clip
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 2);
end
xlim([-125 125]); ylim(xlim);
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('proportion of off-manifold progress');

fnm = 'progs-newdims-prop';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% show actual progress

showIntBlks = false;
vfcn = decs(2).vfcn;

plot.init;

% show polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 70;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

if showIntBlks
%     inds = 1:numel(blks);
    inds = [1 2 numel(blks)-1 numel(blks)];
    clrs = cbrewer('seq', 'Blues', numel(blks)-1);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
else
    inds = 2:(numel(blks)-1);
%     clrs = cbrewer('qual', 'Set1', numel(blks)-1);
    clrs = cbrewer('seq', 'Blues', numel(blks));
end
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for ii = inds
    cblk = blks(ii);
    prgsN = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], 'nanmean');
    ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('actual progress (omp)');

fnm = 'progs';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% show actual progress - before/after

showIntBlks = true;
vfcn = decs(2).vfcn;

plot.init;

% show polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 70;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

if showIntBlks
%     inds = 1:numel(blks);
    inds = [1 2 numel(blks)-1 numel(blks)];
    clrs = cbrewer('seq', 'Blues', numel(blks)-1);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
else
    inds = 2:(numel(blks)-1);
%     clrs = cbrewer('qual', 'Set1', numel(blks)-1);
    clrs = cbrewer('seq', 'Blues', numel(blks));
end

xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for ii = inds
    cblk = blks(ii);
    prgsN = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], 'nanmean');
    ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('actual progress (omp)');

fnm = 'wash-progs';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% show actual progress - Int decoder

showIntBlks = true;
vfcn = decs(1).vfcn;

plot.init;

% show polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 70;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

if showIntBlks
%     inds = 1:numel(blks);
    inds = [1 2 numel(blks)-1 numel(blks)];
    clrs = cbrewer('seq', 'Blues', numel(blks)-1);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
else
    inds = 2:(numel(blks)-1);
%     clrs = cbrewer('qual', 'Set1', numel(blks)-1);
    clrs = cbrewer('seq', 'Blues', numel(blks));
end
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for ii = inds
    cblk = blks(ii);
    prgsN = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], 'nanmean');
    ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('actual progress (int.)');

fnm = 'int-progs';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% plot projection onto new dims

vfcn = decs(2).vfcn;
newDims = cell(ntrgs,1);
vss = cell(ntrgs,1);
vmn = inf; vmx = -inf;
for ii = 1:ntrgs
    newDims{ii} = omp.getAvgActivityDim(blks(end-1), trgs(ii), normSps, Bn);
    vs = cell(numel(blks),1);
    for jj = 1:numel(blks)
%         bsps = omp.sampleTimestepsEvenly(blks(jj).sps, blks(jj).trs, numel(newDims{ii}));
%         vst = cell(size(bsps,1),1);
%         for kk = 1:size(bsps,1)
%             vst{kk} = normSps(squeeze(bsps(kk,:,:)))*newDims{ii}{kk};
%         end
        bsps = omp.sampleTimestepsEvenly(blks(jj).sps, blks(jj).trs, 1);
        vs{jj} = normSps(squeeze(bsps(1,:,:)))*newDims{ii}{1};
        vs{jj} = normSps(blks(jj).sps)*newDims{ii}{1};
        vmn = min(vmn, prctile(vs{jj}, 5));
        vmx = max(vmx, prctile(vs{jj}, 95));
    end
    vss{ii} = vs;
end

clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];

bins = linspace(vmn, vmx);
plot.init;
for ii = 1:ntrgs
    subplot(2,4,ii); hold on;
    for jj = 1:numel(blks)
        cs = histc(vss{ii}{jj}, bins);
        cs = cs/sum(cs);
        plot(bins, smooth(cs, 5), 'Color', clrs(jj,:));
    end
    xlim([vmn vmx]);
    xlabel('projection onto new dim');
    ylabel('normalized frequency');
    title(['new dim for angle ' num2str(trgs(ii)) '^\circ']);
end

fnm = 'proj';
plot.setPrintSize(gcf, struct('width', 9, 'height', 3));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% plot variance in new dims

% clrs = cbrewer('seq', 'Blues', numel(blks)-1);
% clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
clrs = [0.8 0.4 0.4; repmat([0.4 0.4 0.8], numel(blks)-2, 1); 0.8 0.4 0.4];

plot.init;
for ii = 1:ntrgs
    subplot(2,4,ii); hold on;
    for jj = 1:numel(blks)
        bar(jj, var(vss{ii}{jj}), 'FaceColor', 'w', 'EdgeColor', clrs(jj,:));
    end
    set(gca, 'XTick', 1:numel(blks));
    set(gca, 'XTickLabel', {blks.name});
    set(gca, 'XTickLabelRotation', 45);
    ylabel('variance of projection');
    title(['new dim for angle ' num2str(trgs(ii)) '^\circ']);
end

fnm = 'vars';
plot.setPrintSize(gcf, struct('width', 9, 'height', 3));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% compare dimensions

newDims = cell(ntrgs,1);
varExp = cell(ntrgs,1);
for ii = 1:ntrgs
    [newDims{ii},~,varExp{ii}] = omp.getAvgActivityDim(blks(end-1), ...
        trgs(ii), normSps, Bn);
end

nrms = nan(ntrgs, ntrgs);
plot.init;
for ii = 1:ntrgs
    subplot(2,4,ii); hold on;    
    for jj = 1:ntrgs
        plot(newDims{jj}{1}' + 0*mu, '-', 'Color', 0.8*ones(3,1));
        nrms(ii,jj) = rad2deg(subspace(newDims{jj}{1}, newDims{ii}{1}));
    end
    plot(newDims{ii}{1}' + 0*mu, 'k-', 'LineWidth', 1);
    title([num2str(trgs(ii)) '^\circ']);
end
xlabel('neuron index');
ylabel('weight on neuron');

fnm = 'dims';
plot.setPrintSize(gcf, struct('width', 9, 'height', 4));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% show proportion of activity that is off-manifold

clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];

plot.init;

% show polar grid
ymx = 1;
plot(0, 0, 'k+', 'HandleVisibility', 'off');
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for yc = [25 50 75 100]/100
    plot(yc*xs(:,1), yc*xs(:,2), '-', 'Color', 0.9*ones(3,1), ...
        'HandleVisibility', 'off');
end
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

inds = [1 numel(blks)-2 numel(blks)-1 numel(blks)];
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for jj = inds
    varExp = cell(ntrgs,1);
    
    baselineShift = mean(blks(jj).sps) - dec.NormalizeSpikes.mean;
    [beta_nb, beta_rb] = io.getNulRowBasis([baselineShift; beta]);
    Bn = beta_nb*beta_nb';
    
    for ii = 1:ntrgs
        [~,~,varExp{ii}] = omp.getAvgActivityDim(blks(jj), ...
            trgs(ii), normSps, Bn);
    end
    ys = cellfun(@(c) mean(cell2mat(c)), varExp);
    ys = [ys; ys(1)];
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 2);
end

legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('proportion of activity that is off-manifold');

%% show progress of intuitive with baseline shift

vfcn = decs(2).vfcn;

plot.init;

% show polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 100;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

inds = [1 2 numel(blks)-1];
clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];

xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
cblk = blks(1);
for ii = inds
%     muShift = nanmean(blks(ii).sps) - nanmean(cblk.sps);
    muShift = blks(ii).spsBaseline - cblk.spsBaseline;
    csps = bsxfun(@plus, cblk.sps, muShift);
    
%     cblk = blks(ii); csps = cblk.sps;
    
    prgsN = lstmat.getProgress(csps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], @(v) prctile(v, 90));
    ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('progress of baseline-shifted intuitive (omp)');

fnm = 'wash-progs';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end
