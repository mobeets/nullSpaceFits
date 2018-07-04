
runName = '_20180619';
fitName = 'Int2Pert_yIme';
[Ss,Fs] = plot.getScoresAndFits([fitName runName]);
dts = {Fs.datestr};

%%

K = 5;
nboots = 100;
grpNm = 'thetaActualImeGrps';

Ds = nan(numel(Fs), numel(Fs(1).fits)+1);
ns = nan(numel(Fs), 1);
for ii = 1:numel(Fs)
    F = Fs(ii);
    disp([num2str(ii) ' of ' num2str(numel(Fs))]);
    gs1 = F.train.(grpNm);
    gs2 = F.test.(grpNm);
    
    N = min([grpstats(gs1, gs1, @numel); grpstats(gs2, gs2, @numel)]);
    ns(ii) = N;
    if N <= 1
        continue;
    end
    
%     ix1 = ~isnan(gs1); ix2 = ~isnan(gs2); nboots = 1;
    Dsc = nan(nboots, 7);
    for kk = 1:nboots
        [ix1, ix2] = tools.sampleEqualNumbersPerGroup(gs1, gs2, N);
        Dsc(kk,end) = nanmean(tools.computeDomainChange(...
            F.train.latents(ix1,:)', F.test.latents(ix2,:)', K));
        for jj = 1:numel(F.fits)
            Dsc(kk,jj) = nanmean(tools.computeDomainChange(...
                F.train.latents(ix1,:)', F.fits(jj).latents(ix2,:)', K));
        end
        Ds(ii,:) = nanmean(Dsc);
    end
    
end

%%

mnks = io.getMonkeys;
dts = {Fs.datestr};
lw = 2;
plot.init;
for jj = 1:3
    subplot(1,3,jj); hold on; set(gca, 'FontSize', 14);
    
    ixm = io.getMonkeyDateFilter(dts, mnks(jj));
    ds = Ds(ixm,:);

    mus = nanmean(ds);
    ses = nanstd(ds)./sqrt(sum(~isnan(ds)));
%     h = boxplot(ds, 'Outlier', '');
    
    hypnms = [{F.fits.name} 'data'];
    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, false), ...
        hypnms, 'uni', 0);
    clrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');
    bp = boxplot(ds, 'Colors', clrs, ...
        'Symbol', '', 'OutlierSize', 8, 'widths', 0.7);

    % hide horizontal part of error bars
    h = findobj(gcf,'tag','Upper Adjacent Value');
    for kk = 1:numel(h)
        h(kk).Color = 'None';
    end
    h = findobj(gcf,'tag','Lower Adjacent Value');
    for kk = 1:numel(h)
        h(kk).Color = 'None';
    end
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
    set(bp, 'LineWidth', lw);
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
    
    plot(xlim, [0 0], 'k-');
%     bar(1:numel(mus), mus, 'FaceColor', 'none', 'EdgeColor', 'k');
%     for ii = 1:numel(mus)
%         plot([ii ii], [mus(ii)-ses(ii) mus(ii)+ses(ii)], 'k-');
%     end
    
    set(gca, 'LineWidth', lw);
    set(gca, 'XTick', 1:numel(mus));
    set(gca, 'XTickLabel', hypDispNms);
    set(gca, 'XTickLabelRotation', 45);
    box(gca, 'off');
    set(gca, 'TickLength', [0 0]);
    title(mnks{jj});
    ylim([-0.5 4.5]);
    set(gca, 'YTick', 0:2:4);
%     ylim([-0.5 1]); set(gca, 'YTick', 0:1);
    ylabel({'Repertoire change', '(normalized)'});
end

plot.setPrintSize(gcf, struct('width', 9, 'height', 3.5));
