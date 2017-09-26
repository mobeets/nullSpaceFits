%% find basis for manifold

dec = kI.kalmanInitParams;
mu = dec.NormalizeSpikes.mean;
sdev = dec.NormalizeSpikes.std;
[~, beta] = omp.spikesToLatents(dec, nan);
[beta_nb, beta_rb] = io.getNulRowBasis(beta);
normSps = @(sps) bsxfun(@minus, sps, mu);
B = beta_nb*beta_nb'; % find dim orthogonal to manifold
% B = eye(size(B)); % find avg-activity dim

%% prep

atrgs = unique(blks(1).trgpos, 'rows'); % each of 8 targets
trgs = round(tools.computeAngles(bsxfun(@minus, atrgs, mean(atrgs))));
trgs = mod(-trgs, 360);
[trgs,ix] = sort(trgs);
atrgs = atrgs(ix,:);
ntrgs = numel(trgs);
ps = repmat(mean(atrgs), ntrgs, 1); % starting position

%% find dimension per target-angle

% best 40 trials for each OMP, start trial:
trStarts = [nan 220 47 199 348 nan];

% cblk = blks(1); vfcn = decI.vfcn;

vfcn = decP.vfcn;

plot.init;
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
    % find dimension for all target-angles
    cblk = blks(jj);
    newDims = cell(ntrgs, 1);
    for ii = 1:ntrgs
        newDims{ii} = omp.getAvgActivityDim(cblk, trgs(7), normSps, B);
    end

    % find progress of each dimension
    prgs_pred = nan(ntrgs, ntrgs);    
    for ii = 1:ntrgs
        nD = repmat(newDims{ii}{1}' + mu, ntrgs, 1); % new dim
        prgs_pred(ii,:) = lstmat.getProgress(nD, ps, atrgs, vfcn);
    end
%     ys = diag(prgs_pred);
    ys = diag(circshift(prgs_pred,-1)); % get off-diagonal
    ys = [ys; ys(1)];
    ys(ys < 0) = 0;
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(jj,:), ...
        'LineWidth', 2);
end
legend({blks(2:5).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('progress of new dims');

%% show actual progress

vfcn = decP.vfcn;

plot.init;
plot(0, 0, 'k+', 'HandleVisibility', 'off');
ymx = 50;
xs = tools.thetaCenters(32); xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
plot(ymx*xs(:,1), ymx*xs(:,2), '-', 'Color', 0.5*ones(3,1), ...
    'HandleVisibility', 'off');
for ii = 1:numel(trgs)
    plot([0 ymx*cosd(trgs(ii))], [0 ymx*sind(trgs(ii))], ...
        'k--', 'Color', 0.8*ones(3,1), 'HandleVisibility', 'off');
end

inds = 2:5;
% inds = 1:numel(blks);
clrs = cbrewer('qual', 'Set1', 5);
% clrs = cbrewer('seq', 'Blues', 5);
% clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.4 0.4; 0.5 0.5 0.5];
xs = trgs; xs = [xs; trgs(1)]; xs = [cosd(xs) sind(xs)];
for ii = inds
    % compare predicted to true progress
    cblk = blks(ii);
    prgs = lstmat.getProgress(cblk.sps, cblk.pos, cblk.trgpos, vfcn);
    ys = grpstats(prgs, cblk.thgrps);
    ys = [ys; ys(1)];
    plot(ys.*xs(:,1), ys.*xs(:,2), '-', 'Color', clrs(ii,:), ...
        'LineWidth', 2);
end
legend({blks(inds).name}, 'Location', 'BestOutside');
legend boxoff;
axis equal;
axis off;
title('actual progress');

%% plot projection onto new dims

vfcn = decP.vfcn;
newDims = cell(ntrgs,1);
vss = cell(ntrgs,1);
for ii = 1:ntrgs
    newDims{ii} = omp.getAvgActivityDim(blks(5), trgs(ii), normSps, B);
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

%% compare projections of data onto two new dims

bins = linspace(-10, 20);
plot.init;
for jj = 1:numel(blks)
    subplot(2,3,jj); hold on;
    cs1 = histc(vss{1}{jj}, bins);
    cs2 = histc(vss{6}{jj}, bins);
    plot(cs1, cs2, '.', 'Color', clrs(jj,:));
    vmx = max([cs1; cs2]);
    xlim([0 vmx]); ylim(xlim);
    plot(xlim, ylim, 'k--');
end
xlabel('projection onto new dim');
ylabel('normalized frequency');
% title(['new dim for angle ' num2str(trgs(ii)) '^\circ']);
