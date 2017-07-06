%%

dts = io.getDates;
doOverwrite = false;

%%

dts = io.getDates;
doOverwrite = true;
saveDir = 'Int2Pert_yIme_20170605';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);

%%

saveDir = 'Int2Pert_yIme_final';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);

%%

saveDir = 'Int2Pert_nIme_final';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);

%%

saveDir = 'Pert2Int_yIme_final';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);
