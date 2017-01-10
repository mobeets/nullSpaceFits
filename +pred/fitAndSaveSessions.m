%% set opts

saveDir = 'data/fits_Int2Int_nIme';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 1);
hnms = {};
hyps = pred.getDefaultHyps(hnms);
dts = tools.getDatesInDir();
doOverwrite = false;

%% fit and save

% init saveDir and save opts
if ~doOverwrite && exist(saveDir, 'dir')
    error('Cannot fit because directory already exists.');
elseif ~exist(saveDir, 'dir')
    mkdir(saveDir);
end
save(fullfile(saveDir, 'opts.mat'), 'grpName', 'opts', 'hyps', 'dts');

% fit sessions
for ii = 1:numel(dts)
    tic;
    disp(['Fitting ' dts{ii} '...']);
    [F,D] = pred.fitSession(dts{ii}, hyps, grpName, opts);
    S = score.scoreAll(F, grpName); % score each hyp
    toc;

    fnm = fullfile(saveDir, [dts{ii} '_fits.mat']);
    snm = fullfile(saveDir, [dts{ii} '_scores.mat']);
    save(fnm, 'F');
    save(snm, 'S');
    
    histc(S.gs, S.grps)'
end
