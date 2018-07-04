%% load all fits

doSave = true;
runName = '_20180619';
fitName = 'Int2Pert_yIme';
[S,F] = plot.getScoresAndFits([fitName runName]);
saveDir = fullfile('data', 'plots', 'figures', runName);
opts = struct('doSave', doSave, 'saveDir', saveDir, ...
    'FontSize', 17, 'ext', 'pdf');

%%

dtstr = '20160714';
ixd = ismember({F.datestr}, dtstr);
f = F(ixd);
s = S(ixd);

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

set(gca, 'LineWidth', lw);
set(gca, 'TickLength', [0 0]);
set(gca, 'XTick', [0 150]);
set(gca, 'YTick', [0 150]);
xlim([0 150]);
ylim([0 150]);
% axis equal;

xlabel({'Output-null activity, dim. 1', '(spikes/s, rel. to baseline)'});
ylabel({'Output-null activity, dim. 2', '(spikes/s, rel. to baseline)'});

plot.setPrintSize(gcf, struct('width', 5, 'height', 4));
opts.filename = 'distFromBaseline_cart';
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [opts.filename '.' opts.ext]));
end

%% compute avg norm of cloud and observed data, in each group

vnorm = @(y) sqrt(sum(y.^2,2));
grps = tools.thetaCenters;
nrms = nan(numel(F), numel(grps), 3);

distFromZeroSpikes = false;
baseHyp = 'best-mean';

% distFromZeroSpikes = false;
% baseHyp = 'minimum';

dfs = nan(numel(F), 8);
ds = nan(numel(F), 1);
for ii = 1:numel(F)
    f = F(ii);
    s = S(ii);
    
%     sps = f.test.spikes;
%     sps = sps*diag(1./f.dec.spikeCountStd);
%     [~,V] = pca(sps);
%     ds(ii) = sum(var(V(:,1:10)))/sum(var(sps));
%     ds(ii) = sum(var(f.test.latents))/sum(var(sps));
%     continue;
    
    ix = s.ixGs;
    gs = s.gs(ix);
    y = f.test.latents(ix,:);    
    yh1 = f.fits(strcmp({f.fits.name}, baseHyp)).latents(ix,:);
    yh2 = f.fits(strcmp({f.fits.name}, 'constant-cloud')).latents(ix,:);
    
%     f0 = f.fits(strcmp({f.fits.name}, 'best-mean'));
%     mub = f0.extra_info;
    
    RB = f.test.RB;
    NB = f.test.NB;    
    
    if distFromZeroSpikes
        dec = f.dec;
        y = tools.latentsToSpikes(y, dec, false, true);
        yh1 = tools.latentsToSpikes(yh1, dec, false, true);
        yh2 = tools.latentsToSpikes(yh2, dec, false, true);
        NB = f.test.NB_spikes;
    else
        NB = f.test.NB;
        
%         fc = @(yc) yc*(RB*RB') + bsxfun(@minus, yc*NB, mub)*NB';
%         y = fc(y);
%         yh1 = fc(yh1);
%         yh2 = fc(yh2);
    end
    
    y = y*NB;
    yh1 = yh1*NB;
    yh2 = yh2*NB;
    
    % distance from MD or MF prediction
    % (n.b. doing this rather than subtracating mub gives basically same
    % results)
    y = y - yh1;
    yh2 = yh2 - yh1;

    for jj = 1:numel(grps)
        ix = gs == grps(jj);
%         nrms(ii,jj,1) = nanmean(vnorm(y(ix,:)*NB));
%         nrms(ii,jj,2) = nanmean(vnorm(yh1(ix,:)*NB));
%         nrms(ii,jj,3) = nanmean(vnorm(yh2(ix,:)*NB));
        
        nrms(ii,jj,1) = vnorm(nanmean(y(ix,:)));
        nrms(ii,jj,2) = vnorm(nanmean(yh1(ix,:)));
        nrms(ii,jj,3) = vnorm(nanmean(yh2(ix,:)));
        
%         yrn = nanmean(vnorm(vfcn(y(ix,:))));
%         yrhn = nanmean(vnorm(vfcn(ytrhat(ix,:))));
%         dfs(ii,jj) = yrn - yrhn;
    end
end

%% plot

% each point is direction
% xss = squeeze(nrms(:,:,1)); xss = xss(:);
% yss = squeeze(nrms(:,:,2)); yss = yss(:);
% ylbl = 'directions';

% each point is mean per session
pts = squeeze(nanmean(nrms, 2));
pts = (1000/45)*pts; % make spikes/s

xss = pts(:,1);
yss1 = pts(:,2);
yss2 = pts(:,3);

% xss = nrms(:,:,1); xss = xss(:);
% yss2 = nrms(:,:,3); yss2 = yss2(:);
% xss = (1000/45)*xss;
% yss2 = (1000/45)*yss2;
% yss1 = yss2;

ylbl = 'sessions';

% plot
plot.init(opts.FontSize);

% plot scatter
% mnks = io.getMonkeys;
% for ii = 1:numel(mnks)
%     ix = io.getMonkeyDateFilter({F.datestr}, mnks(ii));
%     plot(xss(ix), yss(ix), '.', 'MarkerSize', 10);
% end

clr1 = plot.hypColor('best-mean');
clr2 = plot.hypColor('constant-cloud');
clrs = [clr1; clr2];

pts = [xss yss1 yss2];
xmn = floor(min(pts(:)));
xmn = 0;
xmx = ceil(max(pts(:)));
xlim([xmn xmx]); ylim(xlim);
plot(xlim, ylim, 'k--', 'LineWidth', 2, 'HandleVisibility', 'off');

% plot(xss(:), yss1(:), '.', 'MarkerSize', 30, 'Color', clr1);
plot(xss(:), yss2(:), '.', 'MarkerSize', 30, 'Color', 'k');

xlim([xmn xmx]); ylim(xlim);

set(gca, 'XTick', [xmn xmx]);
set(gca, 'YTick', [xmn xmx]);
xlabel({'Distance of observed activity', 'from MD firing rate (spikes/s)'});
ylabel({'Distance of FD activity', 'from MD firing rate (spikes/s)'});
axis square;
nm1 = plot.hypDisplayName('best-mean');
nm2 = plot.hypDisplayName('constant-cloud');
% legend({nm1, nm2}, 'Location', 'NorthWest'); legend boxoff;
% legend({nm2}, 'Location', 'NorthWest'); legend boxoff;

set(gca, 'LineWidth', 2);
set(gca, 'TickLength', [0 0]);
set(gca, 'XTick', [0 100]);
set(gca, 'YTick', [0 100]);

opts.filename = 'distFromBaseline_scatter';
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [opts.filename '.' opts.ext]));
end
