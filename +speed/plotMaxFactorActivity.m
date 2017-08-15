function plotMaxFactorActivity(Ps, Zs, legs, ttl, lbls, saveDir)
% plot range, compared to actual data

    plot.init;
    vmx = 0;
    for ii = 1:numel(Ps)
        plot(Ps{ii}(:,1), Ps{ii}(:,2), '-', 'LineWidth', 2);
        vmx = max([vmx max(abs(Ps{ii}(:)))]);
    end
    for ii = 1:numel(Zs)
        if size(Zs{ii},1) > 1
            bnd = clouds.getBoundary(Zs{ii}(:,1:2));
            plot(bnd.x, bnd.y, '-', 'LineWidth', 2);
        else
            plot(Zs{ii}(1), Zs{ii}(2), '+');
        end
        vmx = max([vmx max(abs(Zs{ii}(:)))]);
    end
    
    plot(0, 0, 'k+');
    legs = [legs 'mean firing'];    

    xlabel(lbls{1});
    ylabel(lbls{2});
    title(ttl);
    legend(legs, 'Location', 'BestOutside');
    legend boxoff;
    
    popts = struct('width', 9, 'height', 6, 'margin', 0.25);
    plot.setPrintSize(gcf, popts);
    xlim([-vmx vmx]); ylim(xlim);
    axis equal;
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [ttl '.pdf']);
        export_fig(gcf, fnm);
    end

end
