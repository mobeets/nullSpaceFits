function plotProjections(projs, blks, trgs)

    % find bins for histograms
    vmn = inf; vmx = -inf;
    for ii = 1:numel(trgs)
        for jj = 1:numel(blks)
            vmn = min(vmn, prctile(projs{jj,ii}, 5));
            vmx = max(vmx, prctile(projs{jj,ii}, 95));
        end
    end    
    bins = linspace(vmn, vmx);
    
    % plot histograms
    plot.init;
    for ii = 1:numel(trgs)
        subplot(2,4,ii); hold on;
        for jj = 1:numel(blks)
            cs = histc(projs{jj,ii,1}, bins);
            cs = cs/sum(cs);
            plot(bins, smooth(cs, 5), 'Color', blks(jj).clr);
        end
        xlim([vmn vmx]);
        xlabel('projection onto new dim');
        ylabel('normalized frequency');
        title(['new dim for angle ' num2str(trgs(ii)) '^\circ']);
    end
    plot.setPrintSize(gcf, struct('width', 9, 'height', 3));
end
