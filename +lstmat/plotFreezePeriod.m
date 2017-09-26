
% [G,F,D] = lstmat.loadCleanSession('20131205', true);
B = G.test;
Bc = D.blocks(2);
tr0 = 150;
[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(Bc, tr0, ...
    'progress', @max, 5, inf);
tr1 = trL1; tr2 = trL2;
% tr1 = min(ts); tr2 = tr1 + tr0;
% tr1 = 0; tr2 = inf;

trgs = round(tools.computeAngles(bsxfun(@minus, ...
    B.target, mean(unique(B.target, 'rows')))));
alltrgs = sort(unique(trgs));
ntrgs = numel(alltrgs);
clrs = cbrewer('div', 'RdYlGn', ntrgs);
tmx = 20;
ymx = 150;

cvel = @(y) bsxfun(@plus, B.M2*y, B.M0);

ixt = (B.trial_index >= tr1) & (B.trial_index <= tr2);
ixt = ixt & B.isCorrect;
plot.init;
for jj = 1:ntrgs
    ix = (trgs == alltrgs(jj)) & ixt;
    cts = B.time(ix);
    acts = sort(unique(cts));
    yms = grpstats(B.latents(ix,:), B.time(ix));
    ps = cvel(yms');
    
    subplot(2,1,1); hold on;
    plot(acts, ps(1,:), '.-', 'Color', clrs(jj,:));
    if jj == 1
        set(gca, 'FontSize', 16);
        xlabel('time step (45 ms)');
        ylabel('cursor x velocity');
        xlim([0 tmx]);
        ylim([-ymx ymx]);
    end
    subplot(2,1,2); hold on;
    plot(acts, ps(2,:), '.-', 'Color', clrs(jj,:));
    if jj == 1
        set(gca, 'FontSize', 16);
        xlabel('time step (45 ms)');
        ylabel('cursor y velocity');
        xlim([0 tmx]);
        ylim([-ymx ymx]);
    end
end
