doSave = false;
[S,F] = plot.getScoresAndFits('Int2Pert_yIme');
opts = struct('doSave', doSave, 'saveDir', 'data/plots', ...
    'FontSize', 24, 'ext', 'pdf');

%% plot diagonal entries of \Phi

plot.init;
for ii = 1:numel(F)
    f = F(ii);
    v = f.dec.FactorAnalysisParams.ph;
    vr = f.dec.spikeCountStd';
%     v = v.*vr;
    v = sort(v); v = v(end:-1:1);
    plot(v);
end
xlabel('electrode index, i (sorted by \Phi_{ii})');
ylabel('\Phi_{ii}');
% ylim([0 2]);

%% pairwise correlations of all units

plot.init;
for ii = 1:numel(F)
    f = F(ii);
    sps = f.train.spikes;
    cr = corr(sps);
    cr = triu(cr); cr = cr(cr > 0 & cr < 1);
    
    subplot(7,6,ii); hold on;
    
    xs = linspace(0, 1, 20);
    cs = histc(cr, xs);
    bar(xs, cs);
    xlim([0 1]);
end

%%

dtind = 35;
f = F(dtind);
s = S(dtind);

RB1 = f.train.RB;
NB2 = f.test.NB;
SS0 = (NB2*NB2')*RB1; % when activity became irrelevant
[SSS,~,v] = svd(SS0, 'econ');

MD = f.fits(2);
FD = f.fits(end);
clr2 = plot.hypColor('best-mean');
clr3 = plot.hypColor('constant-cloud');

ix = s.gs == 315;
xs1 = f.test.latents(ix,:)*SSS;
xs2 = MD.latents(ix,:)*SSS;
xs3 = FD.latents(ix,:)*SSS;

% scale to spikes/s
mult = 1000/45;
xs1 = mult*xs1;
xs2 = mult*xs2;
xs3 = mult*xs3;

% flip x-axis
xs1(:,1) = -xs1(:,1);
xs2(:,1) = -xs2(:,1);
xs3(:,1) = -xs3(:,1);

[bp1, mu1, sigma1] = plot.gauss2dcirc(xs1, 1);
[bp2, mu2, sigma2] = plot.gauss2dcirc(xs2, 1);
[bp3, mu3, sigma3] = plot.gauss2dcirc(xs3, 1);

plot.init(opts.FontSize);
msz = 50; lw = 2;

% show scatter
% plot(xs1(:,1), xs1(:,2), 'k.');
% plot(xs2(:,1), xs2(:,2), '.', 'Color', clr2);
% plot(xs3(:,1), xs3(:,2), '.', 'Color', clr3);

% show cov ellipse
plot(bp1(1,:), bp1(2,:), 'k-', 'LineWidth', lw);
plot(bp2(1,:), bp2(2,:), '-', 'Color', clr2, 'LineWidth', lw);
plot(bp3(1,:), bp3(2,:), '-', 'Color', clr3, 'LineWidth', lw);

% show distances computed
lw2 = 4;
plot([mu1(1) mu2(1)], [mu1(2) mu2(2)], 'k--', 'LineWidth', lw2);
plot([mu3(1) mu2(1)], [mu3(2) mu2(2)], '--', 'Color', clr3, 'LineWidth', lw2);

% show mean
plot(mu1(1), mu1(2), 'k.', 'MarkerSize', msz);
plot(mu2(1), mu2(2), '.', 'Color', clr2, 'MarkerSize', msz);
plot(mu3(1), mu3(2), '.', 'Color', clr3, 'MarkerSize', msz);

v1 = (MD.extra_info*NB2')*SSS;
v1 = mult*v1;
plot(v1(1), v1(2), 'g.', 'MarkerSize', msz);

set(gca, 'LineWidth', lw);
set(gca, 'TickLength', [0 0]);
set(gca, 'XTick', [0 120]);
set(gca, 'YTick', [0 100]);
xlim([0 140]);
ylim([0 110]);
% axis equal;

xlabel({'Activity, dim. 1', 'spikes/s, rel. to baseline'});
ylabel({'Activity, dim. 2', 'spikes/s, rel. to baseline'});

%%
plot.setPrintSize(gcf, struct('width', 5, 'height', 4));
opts.filename = 'distFromBaseline_cart';
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [opts.filename '.' opts.ext]));
end
