%% set opts

% saveDir = 'data/fits_Int2Int_nIme';
% grpName = 'thetaActualGrps';
% opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 1);

% saveDir = 'data/fits_Int2Pert_nIme';
% grpName = 'thetaActualGrps';
% opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 2);

saveDir = 'data/fits_Int2Pert_yIme';
grpName = 'thetaActualImeGrps';
opts = struct('useIme', true, 'trainBlk', 1, 'testBlk', 2);

% saveDir = 'data/fits_Pert2Int_yIme';
% grpName = 'thetaActualImeGrps';
% opts = struct('useIme', true, 'trainBlk', 2, 'testBlk', 1);

doOverwrite = false;

hnms = {};
hyps = pred.getDefaultHyps(hnms, grpName);
dts = tools.getDatesInDir();

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
    try
        tic;
        disp(['Fitting ' dts{ii} '...']);
        [F,D] = pred.fitSession(dts{ii}, hyps, grpName, opts);
        S = score.scoreAll(F, grpName); % score each hyp
        toc;
    catch
        warning(['Error for ' dts{ii} '.']);
        continue;
    end

    fnm = fullfile(saveDir, [dts{ii} '_fits.mat']);
    snm = fullfile(saveDir, [dts{ii} '_scores.mat']);
    save(fnm, 'F');
    save(snm, 'S');
    
    histc(S.gs, S.grps)'
end
