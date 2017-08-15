function fig = plotMaxProgress(vels, vmx, newFig, gain)
    if nargin < 2
        vmx = nan;
    end
    if nargin < 3
        newFig = true;
    end
    if nargin < 4
        gain = nan;
    end
    if newFig
        fig = figure;
        set(fig, 'color', 'w');        
        set(fig, 'PaperPositionMode', 'auto');
        set(gca, 'FontSize', 18);
        hold on;
    end
    if isnan(gain)
        gain = 45/1000;
    end
    
    plot(gain*vels(:,1), gain*vels(:,2), 'k.-');
    plot(0, 0, 'k+');
    if isnan(vmx)
        vmx = 1.1*ceil(max(abs(gain*vels(:))));
    end
    xlim([-vmx vmx]);
    ylim([-vmx vmx]);
    xlabel('v_x mm/timestep');
    ylabel('v_y mm/timestep');
    axis square;
end
