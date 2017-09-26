
dtstr = '20131205';
G = lstmat.loadCleanSession(dtstr);
[X,Y,Yp] = lstmat.makeDesignMat(G.train);
[Xv,Yv,Yvp] = lstmat.makeDesignMat(G.test);

%% fit all models

nhyps = 4;
kfold = 5;
mdls = cell(size(Y,2), nhyps);
rsqs = nan(size(Y,2), nhyps);
rsqs_se = nan(size(Y,2), nhyps);
rsqvs = nan(size(Y,2), nhyps);

for ii = 1:size(Y,2)
    [rsqs(ii,1), rsqs_se(ii,1), rsqvs(ii,1), mdls{ii,1}] = ...
        lstmat.fitAndScoreWithCv(X, Y(:,ii), Xv, Yv(:,ii), kfold);
    [rsqs(ii,2), rsqs_se(ii,2), rsqvs(ii,2), mdls{ii,2}] = ...
        lstmat.fitAndScoreWithCv(Yp, Y(:,ii), Yvp, Yv(:,ii), kfold);
    [rsqs(ii,3), rsqs_se(ii,3), rsqvs(ii,3), mdls{ii,3}] = ...
        lstmat.fitAndScoreWithCv([X Yp], Y(:,ii), [Xv Yvp], Yv(:,ii), kfold);
    [rsqs(ii,4), rsqs_se(ii,4), rsqvs(ii,4), mdls{ii,4}] = ...
        lstmat.fitAndScoreWithCv(Yp, Y(:,ii), Yvp, Yv(:,ii), kfold, ii);
end

%% view rsqs

plot.init;
ymn = -1.0;
ymx = 1.0;

subplot(1,2,1); hold on; set(gca, 'FontSize', 16);
vs = rsqs;
for ii = 1:size(rsqs_se,1)
    for jj = 1:size(rsqs_se,2)
        x = rsqs(ii,jj);
        e = rsqs_se(ii,jj);
        plot([ii ii], [x-e x+e], 'k-', 'HandleVisibility', 'off');
    end
end
plot(vs, 'LineWidth', 2);
plot(xlim, [0 0], 'k--');
set(gca, 'XTick', 1:size(vs,1));
ylim([ymn ymx]);
xlabel('factor dimension');
ylabel('r^2_{adj} during intuitive (avg. cross-val)');
legend({'X_t only', 'Y_{t-1} only', 'X_t and Y_{t-1}', 'Y_{t-1} rw'});
legend boxoff;

subplot(1,2,2); hold on; set(gca, 'FontSize', 16);
vs = rsqvs;
plot(vs, 'LineWidth', 2);
plot(xlim, [0 0], 'k--');
set(gca, 'XTick', 1:size(vs,1));
ylim([ymn ymx]);
xlabel('factor dimension');
ylabel('r^2_{adj} during perturbation');
legend({'X_t only', 'Y_{t-1}', 'X_t and Y_{t-1}', 'Y_{t-1} rw'});
legend boxoff;
title(dtstr);

%% visualize weights of y_{t-1}^k for predicting y_t^k

vs = nan(size(mdls,1),1);
ps = nan(size(mdls,1),1);
for ii = 1:size(mdls,1)
%     vs(ii) = mdls{ii,3}.Coefficients.Estimate(13+ii);
%     ps(ii) = mdls{ii,3}.Coefficients.pValue(13+ii);
%     vs(ii) = mdls{ii,2}.Coefficients.Estimate(ii+1);
%     ps(ii) = mdls{ii,2}.Coefficients.pValue(ii);
    vs(ii) = mdls{ii,1}.Coefficients.Estimate(end-2);
    ps(ii) = mdls{ii,1}.Coefficients.pValue(end-2);
end
all(ps < eps) % all p-values below machine precision?
plot.init;
bar(vs, 'FaceColor', 'w');
set(gca, 'XTick', 1:numel(vs));
xlabel('factor dimension (k)');
ylabel('estimated weight of y^k_{t-1} in full model');
title(dtstr);

%% view rsqs as heatmap

figure; set(gcf, 'color', 'w');
imagesc(rsqs);
caxis([0 1]);
clrs = cbrewer('seq', 'Blues', 10);
colormap(clrs);
axis off;
colorbar;
