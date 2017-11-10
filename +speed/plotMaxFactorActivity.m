function plotMaxFactorActivity(Ps, Zs, legs, clrs, ttl, lbls, saveDir, vmxc)
% plot range, compared to actual data

    plot.init;
    vmx = 0;
    clrs0 = cbrewer('seq', 'Greens', 3); clrs0 = clrs0(end:-1:1,:);
    for ii = 1:numel(Ps)
        plot(Ps{ii}(:,1), Ps{ii}(:,2), '-', 'LineWidth', 2, ...
            'Color', clrs0(ii,:));
        vmx = max([vmx max(abs(Ps{ii}(:)))]);
    end
    for ii = 1:numel(Zs)
        if ii <= size(clrs,1)
            clr = clrs(ii,:);
        else
            clr = 'none';
        end
        if size(Zs{ii},1) > 1
            bnd = clouds.getBoundary(Zs{ii}(:,1:2));
            plot(bnd.x, bnd.y, '-', 'LineWidth', 2, 'Color', clr);
        else
            plot(Zs{ii}(1), Zs{ii}(2), '+');
        end
        vmx = max([vmx max(abs(Zs{ii}(:)))]);
    end
    if ~isnan(vmxc)
        vmx = vmxc;
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
    axis equal;
    xlim([-vmx vmx]); ylim(xlim);    
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [ttl '.pdf']);
        export_fig(gcf, fnm);
    end

end
