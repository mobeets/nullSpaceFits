%% load

D = io.loadPrepDataByDate('20131205');

%%

dts = io.getDates;
grps = tools.thetaCenters;
binds = [1 3];

errs_WMP = nan(numel(dts), numel(binds), numel(grps));
angs_WMP = errs_WMP;

for kk = 1:numel(dts)
    D = io.loadPrepDataByDate(dts{kk});
    for jj = 1:numel(binds)
        bind = binds(jj);
        
        dWMP = D.blocks(2).fImeDecoder;
        velf_WMP = @(Z) (eye(2) - dWMP.M1)\bsxfun(@plus, dWMP.M2*Z', dWMP.M0);

        dOG = D.blocks(bind).fImeDecoder;
        velf_OG = @(Z) (eye(2) - dOG.M1)\bsxfun(@plus, dOG.M2*Z', dOG.M0);

        Z = D.blocks(bind).latents;
        vels_WMP = velf_WMP(Z)';
        vels_OG = velf_OG(Z)';

        gs = round(D.blocks(bind).targetAngle);
        clrs = cbrewer('div', 'RdYlGn', numel(grps));
%         plot.init;

        % get target locations
        trgs = unique([D.blocks(bind).target D.blocks(bind).targetAngle], 'rows');
        [~,ix] = sort(trgs(:,3));
        trgs = trgs(ix,1:2);
        trgs = bsxfun(@minus, trgs, mean(trgs));    

        % plot mean velocity under WMP
        mus_WMP = nan(numel(grps),2);
        mus_OG = nan(numel(grps),2);
        for ii = 1:numel(grps)
            ix = gs == grps(ii);
            clr = clrs(ii,:);
%             plot(trgs(ii,1), trgs(ii,2), ...
%                 'o', 'Color', clr, 'MarkerFaceColor', clr, 'MarkerSize', 20);

            vs_WMP = vels_WMP(ix,:);
            vs_OG = vels_OG(ix,:);
            mus_WMP(ii,:) = nanmean(vs_WMP);
            mus_OG(ii,:) = nanmean(vs_OG);

%             plot(mus_WMP(ii,1), mus_WMP(ii,2), 'ko', ...
%                 'MarkerFaceColor', clr, 'MarkerSize', 10);
%             plot(mus_OG(ii,1), mus_OG(ii,2), 'wo', ...
%                 'MarkerFaceColor', clr, 'MarkerSize', 10);
        end

%         plot(0, 0, 'k+');
%         title(['Block ' num2str(bind)]);
%         vmx = 250;
%         xlim([-vmx vmx]);
%         ylim(xlim);
%         axis square;

        curAngs = tools.computeAngles(mus_WMP);
        angs_trgs = tools.computeAngles(trgs);
        assert(norm(grps - angs_trgs) < 1e-5);
        errs_WMP(kk,jj,:) = tools.angleDistance(curAngs, angs_trgs, true);
        angs_WMP(kk,jj,:) = curAngs;
    end

end
errs = squeeze(diff(errs_WMP, 1, 2));

%%

lw = 2;
plot.init;
% boxplot(-errs');
bar(1:numel(dts), -mean(errs,2), 'LineWidth', lw, ...
    'FaceColor', 'w', 'EdgeColor', 'k');
for ii = 1:size(errs,1)
    m = mean(errs(ii,:));
    v = std(errs(ii,:))/sqrt(size(errs,2));
    plot([ii ii], -[m-v m+v], 'k-', 'LineWidth', lw);
end
xlim([0.5 numel(dts)+0.5]);
plot(xlim, [0 0], 'k--', 'LineWidth', lw);
set(gca, 'XTick', 1:numel(dts));
set(gca, 'XTickLabel', dts);
set(gca, 'XTickLabelRotation', 90);
set(gca, 'LineWidth', lw);
ylabel([{'Improvement in average angular error'}, ...
    {'per target, through WMP'}]);
box off;

%%

plot.init;
for ii = 1:size(errs,1)
    plot(grps, errs(ii,:), 'ko-');
end
set(gca, 'XTick', grps);
set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
