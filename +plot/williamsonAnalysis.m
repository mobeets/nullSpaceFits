%% init

dts = io.getDates;
Results = cell(numel(dts), 1);
nboots = 1;

for ll = 1:numel(dts)
    dtstr = dts{ll}
    dataDir = '~/code/wmpCode/data/preprocessed';
    try
        d = load(fullfile(dataDir, [dtstr '.mat'])); D = d.D;
    catch
        warning(dtstr);
        continue;
    end
    sps = D.blocks(1).spikes;
    [nt,nd] = size(sps);
    [~,inds] = sort(rand(nboots, nd),2);

    % fit fa while adding more and more neurons
    d_shared = nan(nboots, nd);
    pct_shared_var = nan(nboots, nd);
    faobjs = cell(nboots, nd);
%     dims = 2:5:nd;
    dims = [35 85];

    for ii = 1:nboots
        S = sps(:,inds(ii,:)); % shuffle neuron indices
        disp('----------------');
        disp(['repeat #' num2str(ii) ' of ' num2str(nboots)]);
        disp('----------------');
        for jj = 1:numel(dims)        
            cdim = dims(jj);
            disp(['# neurons: ' num2str(cdim)]);
            Sc = S(:,1:cdim);
            [d,prop,faobj] = tools.apply_fa_and_get_stats(Sc);
            d_shared(ii,cdim) = d;
            pct_shared_var(ii,cdim) = 100*prop;
            faobjs{ii,cdim} = faobj;
        end
    end
    
    clear obj;
    obj.datestr = D.datestr;
    obj.d_shared = d_shared;
    obj.pct_shared_var = pct_shared_var;
    obj.fa_objs = faobjs;
    Results{ll} = obj;
end

% save('data/fits/williamsonAnalysis_FAobjs_v2.mat', 'Results')

%% plot

d = load('data/fits/williamsonAnalysis.mat');
Results = d.Results;

doSave = false;
saveDir = 'data/plots/figures';
fnm = 'williamsonAnalysis';

nd = 85;
pct_shared_var = cell2mat(cellfun(@(d) d.pct_shared_var(1:85), Results, 'uni', 0));
d_shared = cell2mat(cellfun(@(d) d.d_shared(1:85), Results, 'uni', 0));
mksz = 25;

% dts = io.getDates;
% ixd = io.getMonkeyDateFilter(dts, {'Jeffy'});
% d_shared = d_shared(ixd,:);
% pct_shared_var = pct_shared_var(ixd,:);

nrows = 3; ncols = 1;

fig = plot.init;
subplot(nrows,ncols,1); hold on; set(gca, 'FontSize', 14);
xs = 1:nd; ys = d_shared;
mu = nanmean(ys); se = nanstd(ys)/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), 'k.', 'MarkerSize', mksz);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], 'k-');
end
xlim([0 87]);
xlabel('Unit count');
ylabel('Dimensionality (d_{shared})');
set(gca, 'TickDir', 'out');
% set(gca, 'TickLength', [0 0]);

subplot(nrows,ncols,2); hold on; set(gca, 'FontSize', 14);
xs = 1:nd; ys = pct_shared_var;
mu = nanmean(ys); se = nanstd(ys)/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), 'k.', 'MarkerSize', mksz);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], 'k-');
end
xlim([0 87]);
xlabel('Unit count');
ylabel('% Shared Variance');
set(gca, 'TickDir', 'out');
% set(gca, 'TickLength', [0 0]);

subplot(nrows,ncols,3); hold on; set(gca, 'FontSize', 14);
xs = 1:nd; ys = chanceangs;
mu = nanmean(ys); se = nanstd(ys);%/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), '.', 'Color', 0.7*ones(3,1), 'MarkerSize', mksz);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], '-', ...
        'Color', 0.7*ones(3,1), 'HandleVisibility', 'off');
end
xs = 1:nd; ys = angs;
mu = nanmean(ys); se = nanstd(ys)/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), 'k.', 'MarkerSize', mksz);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], 'k-', ...
        'HandleVisibility', 'off');
end
xlim([0.5 K+0.5]);
ylim([0 90]);
xlabel('Principal angle index');
ylabel('Angle (degrees)');
set(gca, 'TickDir', 'out');
legend({'Chance', '35 vs. 85 units'}, 'Location', 'NorthWest');
legend boxoff;
set(gca, 'XTick', 1:K);
set(gca, 'YTick', [0 30 60 90]);
% set(gca, 'TickLength', [0 0]);

plot.setPrintSize(gcf, struct('width', 5, 'height', 6));
if doSave
    export_fig(fig, fullfile(saveDir, [fnm '.pdf']));
end

%%

d = load('data/fits/williamsonAnalysis_FAobjs_v2.mat');
Results = d.Results;
K = 10;

nboots = 1;
angs = nan(numel(Results), K);
chanceangs = nan(numel(Results), K);
for ii = 1:numel(Results)
    r = Results{ii};
    
    % get the two L matrices
    dims = [35 85];
    L1 = r.fa_objs{dims(1)}.estParams.L;
    L2 = r.fa_objs{dims(2)}.estParams.L;
    
    % use only the units the two have in common
    n = min(dims);
    L1 = L1(1:n,:);
    L2 = L2(1:n,:);
    
    % compute modes of shared covariance matrix LL'
    [u1,s1,v1] = svd(L1*L1');
    [u2,s2,v2] = svd(L2*L2');
    
    % find the principal angles, using only the first K modes
    angs(ii,:) = rad2deg(tools.prinangle(u1(:,1:K), u2(:,1:K)));
    
    % find principal angles between random n-d vectors
    rndvecs = randn(2,nboots,K,n);
    rndangs = nan(nboots,K);
    for ll = 1:nboots
        a1 = squeeze(rndvecs(1,ll,:,:))';
        a2 = squeeze(rndvecs(2,ll,:,:))';
        a1 = bsxfun(@times, a1, 1./sqrt(sum(a1.^2)));
        a2 = bsxfun(@times, a2, 1./sqrt(sum(a2.^2)));
        rndangs(ll,:) = rad2deg(tools.prinangle(a1, a2));
    end
    if nboots > 1
        rndangs = nanmean(rndangs);
    end
    chanceangs(ii,:) = rndangs;
end

fig = plot.init;
xs = 1:nd; ys = chanceangs;
mu = nanmean(ys); se = nanstd(ys);%/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), '.', 'Color', 0.7*ones(3,1), 'MarkerSize', 30);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], '-', ...
        'Color', 0.7*ones(3,1), 'HandleVisibility', 'off');
end
xs = 1:nd; ys = angs;
mu = nanmean(ys); se = nanstd(ys)/sqrt(size(ys,1));
ix = ~isnan(mu);
h = plot(xs(ix), mu(ix), 'k.', 'MarkerSize', 30);
for ii = 1:numel(mu)
    if isnan(mu(ii))
        continue;
    end
    plot([xs(ii) xs(ii)], [mu(ii)-se(ii) mu(ii)+se(ii)], 'k-', ...
        'HandleVisibility', 'off');
end
xlim([0.5 K+0.5]);
ylim([0 90]);
xlabel('Principal angle index');
ylabel('Angle (degrees)');
set(gca, 'TickDir', 'out');
legend({'Chance', '35 vs. 85 units'}, 'Location', 'NorthWest'); legend boxoff;
% set(gca, 'TickLength', [0 0]);
