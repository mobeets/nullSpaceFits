function ys = plotBlockErrors(stats, dtstr, binds)
    if nargin < 3
        binds = 1:size(stats,2);
    end

    plot.init;
    ys = cell(max(binds),3);
    for ii = binds
        b1 = stats{1,ii};
        b2 = stats{2,ii};

        b1c = b1.cErrs;
        b2c = b2.cErrs;
        b1m = b1.mdlErrs;
        b2m = b2.mdlErrs;

        % get trial indices
        is1 = b1.by_trial.trial_inds;
        is2 = b2.by_trial.trial_inds;
        ts1 = b1.trial_inds;
        ts2 = b2.trial_inds;
        xs1 = ts1(is1);
        xs2 = ts2(is2);

        lw = 2;
        clr1 = [0.8 0.2 0.2];
        clr2 = [0.2 0.2 0.8];    
        k1 = round(numel(b1c)*0.1);
        k2 = round(numel(b2c)*0.1);
        k1 = 30;
        k2 = 30;
        
        b1c = grpstats(abs(b1c), xs1);
        b1m = grpstats(abs(b1m), xs1);
        b2m = grpstats(abs(b2m), xs2);
        xs1 = unique(xs1);
        xs2 = unique(xs2);

        ys1 = smooth(abs(b1c), k1);
        ys2 = smooth(abs(b1m), k1);
        ys3 = smooth(abs(b2m), k2);
        plot(xs1, ys1, 'Color', 'k', 'LineWidth', lw);
        plot(xs1, ys2, 'Color', clr1, 'LineWidth', lw);
        plot(xs2, ys3, 'Color', clr2, 'LineWidth', lw);
        plot([max(xs1)+1 max(xs1)+1], ylim, 'k--');
        
        ys{ii,1} = ys1;
        ys{ii,2} = ys2;
        ys{ii,3} = ys3;
    end
    
    legend({'cursor', 'Int. IME', 'Pert. IME'});
    xlabel('Trial #');
    ylabel('Absolute angular error (deg)');
    title(dtstr);
end
