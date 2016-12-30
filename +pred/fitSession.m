%% load

dtstr = '20131205';
opts = struct('mapNm', 'fDecoder', 'thetaNm', 'thetas', ...
    'velNm', 'vel', 'trainBlk', 1, 'testBlk', 2, 'trainProp', 0.5);
D = pred.loadSession(dtstr); % load preprocessed session data
D = pred.prepSession(D, opts); % split into train/test

%% fit

hyps = pred.getDefaultHyps();
F = pred.fitHyps(D, hyps);

%% score

grpName = 'thetaActualGrps';
gs = D.test.(grpName);
S = score.scoreAll(F, gs, grpName);
