function vss = plotVarOfProjections(projs, blks, trgs)

    plot.init;
    vss = nan(size(projs));
    for jj = 1:size(projs,2)
        subplot(2,4,jj); hold on;
        for ii = 1:size(projs,1)
            for kk = 1:size(projs,3)
                vss(ii,jj,kk) = var(projs{ii,jj,kk});
            end
            vrmu = nanmean(vss(ii,jj,:));
            vrsd = nanstd(vss(ii,jj,:));
            bar(ii, vrmu, 'FaceColor', 'w', ...
                'EdgeColor', blks(ii).clr);
            plot([ii ii], [vrmu-vrsd vrmu+vrsd], '-', ...
                'Color', blks(ii).clr);
        end
        set(gca, 'XTick', 1:numel(blks));
        set(gca, 'XTickLabel', {blks.name});
        set(gca, 'XTickLabelRotation', 45);
        ylabel('variance of projection');
        title(['new dim for angle ' num2str(trgs(jj)) '^\circ']);
    end

    plot.setPrintSize(gcf, struct('width', 9, 'height', 3));
end
