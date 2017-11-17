%% load all fits

[S,F] = plot.getScoresAndFits('Int2Pert_yIme');

%% compute avg norm of cloud and observed data, in each group

vnorm = @(y) sqrt(sum(y.^2,2));
grps = tools.thetaCenters;
nrms = nan(numel(F), numel(grps), 2);

dfs = nan(numel(F), 8);
for ii = 1:numel(F)
    f = F(ii);
    s = S(ii);
    
    ix = s.ixGs;
    gs = s.gs(ix);
    y = f.test.latents(ix,:);
    yhat = f.fits(end).latents(ix,:);
    
    inds = f.fits(end).extra_info;
    ytrhat = f.train.latents(inds(ix),:);
    RB = f.test.RB;
    
%     dec = f.dec;
%     y = tools.latentsToSpikes(y, dec, false, true);
%     yhat = tools.latentsToSpikes(yhat, dec, false, true);
    
%     yhat = tools.latentsToSpikes(yhat, dec, false, true);
%     y = f.test.spikes(ix,:);
    
    NB = f.test.NB;
    vfcn = @(y) bsxfun(@plus, y*f.test.M2', f.test.M0');
%     NB = f.test.NB_spikes;
    
    for jj = 1:numel(grps)
        ix = gs == grps(jj);
        nrms(ii,jj,1) = nanmean(vnorm(y(ix,:)*NB));
        nrms(ii,jj,2) = nanmean(vnorm(yhat(ix,:)*NB));
        
        yrn = nanmean(vnorm(vfcn(y(ix,:))));
        yrhn = nanmean(vnorm(vfcn(ytrhat(ix,:))));
        dfs(ii,jj) = yrn - yrhn;
    end
end

%% plot

% each point is direction
% xss = squeeze(nrms(:,:,1)); xss = xss(:);
% yss = squeeze(nrms(:,:,2)); yss = yss(:);
% ylbl = 'directions';

% each point is mean per session
pts = squeeze(nanmean(nrms, 2));
xss = pts(:,1);
yss = pts(:,2);
ylbl = 'sessions';

% plot
plot.init;
subplot(1,2,1); hold on; set(gca, 'FontSize', 16);

% plot scatter
mnks = io.getMonkeys;
for ii = 1:numel(mnks)
    ix = io.getMonkeyDateFilter({F.datestr}, mnks(ii));
    plot(xss(ix), yss(ix), '.', 'MarkerSize', 10);
end
% plot(xss(:), yss(:), 'k.', 'MarkerSize', 10);

pts = [xss yss];
xmn = floor(min(pts(:)));
xmx = ceil(max(pts(:)));
xlim([xmn xmx]); ylim(xlim);
plot(xlim, ylim, 'k-');

set(gca, 'XTick', xmn:5:xmx);
set(gca, 'YTick', xmn:5:xmx);
xlabel('avg. norm of obs. activity');
ylabel('avg. norm of pred. (fixed rep.) activity');

% plot histogram
subplot(1,2,2); hold on; set(gca, 'FontSize', 16);
vs = yss-xss;
bins = linspace(min(vs), max(vs), 21);
cs = histc(vs, bins);
bar(bins, cs, 'FaceColor', 'w');
p = signtest(yss, xss);
text(prctile(bins, 75), prctile(cs, 75), {['median = ', ...
    sprintf('%0.2f', median(vs))], ['     p = ' sprintf('%0.4f', p)]}, ...
    'FontSize', 16);
plot([median(vs) median(vs)], ylim, 'r-', 'LineWidth', 2);
xlabel('difference in avg. norms');
ylabel(['# ' ylbl]);

plot.setPrintSize(gcf, struct('width', 10, 'height', 4));
