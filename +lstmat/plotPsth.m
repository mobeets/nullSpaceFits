
B0 = G.train;
B = G.test;
[Sps0, alltms0, alltrs0] = lstmat.makeSpikeBlock(B0.spikes, ...
    B0.time, B0.trial_index);
trgs0 = grpstats(B0.targetAngle, B0.trial_index, 'mode');

[Sps, alltms, alltrs] = lstmat.makeSpikeBlock(B.spikes, ...
    B.time, B.trial_index);
trgs = grpstats(B.targetAngle, B.trial_index, 'mode');

alltrgs = unique(trgs);

maxtms = 7; % 20

for spInd = 1:20%size(Sps,3)
    fig = plot.init;
    ymx = max(max(Sps(:,:,spInd)));
    for ii = 1:numel(alltrgs)
        subplot(2,4,ii); hold on;        
        if ii == 1
            title([D.datestr ' n' num2str(spInd)]);
        end
        csps = Sps(trgs == alltrgs(ii), alltms <= maxtms, spInd);
        for jj = 1:size(csps,1)
            plot(1:maxtms, csps(jj,:), 'Color', 0.9*ones(3,1));
        end
%         plot([7 7], [0 ymx], '-', 'Color', 0.7*ones(3,1));
        plot(1:maxtms, nanmean(csps,1), 'k-');
        csps = Sps0(trgs0 == alltrgs(ii), alltms0 <= maxtms, spInd);
        plot(1:maxtms, nanmean(csps,1), '-', 'Color', [0.2 0.2 0.8]);
        xlabel('time');
        ylabel('spike count');
        ylim([0 ymx]);
        set(gca, 'TickLength', [0 0]);
    end
    plot.setPrintSize(fig, struct('width', 7, 'height', 3));
end

%%

fig = plot.init;
clrs = cbrewer('seq', 'Reds', 5);
for ii = 1:15
    for jj = 1:7
        spInd = (ii-1)*7 + jj;
        if spInd > size(Sps,3)
            continue;
        end
        ymu = mean(Sps(:,alltms == 1,spInd));
        plot([1 8] + 8.5*(ii-1), [0 0] + 15*(jj-1), '-', ...
            'Color', 0.5*ones(3,1));
        sc = max(max(Sps(:,2:5,spInd))) - ymu;
        for t = 2:5
            csps = Sps(:, alltms == t, spInd) - ymu;
            ys = 20*grpstats(csps, trgs)/sc;
            plot((1:8) + 8.5*(ii-1), ys + 15*(jj-1), 'Color', clrs(t,:));            
        end
    end
end
axis off;
box off;
set(gca, 'TickLength', [0 0]);
plot.setPrintSize(fig, struct('width', 8, 'height', 6));
