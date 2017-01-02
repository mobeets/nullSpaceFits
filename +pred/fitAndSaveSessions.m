%% set opts

saveDir = 'data/fits_int';
grpName = 'thetaActualGrps';
opts = struct('useIme', false, 'trainBlk', 1, 'testBlk', 1);
% hnms = {'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
hnms = {};
hyps = pred.getDefaultHyps(hnms);
dts = tools.getDatesInDir();

%% fit and save

% save opts
% if exist(saveDir, 'dir')
%     error('Cannot fit because directory already exists.');
% end
mkdir(saveDir);
save(fullfile(saveDir, 'opts.mat'), 'grpName', 'opts', 'hyps', 'dts');

% fit sessions
for ii = 1%:numel(dts)
    tic;
    disp(['Fitting ' dts{ii} '...']);
    [F,S,D] = pred.fitSession(dts{ii}, hnms, grpName, opts);
    toc;

    fnm = fullfile(saveDir, [dts{ii} '_fits.mat']);
    snm = fullfile(saveDir, [dts{ii} '_scores.mat']);
    save(fnm, 'F');
    save(snm, 'S');
    
    histc(S.gs, S.grps)'
end
