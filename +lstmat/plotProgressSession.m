
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
% nblks = 3;
nblks = 2;
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
%         elseif jj == 2
%             cB = B;
%             ix = ixtE;
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
            
clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];

vss = mean(avgPrg, 4);
ntrgs = size(vss,4);
nblks = size(vss,2);
fnm = ['avg_full_trial_' D.datestr];

ylm = [min(vss(:)) max(vss(:))];

c = 0;
fig = plot.init;
for ii = 1:nblks
    for jj = 1:ntrgs
        lwfcn = @(kk) ii;
        vs = squeeze(vss(:,ii,:,jj));
        lstmat.plotProgress(vs, clrs, ylm, lwfcn);
        title(D.datestr);
    end
end
legend({'int (intDec)', 'int (pertDec)', 'best-pert (intDec)', ...
    'best-pert (pertDec)'}, 'Location', 'BestOutside');
legend boxoff;
plot.setPrintSize(fig, struct('width', 7, 'height', 3));
if ~isempty(saveDir)
    export_fig(fig, fullfile(saveDir, [fnm '.pdf']));
end

%% plot average progress timecourse per monkey

mnkNm = 'Jeffy';
fnm = mnkNm;
ix = io.getMonkeyDateFilter(dts, {mnkNm}) & ~cellfun(@isempty, Cangs);
vss = cell2mat(cellfun(@(d) permute(d, [4 1 2 3]), Cangs(ix), 'uni', 0));
vss = squeeze(mean(vss, 1));
nblks = size(vss,1);
ntrgs = 1;

clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];

ylm = [min(vss(:)) max(vss(:))];

c = 0;
fig = plot.init;
for ii = 1:nblks
    for jj = 1:ntrgs
        lwfcn = @(kk) ii;
        vs = squeeze(vss(:,ii,:,jj));
        lstmat.plotProgress(vs, clrs, ylm, lwfcn);
        title(mnkNm);
    end
end
legend({'int (intDec)', 'int (pertDec)', 'best-pert (intDec)', ...
    'best-pert (pertDec)'}, 'Location', 'BestOutside');
legend boxoff;
plot.setPrintSize(fig, struct('width', 7, 'height', 3));
if ~isempty(saveDir)
    export_fig(fig, fullfile(saveDir, [fnm '.pdf']));
end

%% plot average progress timecourse per target
%             
% clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];
% ylm = [min(avgPrg(:)) max(avgPrg(:))];
% blkNms = {'intuitive trials', ...
%     ['perturbation (first ' num2str(tr0) ' trials)'], ...
%     ['perturbation (best ' num2str(tr0) ' trials)']};
% 
% vss = avgPrg;
% [ndecs, nblks, ntms, ntrgs] = size(avgPrg);
% nrows = nblks; ncols = ntrgs;
% fnm = ['full_trial_' D.datestr];
% 
% vss = mean(vss, 4);
% ntrgs = size(vss,4);
% nrows = 1; ncols = nblks;
% fnm = ['avg_full_trial_' D.datestr];
% 
% c = 0;
% fig = plot.init;
% for ii = 1:nblks
%     for jj = 1:ntrgs
%         c = c + 1;
%         subplot(nrows, ncols, c); hold on;
%         if (ii == 1)
%             lwfcn = @(kk) (kk==1) + 1;
%         else
%             lwfcn = @(kk) min(kk,2);
%         end
%         lstmat.plotProgress(squeeze(vss(:,ii,:,jj)), clrs, ylm, lwfcn);
%         if (ii == 1) && (jj == 1)
%             title([D.datestr ': ' blkNms{ii}]);
%         elseif jj == 1
%             title(blkNms{ii});
%         end
%     end
% end
% plot.setPrintSize(fig, struct('width', 10, 'height', 4));
% if ~isempty(saveDir)
%     export_fig(fig, fullfile(saveDir, [fnm '.pdf']));
% end
