%% load all fits

doSave = false;
[S,F] = plot.getScoresAndFits('Int2Pert_yIme');
opts = struct('doSave', doSave, 'saveDir', 'data/plots', ...
    'FontSize', 24, 'ext', 'pdf');

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
plot(xss(:), yss2(:), '.', 'MarkerSize', 30, 'Color', clr2);

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

%%

% plot histogram

vs0 = [pts(:,2) - pts(:,1); pts(:,3) - pts(:,1)];
ymn = min(vs0);
ymx = max(vs0);

plot.init(opts.FontSize);
ps = [];
for jj = 3%2:3
    yss = pts(:,jj);
    clr = clrs(jj-1,:);
    
    vs = yss - xss;        
    bins = linspace(min(vs0), max(vs0), 21);
    cs = histc(vs, bins);
    bar(bins, cs, 'FaceColor', clr, 'EdgeColor', clr);
    median(vs)
    p = signtest(yss, xss);
    ps = [ps p];
%     text(prctile(bins, 75), prctile(cs, 75), {['median = ', ...
%         sprintf('%0.2f', median(vs))], ['     p = ' sprintf('%0.4f', p)]}, ...
%         'FontSize', 16);
    plot([median(vs) median(vs)], [0 18], '-', ...
        'Color', clr, 'LineWidth', 2, 'HandleVisibility', 'off');
end
plot([0 0], [0 18], 'k-', ...
    'LineWidth', 2, 'HandleVisibility', 'off');

nm1 = plot.hypDisplayName('best-mean');
nm2 = plot.hypDisplayName('constant-cloud');
% legend({nm1, nm2}, 'Location', 'NorthWest'); legend boxoff;
xlabel({'Difference in predicted distance', 'from MD firing rate (spikes/s)'});
ylabel(['# Sessions']);
xlim([-60 60]);

tcks = get(gca, 'XTick');
% set(gca, 'XTick', tcks(2:2:end));
set(gca, 'XTick', [-50 0 50]);
set(gca, 'YTick', [0 15]);
set(gca, 'TickLength', [0 0]);
set(gca, 'LineWidth', 2);

plot.setPrintSize(gcf, struct('width', 6, 'height', 4));

opts.filename = 'distFromBaseline_hist';
if opts.doSave
    export_fig(gcf, fullfile(opts.saveDir, ...
        [opts.filename '.' opts.ext]));
end
