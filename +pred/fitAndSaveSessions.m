function fitAndSaveSessions(saveDir, grpName, opts, hnms, dts, doOverwrite)
    if nargin < 4
        hnms = {};
    end
    if nargin < 5 || isempty(dts)
        dts = tools.getDatesInDir();
    end
    if nargin < 6
        doOverwrite = false;
    end

    hyps = pred.getDefaultHyps(hnms, grpName);

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
            [F,~] = pred.fitSession(dts{ii}, hyps, grpName, opts);
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

end
