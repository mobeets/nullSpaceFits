function D = loadSession(dtstr, baseDir)
    if nargin < 2
        baseDir = 'preprocessed';
    end
    X = load(fullfile('data', baseDir, [dtstr '.mat']));
    D = X.D;
end
