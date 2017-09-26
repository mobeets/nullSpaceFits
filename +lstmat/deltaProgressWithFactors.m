
%% relating change in progress to factor activity with CCA
% per cursor-target angle

[G,F,D] = lstmat.loadCleanSession('20131205');

minTm = 5;
tr0 = 25;

B = D.blocks(2);
ths = B.thetaGrps;
Y = B.latents;
tm = B.time;
trs = B.trial_index;
dprg = diff(B.progress);
ths = ths(2:end,:);
Y = Y(2:end,:);
ixd = diff(tm) == 1;
tm = tm(2:end,:);
trs = trs(2:end,:);

ix = ixd & ~isnan(dprg) & ~any(isnan(Y),2) & ~isnan(ths) & tm > minTm;

[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(B, tr0, ...
    'progress', @max, minTm, inf);
trE1 = min(ts);
trE2 = trE1 + tr0;
trRngs = [trE1 trE2; trL1 trL2];
grps = tools.thetaCenters;

As = nan(numel(grps), size(Y,2), 2);
rsqs = nan(numel(grps),2);

for jj = 1:2
    ixc = ix & trs >= trRngs(jj,1) & trs <= trRngs(jj,2);
    cths = ths(ixc);
    cdprg = dprg(ixc);
    cY = Y(ixc,:);

    for ii = 1:numel(grps)
        ixt = cths == grps(ii);
        [As(ii,:,jj),b,R,u,v,stats] = canoncorr(cY(ixt,:), cdprg(ixt));
        rsqs(ii,jj) = corr(u,v);
    end

    vs = As(:,:,jj)';
    vmx = max(abs(vs(:)));
    figure;
    set(gcf, 'color', 'w');
    imagesc(vs);
    set(gca, 'FontSize', 16);
    xlabel('\theta');
    ylabel('factor dimension');
    colormap(cbrewer('div', 'RdBu', 21));
    grpnms = arrayfun(@num2str, grps, 'uni', 0);
    set(gca, 'XTick', 1:numel(grps));
    set(gca, 'XTickLabel', grpnms);
    caxis([-vmx vmx]);
    colorbar;
    title(D.datestr);
end

% plot.init;
% plot(rsqs(:,1), rsqs(:,2), 'ko');
% xlim([0 1]); ylim(xlim);
% plot(xlim, ylim, 'k--');

angs = @(ii) rad2deg(subspace(As(ii,:,1)', As(ii,:,2)'));
vs = arrayfun(angs, 1:size(As,1));
plot.init;
bar(vs, 'FaceColor', 'w');
set(gca, 'XTick', 1:numel(grps));
set(gca, 'XTickLabel', grpnms);
xlabel('\theta');
ylabel('\Delta angle between early and late');
title(D.datestr);

%% regress factors on progress change, per theta group

grps = tools.thetaCenters;
mdls = cell(numel(grps),1);
for ii = 1:numel(grps)
    ix = ths == grps(ii);
    mdls{ii} = fitlm(Y(ix,:), dprg(ix));
end

ws = cell2mat(cellfun(@(m) m.Coefficients.Estimate(2:end), mdls, 'uni', 0)');
ps = cell2mat(cellfun(@(m) m.Coefficients.pValue(2:end), mdls, 'uni', 0)');
rsqs = cell2mat(cellfun(@(m) m.Rsquared.Adjusted, mdls, 'uni', 0)');

%% plot weights

vs = As';
% vs = ws;
% vs = zscore(ws,0,2);
vmx = max(abs(vs(:)));

figure;
set(gcf, 'color', 'w');
imagesc(vs);
set(gca, 'FontSize', 16);
xlabel('\theta');
ylabel('factor dimension');
colormap(cbrewer('div', 'RdBu', 21));
grpnms = arrayfun(@num2str, grps, 'uni', 0);
set(gca, 'XTick', 1:numel(grps));
set(gca, 'XTickLabel', grpnms);
caxis([-vmx vmx]);
colorbar;

title(D.datestr);
