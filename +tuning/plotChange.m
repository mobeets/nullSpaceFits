



%%
% F.train.thetaGrps = tools.thetaGroup(F.train.thetas, tools.thetaCenters);
% F.test.thetaGrps = tools.thetaGroup(F.test.thetas, tools.thetaCenters);

%%

grpName = 'thetaActualImeGrps';
% grpName = 'thetaGrps';

hypNm = 'habitual-corrected';
% hypNm = 'constant-cloud';
hypInd = strcmp({F.fits.name}, hypNm);
dispNm = strsplit(F.fits(hypInd).name, '-'); dispNm = dispNm{1};

[~,~,vtr] = svd(F.train.latents(~any(isnan(Y),2),:)*F.train.NB, 'econ');
[~,~,vte] = svd(F.test.latents(~any(isnan(Y),2),:)*F.test.NB, 'econ');
% [~,~,vr] = svd(cov(rand(1000,2)), 'econ');
vr = eye(2);

[muTr, grps] = tuning.getTuning(F.train.latents, F.train.(grpName), ...
    F.train.NB*vtr, F.train.RB);
[muTrTe, ~] = tuning.getTuning(F.train.latents, F.train.(grpName), ...
    F.test.NB*vte, F.test.RB*vr);
[muTe, ~] = tuning.getTuning(F.test.latents, F.test.(grpName), ...
    F.test.NB*vte, F.test.RB*vr);
[muCl, ~] = tuning.getTuning(F.fits(hypInd).latents, F.test.(grpName), ...
    F.test.NB*vte, F.test.RB*vr);

% [muTr, grps] = tuning.getTuning(F.train.latents, F.train.(grpName));
% [muTrTe, ~] = tuning.getTuning(F.train.latents, F.train.(grpName));
% [muTe, ~] = tuning.getTuning(F.test.latents, F.test.(grpName));
% [muCl, ~] = tuning.getTuning(F.fits(hypInd).latents, F.test.(grpName));

vals = [muTr muTe muCl muTrTe];
ymn = floor(min(min(vals)));
ymx = ceil(max(max(vals)));

vals = [muCl-muTe muTrTe-muTe];
ymn2 = floor(min(min(vals)));
ymx2 = ceil(max(max(vals)));

cm = cbrewer('div', 'RdGy', 19);
nrows = 2; ncols = 4;
plot.init;

subplot(nrows,ncols,1); hold on;
imagesc(muTe); axis off; colormap(cm); caxis([ymn ymx]);
title({'Post-learn tuning', '(Pert)'});

subplot(nrows,ncols,2); hold on;
imagesc(muTr); axis off; colormap(cm); caxis([ymn ymx]);
title({'Original tuning', '(IntInInt)'});

subplot(nrows,ncols,3); hold on;
imagesc(muCl); axis off; colormap(cm); caxis([ymn ymx]);
title([dispNm 'tuning']);

subplot(nrows,ncols,4); hold on;
imagesc(muTrTe); axis off; colormap(cm); caxis([ymn ymx]);
title('IntInPert');

% subplot(nrows,ncols,6); hold on;
% imagesc(muTe - muTr); axis off; colormap(cm); caxis([ymn2 ymx2]);
% title({'Tuning change', '(Pert - IntInInt)'});

subplot(nrows,ncols,7); hold on;
imagesc(muCl - muTe); axis off; colormap(cm); caxis([ymn2 ymx2]);
title({[dispNm ' tuning change error'], ['(' dispNm ' - Pert)']});

subplot(nrows,ncols,8); hold on;
imagesc(muTrTe - muTe); axis off; colormap(cm); caxis([ymn2 ymx2]);
title({'Tuning change', '(IntInPert - Pert)'});

%%

% [~, Fs] = plot.getScoresAndFits('Int2Pert_yIme');
[~, Fs] = plot.getScoresAndFits('Int2Pert_nIme');

%%

grpName = 'thetaActualImeGrps';
% grpName = 'thetaGrps';
grpName = 'potentAngle';

% hypNm = 'habitual-corrected';
hypNm = 'constant-cloud';

pds = nan(numel(Fs), 10, 3);
errs = nan(numel(Fs), 10, 2);
ths = nan(numel(Fs), 10, 3, 3);

doSave = true;
doPlot = true;
doPca = true;

popts = struct('width', 7, 'height', 5, 'margin', 0.125, ...
    'doSave', doSave, 'saveDir', 'data/plots/tuning_tmp2_noIme', ...
    'ext', 'pdf');

if popts.doSave && ~exist(popts.saveDir, 'dir')
    mkdir(popts.saveDir);
end

for jj = 1:numel(Fs)
    F = Fs(jj);
    F.train.thetaGrps = tools.thetaGroup(F.train.thetas, tools.thetaCenters);
    F.test.thetaGrps = tools.thetaGroup(F.test.thetas, tools.thetaCenters);

    hypInd = strcmp({F.fits.name}, hypNm);
    dispNm = plot.hypDisplayName(hypNm, true);
    
%     gs1 = F.train.(grpName);
%     gs2 = F.test.(grpName);
    NB1 = F.train.NB;
    RB1 = F.train.RB;
    NB2 = F.test.NB;
    RB2 = F.test.RB;
    Y1 = F.train.latents;
    Y2 = F.test.latents;
%     Yh = F.fits(hypInd).latents; gsh = gs2;
    Yh = F.train.latents;
    
%     G = F; G.test.latents = G.train.latents;
%     Yh = closestRowValFitTmp(G.train, G.test, 1, struct('kNN', 200));    
    
%     RB = RB1; NB = NB1;
    RB = RB2; NB = NB2;
    gs1 = tools.thetaGroup(tools.computeAngles(Y1*RB1), ...
        tools.thetaCenters);
    gs2 = tools.thetaGroup(tools.computeAngles(Y2*RB2), ...
        tools.thetaCenters);
    gsh = tools.thetaGroup(tools.computeAngles(Yh*RB2), ...
        tools.thetaCenters);
    
    if doPca
%         [~,~,v1] = svd(Y1(~any(isnan(Y1),2),:)*NB, 'econ'); NB = NB*v1;
        [~,~,v2] = svd(Y2(~any(isnan(Y2),2),:)*NB, 'econ'); NB = NB*v2;
    end

    grps = tools.thetaCenters;
    mu1 = tuning.getTuning(Y1, gs1, NB, RB, grps);
    mu2 = tuning.getTuning(Y2, gs2, NB, RB, grps);
    muh = tuning.getTuning(Yh, gsh, NB, RB, grps);
    
%     inds = F.fits(hypInd).extra_info;
%     Yh2 = Y1(inds,:)*(RB2*RB2') + Yh*(NB2*NB2');
%     [muh2, grps] = tuning.getTuning(Yh2, gs2, NB2, RB2);
%     mu1 = muh2;

    vs = [mu1 mu2 muh]; vs = abs(vs(:));
    ymx = ceil(max(vs)); ymn = -ymx;

    [~, pd1] = max(mu1); pd1 = grps(pd1);
    [~, pd2] = max(mu2); pd2 = grps(pd2);
    [~, pdh] = max(muh); pdh = grps(pdh);
    
    nd = size(mu2,2);
    for ii = 1:nd
        th1 = tuning.cosFit(grps, mu1(:,ii));
        th2 = tuning.cosFit(grps, mu2(:,ii));
        thh = tuning.cosFit(grps, muh(:,ii));
        ths(jj,ii,1,:) = th1;
        ths(jj,ii,2,:) = th2;
        ths(jj,ii,3,:) = thh;
        
        pd1(ii) = th1(2);
        pd2(ii) = th2(2);
        pdh(ii) = thh(2);
    end

    ignoreSign = false;
    pd1a = tools.angleDistance(pd1, pd2, ignoreSign);
    pd1e = 1-cosd(pd1a);
    pd1e = sign(pd1a).*pd1e;
    
    pdha = tools.angleDistance(pdh, pd2, ignoreSign);
    pdhe = 1-cosd(pdha);
    pdhe = sign(pdha).*pdhe;
    
    pds(jj,:,1) = pd1;
    pds(jj,:,2) = pdh;
    pds(jj,:,3) = pd2;    
    errs(jj,:,1) = pd1e;
    errs(jj,:,2) = pdhe;
    
    if ~doPlot
        continue;
    end
    
    lw = 2;
    msz = 20;
    clrs = [0 0 0; plot.hypColor(hypNm)];
    nrows = 3; ncols = 4;
    plot.init;
    dimnms = {};
    for ii = 1:nd        
        subplot(nrows, ncols, ii); hold on;
        if ii == 1
            xlabel(['\theta (' grpName ')']);
            ylabel('mean activity (sps/timestep)');
        end        
        plot(grps, mu1(:,ii), '--', 'LineWidth', lw, 'Color', clrs(1,:));
        plot(grps, mu2(:,ii), '-', 'LineWidth', lw, 'Color', clrs(1,:));
        plot(grps, muh(:,ii), '-', 'LineWidth', lw, 'Color', clrs(2,:));
        plot(xlim, [0 0], 'k--');

        plot(pd1(ii), ymn, 'o', 'Color', clrs(1,:), 'LineWidth', lw, 'MarkerSize', 6);
        plot(pd2(ii), ymn, '.', 'Color', clrs(1,:), 'LineWidth', lw, 'MarkerSize', msz);
        plot(pdh(ii), ymn, 'o', 'Color', clrs(2,:), 'LineWidth', lw, 'MarkerSize', 6);

        set(gca, 'XTick', grps);
        set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
        set(gca, 'XTickLabelRotation', 45);
        ylim([ymn ymx]);
        
        if ii <= 2
            title(['row dim #' num2str(ii)]);
            dimnms = [dimnms ['R' num2str(ii)]];
        else
            title(['null dim #' num2str(ii-2)]);
            dimnms = [dimnms ['N' num2str(ii-2)]];
        end
    end

    subplot(nrows, ncols, ii+1); hold on;
    plot(1:nd, pd1e, '--', 'LineWidth', lw,'Color', clrs(1,:));
    % plot(1:nd, pd2, '--', 'LineWidth', lw, 'Color', clrs(1,:));
    plot(1:nd, pdhe, '-', 'LineWidth', lw, 'Color', clrs(2,:));
    set(gca, 'XTick', 1:nd);
%     set(gca, 'XTickLabel', arrayfun(@num2str, 1:nd, 'uni', 0));
    set(gca, 'XTickLabel', dimnms);
    set(gca, 'XTickLabelRotation', 90);
    % set(gca, 'YTick', grps);
    % set(gca, 'YTickLabel', arrayfun(@num2str, grps, 'uni', 0));
    xlabel('dim #');
    ylabel('signed cosine distance');
    ylim([-2.1 2.1]);
    title('distance from pert. p.d.');
    
    popts.filename = F.datestr;
    plot.setPrintSize(gcf, popts);
    if popts.doSave
        export_fig(gcf, fullfile(popts.saveDir, ...
            [popts.filename '.' popts.ext]));
    end
    
    subplot(nrows, ncols, ii+2); hold on;
    plot(0,0, '--', 'LineWidth', lw, 'Color', clrs(1,:));
    plot(0,0, '-', 'LineWidth', lw, 'Color', clrs(1,:));
    plot(0,0, '-', 'LineWidth', lw, 'Color', clrs(2,:));
    legend({'intuitive data', 'perturbation data', 'cloud prediction'});
    axis off;
end

dts = {Fs.datestr};
if popts.doSave
    save(fullfile(popts.saveDir, 'pds.mat'), 'pds', 'errs', 'ths', 'dts');
end

% now summarize errors

%%

% errs = d.errs;
errs1 = errs(:,3:10,1);
errsh = errs(:,3:10,2);

es = errs(~isnan(errs));
bins = unique(es(:));
bins = linspace(-2,2,50);
e1 = histc(errs1(:), bins); e1 = e1./sum(e1);
eh = histc(errsh(:), bins); eh = eh./sum(eh);

plot.init;
bar(bins, e1, 'FaceColor', 'w', 'EdgeColor', clrs(1,:));
bar(bins, -eh, 'FaceColor', 'w', 'EdgeColor', clrs(2,:));
xlabel('cosine distance from perturbation p.d.');
ylabel('frequency (all sessions, all null dimensions)');
legend({'intuitive', 'cloud'});
% xlim([-0.1 2]);
% ylim([-1 1]);

popts.filename = 'summary';
plot.setPrintSize(gcf, popts);
if popts.doSave
    export_fig(gcf, fullfile(popts.saveDir, ...
        [popts.filename '.' popts.ext]));
end

%%

% d = load('data/plots/tuning_wIme_PCA/pds.mat');
d = load('data/plots/tuning_rsAng1vs2_noIme/pds.mat');
pds = d.pds;
[ns,nd,~] = size(pds);

% pds(jj,:,1) = pd1;
% pds(jj,:,2) = pdh;
% pds(jj,:,3) = pd2;
ignoreSign = false;
numNulDims = 2;
useRowDims = true;

startDim = 3 - 2*useRowDims;
ds1 = tools.angleDistance(pds(:,startDim:3+numNulDims-1,1), ...
    pds(:,startDim:3+numNulDims-1,3), ignoreSign); % pd1 - pd2
ds2 = tools.angleDistance(pds(:,startDim:3+numNulDims-1,1), ...
    pds(:,startDim:3+numNulDims-1,2), ignoreSign); % pd1 - pdh
ds3 = tools.angleDistance(pds(:,startDim:3+numNulDims-1,2), ...
    pds(:,startDim:3+numNulDims-1,3), ignoreSign); % pdh - pd2
% ds3 = log(ds2./ds1);

'Actual tuning changes:'
[min(ds1); max(ds1)]

vMn = -180;
vMx = 180;
% vMn = -45; vMx = 45;
% close all;

cm = cbrewer('div', 'RdBu', 25);

% plot.init;
% % subplot(1,3,1); hold on;
% imagesc(ds1);
% caxis([vMn vMx]);
% colormap(cm);
% % axis off;
% cbh = colorbar;
% set(cbh, 'YTick', vMn:45:vMx);
% title('change in p.d. (actual)');
% xlabel('dim #');
% ylabel('session #');
% set(gca, 'XTick', []);
% set(gca, 'YTick', []);
% 
% % subplot(1,3,2); hold on;
% plot.init;
% imagesc(ds2);
% caxis([vMn vMx]);
% colormap(cm);
% axis off;
% cbh = colorbar;
% set(cbh, 'YTick', vMn:45:vMx);
% title('change in p.d. (predicted by cloud)');
% 
% % subplot(1,3,3); hold on;
% plot.init;
% imagesc(ds3);
% caxis([vMn vMx]);
% colormap(cm);
% axis off;
% cbh = colorbar;
% set(cbh, 'YTick', vMn:45:vMx);
% title('error in predicted p.d. change');

plot.init;
for ii = 1:size(ds1,2)
    plot(ds1(:,ii), ds2(:,ii), '.');
end
% gsc = 0:45:180;
gsc = vMn:45:vMx;
set(gca, 'XTick', gsc);
set(gca, 'XTickLabel', arrayfun(@num2str, gsc, 'uni', 0));
set(gca, 'XTickLabelRotation', 45);
set(gca, 'YTick', gsc);
set(gca, 'YTickLabel', arrayfun(@num2str, gsc, 'uni', 0));
set(gca, 'YTickLabelRotation', 0);
xlim([vMn vMx]); ylim(xlim);
plot(xlim, ylim, 'k--');
xlabel('actual change in p.d.');
ylabel('predicted change in p.d. (by cloud)');

%%

d1 = load('data/plots/tuning_wIme_PCA/pds.mat');
d2 = load('data/plots/tuning_noIme_PCA/pds.mat');
ths1 = d1.ths;
ths2 = d2.ths;
[ns nd nh ~] = size(ths1);

doIme = false;
doPert = true;

if doPert
    blkStr = 'perturbation';
    blkInd = 2;
else
    blkStr = 'intuitive';
    blkInd = 1;
end

modDepths1 = squeeze(ths1(:,:,blkInd,1));
modDepths2 = squeeze(ths2(:,:,blkInd,1));

if doIme
    imeStr = 'with';
    modDepths = modDepths1;
else
    imeStr = 'no';
    modDepths = modDepths2;
end

% modDepths = tools.angleDistance(modDepths1, modDepths2, true);

vMx = ceil(max(abs(modDepths(:))));
% vMx = 8;
vMn = 0;
vStep = 2;
cm = cbrewer('seq', 'Oranges', 2*vMx);

% vStep = 45;
% vMn = -vMx;
% cm = cbrewer('div', 'RdBu', 2*vMx);

plot.init;
imagesc(modDepths);
caxis([vMn vMx]);
colormap(cm);
cbh = colorbar;
set(cbh, 'YTick', vMn:vStep:vMx);
xlabel('dim #');
ylabel('session #');
set(gca, 'XTick', 1:numel(dimnms));
set(gca, 'XTickLabel', dimnms);
set(gca, 'YTick', []);
title(['modulation depth (' blkStr ', ' imeStr ' IME)']);

