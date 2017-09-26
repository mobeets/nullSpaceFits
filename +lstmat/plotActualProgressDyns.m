
B0 = G.train;
B = G.test;
Bc = D.blocks(2);

tr0 = 56;
[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(Bc, tr0, ...
    'progress', @max, 5, inf);
trRngs = [min(ts) min(ts) + tr0; trL1 trL2];
ixtE = (B.trial_index >= trRngs(1,1)) & (B.trial_index <= trRngs(1,2));
ixtL = (B.trial_index >= trRngs(2,1)) & (B.trial_index <= trRngs(2,2));

% note that this doesn't account for v_{t-1}
velIntFcn = @(y) bsxfun(@plus, B0.M2*y, B0.M0);
velPertFcn = @(y) bsxfun(@plus, B.M2*y, B.M0);

ndecs = 2;
nblks = 3;
ntms = 20;
prg = cell(ndecs, nblks);
avgPrg = nan(ndecs, nblks, ntms, 8);
for ii = 1:ndecs
    if ii == 1
        velFcn = velIntFcn;
    else
        velFcn = velPertFcn;
    end
    for jj = 1:nblks
        if jj == 1
            cB = B0;
            ix = true(size(cB.trial_index));
        elseif jj == 2
            cB = B;
            ix = ixtE;
        else
            cB = B;
            ix = ixtL;
        end
        prg{ii,jj} = lstmat.getProgress(cB.latents(ix,:), cB.pos(ix,:), ...
            cB.target(ix,:), velFcn);
        
        gs = [cB.targetAngle(ix,:) cB.time(ix,:)];
        ixc = cB.time(ix,:) <= ntms;
        gsa = unique(gs(ixc,:), 'rows');
        aprg = grpstats(prg{ii,jj}(ixc), gs(ixc,:));
        avgPrg(ii,jj,:,:) = reshape(aprg, ntms, []);
    end
end

%% plot average progress timecourse per target

% 
% ttl = D.datestr;
% clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];
% ymn = min(avgPrg(:));
% ymx = max(avgPrg(:));
% blkNms = {'intuitive trials', ...
%     ['perturbation (first ' num2str(tr0) ' trials)'], ...
%     ['perturbation (best ' num2str(tr0) ' trials)']};
% 
% c = 0;
% fig = plot.init;
% for ii = 1:nblks
%     for jj = 1:ntrgs
%         c = c + 1;
%         subplot(nblks, ntrgs, c); hold on;
%         plot([3 3], [ymn ymx], 'Color', 0.8*ones(3,1), ...
%             'HandleVisibility', 'off');
%         plot([7 7], [ymn ymx], 'Color', 0.8*ones(3,1), ...
%             'HandleVisibility', 'off');
%         plot([1 ntms], [0 0], 'Color', 0.8*ones(3,1), ...
%             'HandleVisibility', 'off');
%         for kk = 1:ndecs
%             lw = 1;
%             if ((kk == 1) && (ii == 1)) || ((kk == 2) && (ii > 1))
%                 lw = 2;
%             end
%             xs = 1:ntms;
%             ys = squeeze(avgPrg(kk,ii,:,jj));
%             plot(xs, ys, 'LineWidth', lw, 'Color', clrs(kk,:));
%         end
%         xlabel('time');
%         ylabel('progress');
%         ylim([ymn ymx]);
%         box off;
%         if (ii == 1) && (jj == 1)
%             title([D.datestr ': ' blkNms{ii}]);
%         elseif jj == 1
%             title(blkNms{ii});
%         end
%     end
% end
% plot.setPrintSize(fig, struct('width', 10, 'height', 4));
% if ~isempty(saveDir)
%     export_fig(fig, fullfile(saveDir, ['full_trial_' ttl '.pdf']));
% end

%% plot average progress timecourse, averaged across targets

ttl = D.datestr;
clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];
ymn = min(avgPrg(:));
ymx = max(avgPrg(:));
blkNms = {'intuitive trials', ...
    ['perturbation (first ' num2str(tr0) ' trials)'], ...
    ['perturbation (best ' num2str(tr0) ' trials)']};

vs = avgPrg;
vs = mean(vs, 4);
ntrgs = size(vs,4);

c = 0;
fig = plot.init;
for ii = 1:nblks
    for jj = 1:ntrgs
        c = c + 1;
        subplot(ntrgs, nblks, c); hold on;
        plot([3 3], [ymn ymx], 'Color', 0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        plot([7 7], [ymn ymx], 'Color', 0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        plot([1 ntms], [0 0], 'Color', 0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        for kk = 1:ndecs
            lw = 1;
            if ((kk == 1) && (ii == 1)) || ((kk == 2) && (ii > 1))
                lw = 2;
            end
            xs = 1:ntms;
            ys = squeeze(vs(kk,ii,:,jj));
            plot(xs, ys, 'LineWidth', lw, 'Color', clrs(kk,:));
        end
        xlabel('time');
        ylabel('progress');
        ylim([ymn ymx]);
        box off;
        if (ii == 1) && (jj == 1)
            title([D.datestr ': ' blkNms{ii}]);
        elseif jj == 1
            title(blkNms{ii});
        end
    end
end
plot.setPrintSize(fig, struct('width', 9, 'height', 2.5));
if ~isempty(saveDir)
    export_fig(fig, fullfile(saveDir, ['avg_full_trial_' ttl '.pdf']));
end
