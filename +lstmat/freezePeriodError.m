
% [G,F,D] = lstmat.loadCleanSession('20120525', true, true);
B0 = G.train;
B = G.test;
Bc = D.blocks(2);
tr0 = 56;
[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(Bc, tr0, ...
    'progress', @max, 5, inf);
trRngs = [min(ts) min(ts) + tr0; trL1 trL2];

trgs0 = round(B0.targetAngle);
trgs = round(B.targetAngle);
alltrgs = sort(unique(trgs));
ntrgs = numel(alltrgs);

ixtE = (B.trial_index >= trRngs(1,1)) & (B.trial_index <= trRngs(1,2));
ixtL = (B.trial_index >= trRngs(2,1)) & (B.trial_index <= trRngs(2,2));

cvelInt = @(y) bsxfun(@plus, B0.M2*y, B0.M0);
cvelPert = @(y) bsxfun(@plus, B.M2*y, B.M0);

%% plot behavior per target

trs = B0.trial_index;
trgs = round(B0.targetAngle);
tms = B0.time;
ix = tms > 6;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgsc = grpstats(trgs(ix), trs(ix));
beh1 = grpstats(atms, trgsc);

trs = B.trial_index;
trgs = round(B.targetAngle);
tms = B.time;
ix = (tms > 6) & ixtE;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgsc = grpstats(trgs(ix), trs(ix));
beh2 = grpstats(atms, trgsc);

trs = B.trial_index;
trgs = round(B.targetAngle);
tms = B.time;
ix = (tms > 6) & ixtL;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgsc = grpstats(trgs(ix), trs(ix));
beh3 = grpstats(atms, trgsc);

behs{1} = beh1;
behs{2} = beh2;
behs{3} = beh3;

%% find behavior per block per time per angle

ts = trgs;
tms = B.time;
lts = B.latents;
NB = B.NB;
RB = B.RB;

ts0 = trgs0;
tms0 = B0.time;
lts0 = B0.latents;
NB0 = B0.NB;
RB0 = B0.RB;

% behNm = 'angular error';
behNm = 'progress';
if strcmp(behNm, 'angular error')
    behfcn = @(u,v) tools.computeAngle(u, v);
else
    behfcn = @(u,v) v*u;
end

ntms = 10;
% angs = nan(3, ntms, ntrgs, 2+4);
angs = nan(3, ntms, ntrgs, 2);
for t = 1:ntms
    for jj = 1:ntrgs
        ctrg = [cosd(alltrgs(jj)) -sind(alltrgs(jj))];
        
        ix = (ts0 == alltrgs(jj)) & tms0 == t;
        yms = grpstats(lts0(ix,:), tms0(ix));
        angs(1,t,jj,1) = behfcn(cvelInt(yms'), ctrg);
        angs(1,t,jj,2) = behfcn(cvelPert(yms'), ctrg);
        
%         angs(1,t,jj,3) = behfcn(cvelInt((yms*(NB*NB'))'), ctrg);
%         angs(1,t,jj,4) = behfcn(cvelInt((yms*(RB*RB'))'), ctrg);
%         angs(1,t,jj,5) = behfcn(cvelPert((yms*(NB0*NB0'))'), ctrg);
%         angs(1,t,jj,6) = behfcn(cvelPert((yms*(RB0*RB0'))'), ctrg);
        
        ix = (ts == alltrgs(jj)) & ixtE & tms == t;
        yms = grpstats(lts(ix,:), tms(ix));
        angs(2,t,jj,1) = behfcn(cvelInt(yms'), ctrg);
        angs(2,t,jj,2) = behfcn(cvelPert(yms'), ctrg);
        
%         angs(2,t,jj,3) = behfcn(cvelInt((yms*(NB*NB'))'), ctrg);
%         angs(2,t,jj,4) = behfcn(cvelInt((yms*(RB*RB'))'), ctrg);
%         angs(2,t,jj,5) = behfcn(cvelPert((yms*(NB0*NB0'))'), ctrg);
%         angs(2,t,jj,6) = behfcn(cvelPert((yms*(RB0*RB0'))'), ctrg);
        
        ix = (ts == alltrgs(jj)) & ixtL & tms == t;
        yms = grpstats(lts(ix,:), tms(ix));
        angs(3,t,jj,1) = behfcn(cvelInt(yms'), ctrg);
        angs(3,t,jj,2) = behfcn(cvelPert(yms'), ctrg);
        
%         angs(3,t,jj,3) = behfcn(cvelInt((yms*(NB*NB'))'), ctrg);
%         angs(3,t,jj,4) = behfcn(cvelInt((yms*(RB*RB'))'), ctrg);
%         angs(3,t,jj,5) = behfcn(cvelPert((yms*(NB0*NB0'))'), ctrg);
%         angs(3,t,jj,6) = behfcn(cvelPert((yms*(RB0*RB0'))'), ctrg);
    end
end

%%

[nblks, ntms, nangs, nds] = size(angs);
ncols = nblks+1; nrows = nangs;

c = 0;
blkNms = {'intuitive trials', ...
    ['perturbation (first ' num2str(tr0) ' trials)'], ...
    ['perturbation (best ' num2str(tr0) ' trials)']};
nms = {'intDec', 'pertDec'};
% clrs = [0.8 0.2 0.2; 0.2 0.2 0.8];
% nms = {'pertDec', 'pertDec-NB0', 'pertDec-RB0'};
% nms = {'intDec', 'intDec-NB', 'intDec-RB'};
% nms = {'Mp_I', 'Mp_P', 'Mp_I-RB_2', 'Mp_P-NB_1'};
clrs = [0.8 0.2 0.2; 0.2 0.2 0.8; 0.8 0.6 0.6; 0.8 0.6 0.6; ...
    0.6 0.6 0.8; 0.6 0.6 0.8];

fig = plot.init;
xs = tools.thetaCenters;
sc = 45/1000;
for kk = 1:nangs
    c = c + 1;
    x = xs(kk);
    y1 = behs{1}(kk);
    y2 = behs{2}(kk);
    y3 = behs{3}(kk);
    subplot(ncols, nrows, c); hold on;
    bar(1, sc*y1, 'EdgeColor', clrs(1,:), ...
        'FaceColor', 'w', 'LineWidth', 1);
    bar(2:3, sc*[y2 y3], 'EdgeColor', clrs(2,:), ...
        'FaceColor', 'w', 'LineWidth', 1);
    set(gca, 'XTick', 1:3);
    set(gca, 'XTickLabel', {'int.', 'pert, first', 'pert, best'});
    set(gca, 'XTickLabelRotation', 45);
    ylabel('acq. time (s)');
    xlim([0.5 3.5]);
    ylim([0 sc*max(max(cell2mat(behs)))]);
    title(['target = ' num2str(xs(kk)) '^\circ']);
end

ymn = floor(min(angs(:)));
ymx = ceil(max(angs(:)));
for ii = 1:nblks
    for kk = 1:nangs
        c = c + 1;
        subplot(ncols, nrows, c); hold on;
        plot([1 ntms], [0 0], '-', 'Color', 0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        plot([3 3], [ymn ymx], '-', 'Color',  0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        plot([7 7], [ymn ymx], '-', 'Color',  0.8*ones(3,1), ...
            'HandleVisibility', 'off');
        for jj = 1:nds
            ys = angs(ii,:,kk,jj);
            if (ii == 1 && jj == 1) || (ii > 1 && jj == 2)
                lw = 2;
            else
                lw = 1;
            end
%             if any(jj == [1 2 4 5])
            if any(jj == [1 2])
                plot(1:ntms, ys, '-', 'Color', clrs(jj,:), 'LineWidth', lw);
            end
        end        
        xlabel('time');
        ylabel(behNm);
        ylim([ymn ymx]);
        if kk == 1
            if ii == 1
                title([D.datestr ': ' blkNms{ii}]);
            else
                title(blkNms{ii});
            end
        end        
        if ii == 1 && kk == 1
            legend(nms, 'Location', 'Southwest');
            legend boxoff;
        end
    end
end

plot.setPrintSize(fig, struct('width', 11, 'height', 6));
if ~isempty(saveDir)
    export_fig(fig, fullfile(saveDir, [D.datestr '_dyns.pdf']));
end

%%

cangs = squeeze(mean(angs, 3));
vs = cangs;
ttl = D.datestr;
nms = {'Mp_I', 'Mp_P', 'Mp_I-NB_P', 'Mp_I-RB_P', 'Mp_P-NB_I', 'Mp_P-RB_I'};

mnkNm = 'Lincoln';
ttl = mnkNm;
ix = io.getMonkeyDateFilter(dts, {mnkNm});
vs = cell2mat(cellfun(@(d) permute(d, [4 1 2 3]), Cangs(ix), 'uni', 0));
vs = squeeze(mean(vs, 1));

fig = plot.init;

ymn = floor(min(vs(:)));
ymx = ceil(max(vs(:)));

for ii = 1:size(vs,1)
    subplot(1, size(vs,1), ii); hold on;
    set(gca, 'FontSize', 14);
    plot([1 ntms], [0 0], '-', 'Color', 0.8*ones(3,1), ...
    'HandleVisibility', 'off');
    plot([3 3], [ymn ymx], '-', 'Color',  0.8*ones(3,1), ...
    'HandleVisibility', 'off');
    plot([7 7], [ymn ymx], '-', 'Color',  0.8*ones(3,1), ...
    'HandleVisibility', 'off');
    plot(vs(ii,:,1), 'Color', clrs(1,:), 'LineWidth', 2);
    plot(vs(ii,:,2), 'Color', clrs(2,:), 'LineWidth', 2);
    plot(vs(ii,:,3), '--', 'Color', clrs(3,:), 'LineWidth', 2);
    plot(vs(ii,:,4), 'Color', clrs(4,:), 'LineWidth', 2);
    plot(vs(ii,:,5), '--', 'Color', clrs(5,:), 'LineWidth', 2);    
    plot(vs(ii,:,6), 'Color', clrs(6,:), 'LineWidth', 2);
    ylim([ymn ymx]);
    xlabel('time');
    ylabel(behNm);
    if ii == 1
        title([ttl ': ' blkNms{ii}]);
        legend(nms, 'Location', 'Northwest'); legend boxoff;
    else
        title(blkNms{ii});
    end
end

plot.setPrintSize(fig, struct('width', 9, 'height', 2));
if ~isempty(saveDir)
    export_fig(fig, fullfile(saveDir, ['all_dyns_' ttl '.pdf']));
end

%%
% 
% ymx = max(abs(angs(:)));
% ct = 6;
% 
% dprg = nan(ntrgs, 2);
% 
% f = plot.init;
% for jj = 1:ntrgs
%     subplot(2,4,jj); hold on;    
%     vs1 = squeeze(angs(:, ct, jj, 1));
%     vs2 = squeeze(angs(:, ct, jj, 2));
%     
%     dprg(jj,1) = vs1(2) - vs1(1);
%     dprg(jj,2) = vs2(2) - vs2(1);
%     
%     plot(1:3, vs1);
%     plot(1:3, vs2);
%     plot([1 3], [0 0], '-', 'Color', 0.8*ones(3,1));
%     set(gca, 'XTickLabel', {'int', 'early-pert', 'late-pert'});
%     set(gca, 'XTickLabelRotation', 45);
%     ylim([-ymx ymx]);
%     set(gca, 'FontSize', 14);
%     if jj == 1
%         legend({'intDec', 'pertDec'}, 'FontSize', 8);
%         legend boxoff;        
%     end
%     ylabel(behNm);
%     title({D.datestr, ['trg: ' num2str(alltrgs(jj)) '^\circ' ...
%         ', t: ' num2str(ct)]});
% end
% plot.setPrintSize(f, struct('width', 7, 'height', 4.5));
% 
% %% compare progress change before and after learning
% 
% plot.init;
% ymx = max(abs(dprg(:)));
% plot([0 0], [-ymx ymx], '-', 'Color', 0.8*ones(3,1));
% plot([-ymx ymx], [0 0], '-', 'Color', 0.8*ones(3,1));
% xlim([-ymx ymx]); ylim(xlim);
% plot(dprg(:,1), dprg(:,2), 'ko');
% xlabel(['\Delta ' behNm ' (pert-early - int), intDec']);
% ylabel(['\Delta ' behNm '(pert-early - int), pertDec']);
% title(D.datestr);
