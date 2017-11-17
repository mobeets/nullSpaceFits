function D = loadPrepDataByDate(dtstr, dirNm)
    if nargin < 2
        dirNm = 'preprocessed';
    end
    DATADIR = getpref('factorSpace', 'data_directory');
    X = load(fullfile(DATADIR, 'sessions', dirNm, ...
        [dtstr '.mat']));
    D = X.D;
end
