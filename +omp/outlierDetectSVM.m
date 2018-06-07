
doMultiOMP = true;
dts = omp.getDates(doMultiOMP);
dtstr = dts{8};

[blks, decs, ks, d] = omp.loadCoachingSessions(dtstr, ...
    true, false, ~doMultiOMP);

%%

alpha = 0.05; % outlier fraction
dec = decs(end);
blk = blks(2);

ix = (blk.tms <= 17) & (blk.tms >= 6);
X = blk.sps(ix, :);
X = dec.vfcn(X')';
mdl = fitcsvm(X, ones(size(X,1),1), 'KernelScale', 'auto', ...
    'Standardize', true, 'OutlierFraction', alpha);

%%

ixsv = mdl.IsSupportVector;
h = 2.0; % Mesh grid step size
mns = min(X);
mxs = max(X);
xs1 = mns(1):h:mxs(1);
xs2 = mns(2):h:mxs(2);
[X1, X2] = meshgrid(xs1, xs2);
[~, score] = predict(mdl, [X1(:), X2(:)]);
scoreGrid = reshape(score, size(X1,1), size(X2,2));

[~, sc] = predict(mdl, X);
ixOutlier = sc < 0;

%%

plot.init;

ncols = ceil(sqrt(numel(blks)+1));
nrows = ceil((numel(blks)+1)/ncols);
ns = nan(numel(blks), 1);
for ii = 1:numel(blks)
    subplot(nrows, ncols, ii); hold on;
    
    blk = blks(ii);
    ix = (blk.tms <= 17) & (blk.tms >= 6);
    Xc = blk.sps(ix, :);
    muShift = blk.spsBaseline - blks(1).spsBaseline;
    Xc = bsxfun(@minus, Xc, muShift);
    
    Xc = dec.vfcn(Xc')';
    [~, sc] = predict(mdl, Xc);
    ixOutlier = sc < 0;
    
    plot(Xc(:,1), Xc(:,2), 'k.', 'MarkerSize', 1);
    plot(Xc(ixOutlier,1), Xc(ixOutlier,2), 'r.', 'MarkerSize', 1);
    
    x1 = X1(scoreGrid > 0);
    x2 = X2(scoreGrid > 0);
    k = boundary(x1, x2);
    plot(x1(k), x2(k), 'r-', 'LineWidth', 1);
    
    title(blk.name);
    
    ns(ii) = mean(ixOutlier);
    
end

xlabel('v_x');
ylabel('v_y');

subplot(nrows, ncols, ii+1); hold on;
bar(1:numel(blks), 100*ns, 'FaceColor', 'w');
ylabel('% outliers');
plot(xlim, 100*[alpha alpha], 'k-');
title(dtstr);

