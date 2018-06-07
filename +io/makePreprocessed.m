function makePreprocessed(dts, prepType, doOverwrite)
    if nargin < 2
        prepType = 'checkpoint';
    end
    if nargin < 3
        doOverwrite = false;
    end
    
    DATADIR = getpref('factorSpace', 'data_directory');
    saveDir = fullfile(DATADIR, 'sessions', prepType);
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    
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
        elseif strcmpi(prepType, 'alltrials')
            D = io.quickLoadByDate(dts{ii}, ...
                struct('START_SHUFFLE', nan, 'END_SHUFFLE', nan));
        end
        save(fnm, 'D');
    end
end
