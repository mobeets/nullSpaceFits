%% load 

fnm = 'data/omp/coaching20160617.mat';
knmI = 'data/omp/kalmanInitParamsFA20160617_6.mat';
knmP = 'data/omp/kalmanInitParamsFA20160617_12.mat';
d = load(fnm);
kI = load(knmI);
kP = load(knmP);

%% activity during intuitive mappings

% Intuitive activity
dayInd = 1;
trialTags = [7 8];
blkI = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkI.name = 'Intuitive';

% OMP activity - day 1
dayInd = 1;
trialTags = 9;
blkP_1 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_1.name = 'OMP-d1';

% OMP activity - day 6
dayInd = 6;
trialTags = 4;
blkP_6 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_6.name = 'OMP-d6';

% OMP activity - day 7
dayInd = 7;
trialTags = 4;
blkP_7 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_7.name = 'OMP-d7';

% OMP activity - day 8
dayInd = 8;
trialTags = 4;
blkP_8 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_8.name = 'OMP-d8';

% Washout activity
dayInd = 8;
trialTags = 5;
blkW = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkW.name = 'Washout';

blks = [blkI, blkP_1, blkP_6, blkP_7, blkP_8, blkW];

% best 40 trials for each OMP, start trial:
% 220 (day 1)
% 47 (day 6)
% 199 (day 7)
% 348 (day 8)

%% re-fit FA

dayInd = 1;
trialTags = [7 8];
spsC = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags, nan, ...
    true, true, false); % include freeze activity
decs = omp.fitFA(spsC, 20);

%% decoders

decI.M0 = kI.kalmanInitParams.M0;
decI.M1 = kI.kalmanInitParams.M1;
decI.M2 = kI.kalmanInitParams.M2;
decP.M0 = kP.kalmanInitParams.M0;
decP.M1 = kP.kalmanInitParams.M1;
decP.M2 = kP.kalmanInitParams.M2;
decI.vfcn = @(y) bsxfun(@plus, decI.M2*y, decI.M0);
decP.vfcn = @(y) bsxfun(@plus, decP.M2*y, decP.M0);

% prgI = lstmat.getProgress(blks(1).sps, blks(1).pos, blks(1).trgpos, ...
%     decI.vfcn);
prgI = lstmat.getProgress(blks(1).sps, blks(1).pos, blks(1).trgpos, ...
    [], blks(1).vel);

%% progress of new dims

atrgs = unique(blks(1).trgpos, 'rows'); % each of 8 targets
xs = round(tools.computeAngles(bsxfun(@minus, atrgs, mean(atrgs))));
[xs,ix] = sort(xs);
atrgs = atrgs(ix,:);

ntrgs = size(atrgs,1);
prgsI = nan(size(newDims,1), ntrgs);
prgsP = nan(size(newDims,1), ntrgs);
for ii = 1:size(newDims,1)
    ps = repmat(mean(atrgs), ntrgs, 1); % starting position
    nD = repmat(newDims{ii,1}' + mu, ntrgs, 1); % new dim
    prgsI(ii,:) = lstmat.getProgress(nD, ps, atrgs, decI.vfcn);
    prgsP(ii,:) = lstmat.getProgress(nD, ps, atrgs, decP.vfcn);
end

vs = prgsP;
figure; imagesc(vs);
colormap(cbrewer('div', 'RdBu', 21));
set(gca, 'XTick', 1:numel(xs));
set(gca, 'XTickLabel', arrayfun(@num2str, xs, 'uni', 0));
set(gca, 'YTick', 1:numel(xs));
set(gca, 'YTickLabel', arrayfun(@num2str, xs, 'uni', 0));
xlabel('angle');
ylabel('angle used to find new dim');
cmx = ceil(max(abs(vs(:))));
caxis([-cmx cmx]);
colorbar;

% TODO:
% need to compare these predictions to actual progress
% - find dim using intuitive, compute prog as here
% - compare to actual prog on first 40 trials of OMP-d1, and during int.
% - now find dim using OMP-d8, compute prog as here, compare to actual prog

plot.init;
plot(xs, diag(prgsP), '-', 'LineWidth', 2);
plot(xlim, [0 0], 'k-');
set(gca, 'XTick', sort(xs));
xlabel('target');
ylabel('progress of new dim. through OMP decoder');
% ylabel('progress of dim. through OMP decoder');

%% find new dimensions in OMP activity

% find basis for manifold
dec = kI.kalmanInitParams;
% dec = decs{10};
mu = dec.NormalizeSpikes.mean;
sdev = dec.NormalizeSpikes.std;
[~, beta] = omp.spikesToLatents(dec, nan);
[beta_nb, beta_rb] = io.getNulRowBasis(beta);

% normalize spikes
normSps = @(sps) bsxfun(@minus, sps, mu);

% balance contribution of each trial by sampling equal number per trial
ntrboots = 5;
bsps = cell(numel(blks)+1,1);
for ii = 1:numel(blks)
    bsps{ii} = omp.sampleTimestepsEvenly(blks(ii).sps, ...
        blks(ii).trs, ntrboots);
end

% init
ymx = 20;
alltrgs = tools.thetaCenters;
newDims = cell(numel(alltrgs), ntrboots);
bls = cbrewer('seq', 'Blues', 5); bls = bls(2:end,:);
clrs = [0.8 0.2 0.2; bls; 0.8 0.4 0.4; 0.5 0.5 0.5];

% plot
fig1 = plot.init;
fig2 = plot.init;
for ii = 1:numel(alltrgs)
    % get activity during OMP for this target
    % balance contribution of each trial by sampling equal number per trial
    ctrg = alltrgs(ii);
    hypnms = [{blks.name} {['OMP (' num2str(ctrg) '^\circ)']}];
    blkIndP = 1;
    spsP2 = blks(blkIndP).sps(blks(blkIndP).thgrps == ctrg,:);
    trsP2 = blks(blkIndP).trs(blks(blkIndP).thgrps == ctrg,:);
    bsps{end} = omp.sampleTimestepsEvenly(spsP2, trsP2, ntrboots);
    
    figure(fig1);
    subplot(2, 4, ii); hold on;
    set(gca, 'FontSize', 16);    
    vs = nan(ntrboots, numel(hypnms));
    for jj = 1:ntrboots
        
        csps = cell(numel(bsps),1);
        for kk = 1:numel(bsps)
            csps{kk} = normSps(squeeze(bsps{kk}(jj,:,:)));
        end        
        % find new dimension for this target
        cspsP = csps{end};
        spsOffMan = mean(cspsP)*(beta_nb*beta_nb');
%         spsOffMan = mean(cspsP)*(beta_rb*beta_rb');
%         spsOffMan = mean(cspsP);
        newDim = (spsOffMan/norm(spsOffMan))';
        newDims{ii,jj} = newDim;

        % compare variance in new dimensions before and after learning OMP
        for kk = 1:numel(csps)
            vs(jj,kk) = var(csps{kk}*newDim);
        end
        
        % show histogram of projection onto new dimension
        vmn = -25; vmx = 25;
        bins = linspace(vmn, vmx, 100);
        css = nan(numel(csps), numel(bins));
        for kk = 1:numel(csps)
            css(kk,:) = histc(csps{kk}*newDim, bins);
            css(kk,:) = css(kk,:)/sum(css(kk,:));
            plot(bins, css(kk,:), '-', 'Color', clrs(kk,:));
        end
        if jj == ntrboots
            xlabel('proj. on new dim');
            ylabel('frequency');
            xlim([vmn vmx]);
            title([num2str(ctrg) '^\circ']);
        end
        if ii == 1 && jj == ntrboots
            legend(hypnms);
            legend boxoff;
        end
        
    end
    vsm = mean(vs);
    vse = std(vs)/sqrt(ntrboots);

    figure(fig2);
    subplot(2, 4, ii); hold on;
    set(gca, 'FontSize', 16);
    bar(1:numel(vsm), vsm, 'FaceColor', 'w');
    for jj = 1:numel(vsm)
        cm = vsm(jj);
        cse = vse(jj);
        plot([jj jj], [cm-cse cm+cse], 'k-');
    end
    set(gca, 'XTick', 1:numel(vsm));
    set(gca, 'XTickLabel', hypnms);
    set(gca, 'XTickLabelRotation', 45);
    ylabel('variance in new dimension');
    title([num2str(ctrg) '^\circ']);
    ylim([0 ymx]);
end
