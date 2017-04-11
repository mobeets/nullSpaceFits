function makePreprocessed(dts, prepType, doOverwrite)
    if nargin < 2
        prepType = 'checkpoints';
    end
    if nargin < 3
        doOverwrite = false;
    end
    
    DATADIR = getpref('factorSpace', 'data_directory');
    saveDir = fullfile(DATADIR, 'sessions', prepType);
    
    for ii = 1:numel(dts)
        fnm = fullfile(saveDir, [dts{ii} '.mat']);
        if exist(fnm, 'file') && ~doOverwrite
            warning(['Skipping file "' fnm '" because it already exists.']);
            continue;
        end
        dts{ii}
        if strcmpi(prepType, 'checkpoint')
            D = io.loadRawDataByDate(dts{ii});
        elseif strcmpi(prepType, 'preprocessed')
            D = io.quickLoadByDate(dts{ii});
        end
        save(fnm, 'D');
    end
end
