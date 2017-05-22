%% find errors

% grpNm = 'thetasIme';
% decNm = 'fImeDecoder';
grpNm = 'thetas';
decNm = 'fDecoder';

compareToTrue = true;
useTrueDecoder = false;

dts = io.getDates;
errs = nan(numel(dts), 8);
es = cell(numel(dts), 2);

errs2 = nan(numel(dts), 8);
es2 = cell(numel(dts), 1);

for ii = 1:numel(dts)
    D = io.loadPrepDataByDate(dts{ii});
    [errs(ii,:), es{ii,1}, es{ii,2}, errs2(ii,:), es2{ii}] = ...
        washout.errorImprovement(D, grpNm, decNm, ...
            compareToTrue, useTrueDecoder);
end

%% average error per session

% mask is true in places where washout acq. time is at intuitive levels
%     after throwing out the first 30% of trials
mask = [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 ...
    1 1 0 1 1 1 0 0 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1];
mask = ones(size(mask));
errsc = errs2;
mus = nanmean(errsc,2);
ses = nanstd(errsc,[],2)/sqrt(size(errsc,2));

lw = 2;
plot.init;
% bar(1:numel(dts), mus, 'LineWidth', lw, ...
%     'FaceColor', 'w', 'EdgeColor', 'k');
for ii = 1:size(errsc,1)
    m = mus(ii);
    v = ses(ii);
    if mask(ii)
        clr = 'k';
    else
        clr = [0.8 0.8 0.8];
    end
    bar(ii, mus(ii), 'LineWidth', lw, 'FaceColor', 'w', 'EdgeColor', clr);
    plot([ii ii], [m-v m+v], '-', 'Color', clr, 'LineWidth', lw);
end
xlim([0.5 numel(dts)+0.5]);
plot(xlim, [0 0], 'k--', 'LineWidth', lw);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 90);
set(gca, 'LineWidth', lw);
if useTrueDecoder
    ylabel({'|\theta_{Intuitive}| - |\theta_{Washout}|' , ...
        '(\theta = Angular error through Int.)'});
elseif ~compareToTrue
    ylabel({'|\theta_{Intuitive}| - |\theta_{Washout}|' , ...
        '(\theta = Angular error through WMP)'});
else
    ylabel({'|\theta_{Intuitive}| - |\theta_{Washout}|' , ...
        '(\theta = Angular error between WMP and Int. vels)'});
end
box off;

%% errors per group per session

grps = tools.thetaCenters;

plot.init;
imagesc(errs');
mx = 90;
caxis([-mx mx]);
colormap(cbrewer('div', 'RdBu', 11));
cb = colorbar;
set(cb, 'YTick', -mx:45:mx);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'TickDir', 'out');
set(gca, 'YTick', 1:numel(grps));
set(gca, 'YTickLabel', arrayfun(@num2str, grps, 'uni', 0));
set(gca, 'XTickLabelRotation', 90);
ylim([0 9]);

%% show example

D = io.loadPrepDataByDate('20131205');
d = D.blocks(2).(decNm);
velf = @(Z) ((eye(2) - d.M1)\bsxfun(@plus, d.M2*Z', d.M0))';

Blk = D.blocks(1);
vs1 = velf(Blk.latents);
gs1 = Blk.(grpNm);
es1 = tools.angleDistance(tools.computeAngles(vs1), gs1, false);

Blk = D.blocks(3);
vs3 = velf(Blk.latents);
gs3 = Blk.(grpNm);
es3 = tools.angleDistance(tools.computeAngles(vs3), gs3, false);


