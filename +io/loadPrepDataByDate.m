function D = loadPrepDataByDate(dtstr)
    DATADIR = getpref('factorSpace', 'data_directory');
    X = load(fullfile(DATADIR, 'sessions', 'preprocessed', ...
        [dtstr '.mat']));
    D = X.D;
end
