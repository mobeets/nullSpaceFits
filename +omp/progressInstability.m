
opts.doSave = false;
opts.saveDir = fullfile('data', 'plots', 'omp', 'instab');
opts.ext = 'pdf';

%%

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

atrgs = unique(blks(1).trgpos, 'rows'); % each of 8 targets
trgs = round(tools.computeAngles(bsxfun(@minus, atrgs, mean(atrgs))));
trgs = mod(-trgs, 360);
[trgs,ix] = sort(trgs);
atrgs = atrgs(ix,:);
ntrgs = numel(trgs);
ps = repmat(mean(atrgs), ntrgs, 1); % starting position

%% actual progress

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
for ii = inds
    cblk = blks(ii); csps = cblk.sps;
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
title('actual progress (omp)');

fnm = 'progs-actual';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end

%% progress of baseline-shift

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
title('baseline-shifted int. (omp)');

fnm = 'progs-baseline-shift';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end


%% progress of actual and of baseline-shift

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

inds = [1 numel(blks)-1];
clrs = cbrewer('seq', 'Blues', numel(blks)-1);
clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];

xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
nms = [];
for ii = inds
    
    if (ii > 1)
        cblk = blks(1);
        muShift = blks(ii).spsBaseline - cblk.spsBaseline;
        csps = bsxfun(@plus, cblk.sps, muShift);
        prgsN = lstmat.getProgress(csps, cblk.pos, cblk.trgpos, vfcn);
        ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], @(v) prctile(v, 90));
        ys = [ys; ys(1)];
        ys(ys < 0) = 0; % ignore negative progress
        plot(ys.*xs(:,1), ys.*xs(:,2), '--', 'Color', clrs(ii,:), ...
            'LineWidth', 2);
        nms = [nms {[blks(ii).name '-shift']}];
    end
    
    cblk = blks(ii); csps = cblk.sps;
    prgsN = lstmat.getProgress(csps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats([prgsN; nan(numel(trgs),1)], [cblk.thgrps; trgs], @(v) prctile(v, 90));
    ys = [ys; ys(1)];
    ys(ys < 0) = 0; % ignore negative progress
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
    
    nms = [nms {blks(ii).name}];
end
legend(nms, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('baseline-shifted int. (omp)');

fnm = 'progs-both';
plot.setPrintSize(gcf, struct('width', 6, 'height', 5));
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [dtstr '-' fnm '.' opts.ext]));
end
