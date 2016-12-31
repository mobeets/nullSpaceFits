%% load

dtstr = '20131205';

opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2, ...
    'fieldsToAdd', {{'thetaActualGrps16'}});
D = pred.loadSession(dtstr); % load preprocessed session data
D = pred.prepSession(D, opts); % split into train/test

%% fit

hyps = pred.getDefaultHyps();
hnms = {'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
hix = ismember({hyps.name}, hnms);
hyps = hyps(hix);
F = pred.fitHyps(D, hyps);

%% score

grpName = 'thetaActualGrps';
gs = F.test.(grpName);
S = score.scoreAll(F, gs, grpName);
