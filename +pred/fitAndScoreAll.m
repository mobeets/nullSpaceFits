%%

% runName = '_20180619'; % '_final'
dts = io.getDates;
doOverwrite = false;
% hnms = {'habitual-corrected', 'constant-cloud'};
hnms = {};

%%

saveDir = ['Int2Pert_yIme' runName];
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%%

saveDir = ['Int2Pert_nIme' runName];
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%%

saveDir = ['Pert2Int_yIme' runName];
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);
