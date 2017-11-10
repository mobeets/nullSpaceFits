%% load

[blks, decs, ks, d] = omp.loadCoachingSessions('20160617');

%% plot opts

opts.doSave = false;
opts.saveDir = fullfile('data', 'plots', 'omp', 'progress');
opts.ext = 'pdf';

%% correct for baseline shift on each day

% old_blks = blks;
muBaseline = blks(1).spsBaseline;
for ii = 2:numel(blks)
    muShift = muBaseline - blks(ii).spsBaseline;
    blks(ii).sps = bsxfun(@plus, blks(ii).sps, muShift);
end

%% find new dims on last full-OMP day

orthToBaseline = false;
muBaseline = blks(1).spsBaseline;
[trgs, atrgs, ps] = omp.findTargetsAndStartPos(blks(1));
[newDims, normSps] = omp.getNewDims(blks(end-1), ks, trgs, orthToBaseline, muBaseline);

%% plot projections onto new dims and their variance, over days

projs = omp.getProjectionsOnNewDims(blks, trgs, newDims, normSps);
omp.plotProjections(projs, blks, trgs);
vss = omp.plotVarOfProjections(projs, blks, trgs);

%% show progress of avg activity

%% show progress activity along new dims
