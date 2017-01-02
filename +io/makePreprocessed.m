function makePreprocessed(dts, saveDir, doOverwrite)
    if nargin < 3
        doOverwrite = false;
    end
    for ii = 1:numel(dts)
        fnm = fullfile(saveDir, [dts{ii} '.mat']);
        if exist(fnm, 'file') && ~doOverwrite
            warning(['Skipping file "' fnm '" because it already exists.']);
            continue;
        end
        dts{ii}
        D = io.quickLoadByDate(dts{ii});
        save(fnm, 'D');
    end
end
