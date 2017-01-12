%% 

saveDir = 'data/fits/Int2Int_nIme';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 1);
hnms = {'minimum', 'baseline', 'uncontrolled-uniform', 'best-mean'};
pred.fitAndSaveSessions(saveDir, grpName, opts, hnms);

%%

saveDir = 'data/fits/Int2Pert_nIme';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndSaveSessions(saveDir, grpName, opts);

%%

saveDir = 'data/fits/Int2Pert_yIme_v1';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndSaveSessions(saveDir, grpName, opts);

%%

saveDir = 'data/fits/Pert2Int_yIme';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);
pred.fitAndSaveSessions(saveDir, grpName, opts);
