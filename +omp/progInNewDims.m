%% plot opts

opts.doSave = true;
opts.saveDir = fullfile('data', 'plots', 'omp');
opts.ext = 'pdf';

%% find basis for manifold

dec = ks(1).kalmanInitParams;
mu = dec.NormalizeSpikes.mean;
sdev = dec.NormalizeSpikes.std;
[~, beta] = omp.spikesToLatents(dec, nan);
[beta_nb, beta_rb] = io.getNulRowBasis(beta);
normSps = @(sps) bsxfun(@minus, sps, mu);
B = beta_nb*beta_nb'; % find dim orthogonal to manifold
% B = eye(size(B)); % find avg-activity dim

% baselineShift = mean(blks(end-1).sps) - mu;
% [beta_nb, beta_rb] = io.getNulRowBasis([baselineShift; beta]);
% B = beta_nb*beta_nb';

%% prep

atrgs = unique(blks(1).trgpos, 'rows'); % each of 8 targets
trgs = round(tools.computeAngles(bsxfun(@minus, atrgs, mean(atrgs))));
trgs = mod(-trgs, 360);
[trgs,ix] = sort(trgs);
atrgs = atrgs(ix,:);
ntrgs = numel(trgs);
ps = repmat(mean(atrgs), ntrgs, 1); % starting position

%% find dimension per target-angle

plot.init;
% axis off; axis equal;
% for kk = 1:ntrgs
%     subplot_tight(2,4,kk); hold on;

% find new dimension for all target-angles
newDims = cell(5, ntrgs);
for jj = 2:5
    for ii = 1:ntrgs
        ctrg = trgs(ii); % fit one dim per angle
%         ctrg = trgs(kk); % fit one dim across session
        newDims{jj,ii} = omp.getAvgActivityDim(blks(jj), ctrg, normSps, B);
    end
end

% best 40 trials for each OMP, start trial:
% trStarts = [nan 220 47 199 348 nan];
% cblk = blks(1); vfcn = decI.vfcn;
vfcn = decs(2).vfcn;

% plot polar grid
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 3;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.8*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

% clrs = cbrewer('seq', 'Blues', 5);
clrs = cbrewer('qual', 'Set1', 5);
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for jj = 2:5
    % find progress of each dimension
    prgs_pred = nan(ntrgs, ntrgs);    
    for ii = 1:ntrgs
        nD = repmat(newDims{jj,ii}{1}' + mu, ntrgs, 1); % new dim
        prgs_pred(ii,:) = lstmat.getProgress(nD, ps, atrgs, vfcn);
    end
    ys = diag(prgs_pred); ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 2);
end
legend({blks(2:5).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('progress of new dims');
% title(['dim: ' num2str(trgs(kk)) '^\circ']);

fnm = 'progs-newdims';
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
ymx = 50;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

if showIntBlks
    inds = 1:numel(blks);
    clrs = cbrewer('seq', 'Blues', 5);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.4 0.4; 0.5 0.5 0.5];
else
    inds = 2:5;
    clrs = cbrewer('qual', 'Set1', 5);
end
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for ii = inds
    cblk = blks(ii);
    prgs = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats(prgs, cblk.thgrps); ys = [ys; ys(1)];
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('actual progress');

fnm = 'progs';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% plot projection onto new dims

vfcn = decs(2).vfcn;
newDims = cell(ntrgs,1);
vss = cell(ntrgs,1);
for ii = 1:ntrgs
    newDims{ii} = omp.getAvgActivityDim(blks(end-1), trgs(ii), normSps, B);
    vs = cell(numel(blks),1);
    for jj = 1:numel(blks)
        vs{jj} = normSps(blks(jj).sps)*newDims{ii}{1};
    end
    vss{ii} = vs;
end

clrs = cbrewer('seq', 'Blues', 5);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.4 0.4; 0.5 0.5 0.5];

bins = linspace(-10, 20);
plot.init;
for ii = 1:ntrgs
    subplot(2,4,ii); hold on;
    for jj = 1:numel(blks)
        cs = histc(vss{ii}{jj}, bins);
        cs = cs/sum(cs);
        plot(bins, cs, 'Color', clrs(jj,:));
    end
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

plot.init;
for ii = 1:ntrgs
    subplot(2,4,ii); hold on;
    bar(1:numel(blks), cellfun(@var, vss{ii}), 'FaceColor', 'w');
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
for ii = 1:ntrgs
    newDims{ii} = omp.getAvgActivityDim(blks(end-1), trgs(ii), normSps, B);
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
