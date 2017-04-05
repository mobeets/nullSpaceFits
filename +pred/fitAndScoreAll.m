%%

% dts = {'20131205'};
dts = io.getDates;
doOverwrite = false;

%%

saveDir = 'Int2Pert_yIme_v2';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);
hnms = {};
pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);

%%

saveDir = 'Int2Pert_nIme';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);

%%

saveDir = 'Pert2Int_yIme';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);
pred.fitAndScoreSessions(saveDir, grpName, opts, {}, dts, doOverwrite);

%% 

% saveDir = 'Int2Int_nIme';
% grpName = 'thetaActualGrps';
% opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 1);
% hnms = {'minimum', 'baseline', 'uncontrolled-uniform', 'best-mean'};
% pred.fitAndScoreSessions(saveDir, grpName, opts, hnms, dts, doOverwrite);
