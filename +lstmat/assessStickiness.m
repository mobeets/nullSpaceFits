
% [G,F,D] = lstmat.loadCleanSession('20160722');
B = D.blocks(2);

minTm = 5; % end of freeze period
tr0 = 150; % # of trials to use

% identify block of trials with best learning
[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(B, tr0, ...
    'progress', @max, minTm, inf);
trE1 = min(ts);
trE2 = trE1 + tr0;
trRngs = [trE1 trE2; trL1 trL2];
% trRngs(2,:) = [0 inf];

[X,Y,Yp,ix] = lstmat.makeDesignMat(B, trRngs(2,:), [minTm inf]);

%% fit all factor dims for each cursor-target angle

grps = tools.thetaCenters;
ngrps = numel(grps);
kfold = 5;
rsqs = nan(size(Y,2), ngrps);
rsqs_se = nan(size(Y,2), ngrps);

ths = B.thetaGrps(2:end); thsc = ths(ix);
for ii = 1:numel(grps)
    ixc = thsc == grps(ii);
    Yc = Y(ixc,:);
    Ypc = Yp(ixc,:);
    for jj = 1:size(Y,2)        
        [rsqs(jj,ii), rsqs_se(jj,ii)] = ...
            lstmat.fitAndScoreWithCv(Ypc, Yc(:,jj), [], [], kfold);
    end
end

%% plot rsqs

figure; set(gcf, 'color', 'w');
imagesc(rsqs);
set(gca, 'FontSize', 16);
xlabel('\theta (cursor-target)');
% xlabel('\theta (velocity)');
ylabel('factor dimension');
set(gca, 'XTick', 1:numel(grps));
grpnms = arrayfun(@num2str, grps, 'uni', 0);
set(gca, 'XTickLabel', grpnms);
title(D.datestr);
ymx = max(abs(rsqs(:)));
caxis([-ymx ymx]);
clrs = cbrewer('div', 'RdBu', 21);
colormap(clrs);
colorbar;

%% plot behavior per group

grps = tools.thetaCenters;
ths = B.thetaActualImeGrps(2:end); thsc = ths(ix);
prg = B.progress(2:end); prgc = prg(ix);

plot.init;
for ii = 1:numel(grps)
    ixc = thsc == grps(ii);
    bar(ii, nanmean(prg(ixc)), 'FaceColor', 'w');    
end
bar(sum(rsqs), 'FaceColor', 'none', 'EdgeColor', 'r');
set(gca, 'XTick', 1:numel(grps));
grpnms = arrayfun(@num2str, grps, 'uni', 0);
set(gca, 'XTickLabel', grpnms);
title(D.datestr);

%% find distance between y_t and y_{t-1} for each cursor-target group

grps = tools.thetaCenters;
thsp = tools.thetaGroup(tools.computeAngles(X(:,end-1:end)), grps);
ths = tools.thetaGroup(tools.computeAngles(X(:,end-3:end-2)), grps);
[sum(ths == thsp) sum(ths ~= thsp)]

ixm = ths == thsp;
nboots = 100;
ds = cell(numel(grps), nboots+1);
for ii = 1:numel(grps)
    ixc = ixm & (ths == grps(ii));
    Yc = Y(ixc,:);
    Ypc = Yp(ixc,:);
    ds{ii,1} = sqrt(sum((Yc - Ypc).^2,2));
    for jj = 1:nboots
        inds = randperm(sum(ixc));
        ds{ii,jj+1} = sqrt(sum((Yc - Ypc(inds,:)).^2,2));
    end
%     mu = mean(Yc);
%     cfs = pca(Yc);
%     yc = bsxfun(@minus, Yc, mu)*cfs;
%     ypc = bsxfun(@minus, Ypc, mu)*cfs;
end

[mus(:,1) mean(mus(:,2:end),2) - std(mus(:,2:end),[],2)/10]

%% plot distances from above

bins = linspace(0, round(max(max(cell2mat(ds)))), 50);
hstsData = cellfun(@(d) histc(d, bins), ds(:,1), 'uni', 0);
hstsNull = cellfun(@(d) histc(d, bins), ds(:,2:end), 'uni', 0);

plot.init;
for ii = 1:numel(grps)
    cs = histc(ds{ii,1}, bins); cs = cs/sum(cs);
    dNull = cell2mat(ds(ii,2:end));
    csNull = histc(dNull(:), bins); csNull = csNull/sum(csNull);
    
    subplot(2,4,ii); hold on;
    plot(cs, 'Color', [0.8 0.2 0.2]);
    plot(csNull, 'k');
    xlabel(['|| y_t - y_{t-1} ||_2 when \theta=' num2str(grps(ii)) '^\circ']);
    ylabel('proportion');
    
    if ii == 1
        legend({'data', 'shuffled'});
        legend boxoff;
    end
end

%% plot last freeze activity

B = D.blocks(2);
Y = B.latents;
trgs = bsxfun(@minus, B.target, mean(unique(B.target, 'rows')));
trgs = round(tools.computeAngles(trgs));
trs = B.trial_index;
tm = B.time;

ixtr = trs >= trRngs(2,1) & trs <= trRngs(2,2);
% ixtr = trs >= trRngs(1,1) & trs <= trRngs(1,2);
% ixtr = true(size(trs));

grps = tools.thetaCenters;
% plot.init;
for ii = 1:numel(grps)
    subplot(2,4,ii); hold on;
    ixc = trgs == grps(ii) & ixtr;
    ctrs = trs(ixc);
    actrs = sort(unique(ctrs));
    ix = (tm == 10) & ismember(trs, actrs);

    atms = grpstats(ctrs, ctrs, 'numel');
    prgs = grpstats(B.progress(ismember(trs, actrs)), ctrs, 'nanmean');
    
    cv = corr([Y(ix,:) atms prgs]);
    crs1 = cv(end,1:end-2);
    crs2 = cv(end-1,1:end-2);
    plot(crs1);
%     plot(-crs2);
    plot(xlim, [0 0], 'k--');
    ylim([-1 1]);
    xlabel('factor dim');
    ylabel('corr of y_{time=5} with prog/acqtm');
    continue;
    
    plot(actrs, Y(ix,1), '-', 'Color', 0.7*ones(3,1));
    plot(actrs, smooth(Y(ix,1)), 'k-');
    ylim([-10 10]);
    plot([trRngs(2,1) trRngs(2,1)], ylim, 'k--');
    plot([trRngs(2,2) trRngs(2,2)], ylim, 'k--');
end




