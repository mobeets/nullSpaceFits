%% load

dtstr = '20131205';

opts = struct('mapNm', 'fDecoder', 'thetaNm', 'thetas', ...
    'velNm', 'vel', 'velNextNm', 'velNext', ...
    'trainBlk', 1, 'testBlk', 2, 'trainProp', 0.5, ...
    'fieldsToAdd', {{'thetaActualGrps'}});
% opts = struct('mapNm', 'fImeDecoder', 'thetaNm', 'thetasIme', ...
%     'velNm', 'velIme', 'velNextNm', 'velNextIme', ...
%     'trainBlk', 1, 'testBlk', 2, 'trainProp', 0.5, ...
%     'fieldsToAdd', {{'thetaActualImeGrps'}});

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
% gs = F.test.(grpName);
gs = D.blocks(2).thetaActualGrps16;
S = score.scoreAll(F, gs, grpName);
