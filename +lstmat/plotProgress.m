function plotProgress(vs, clrs, ylm, lwfcn)

    plot([3 3], ylm, 'Color', 0.8*ones(3,1), ...
        'HandleVisibility', 'off');
    plot([7 7], ylm, 'Color', 0.8*ones(3,1), ...
        'HandleVisibility', 'off');
    plot([1 size(vs,2)], [0 0], 'Color', 0.8*ones(3,1), ...
        'HandleVisibility', 'off');
    for kk = 1:size(vs,1)
        lw = lwfcn(kk);
        ys = vs(kk,:);
        xs = 1:numel(ys);
        plot(xs, ys, 'LineWidth', lw, 'Color', clrs(kk,:));
    end
    set(gca, 'TickDir', 'out');
    xlabel('time');
    ylabel('progress');
    ylim(ylm);
    box off;
end
