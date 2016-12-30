function D = loadSession(dtstr, baseDir)
    if nargin < 2
        baseDir = 'preprocessed';
    end
    D = load(fullfile('data', baseDir, [dtstr '.mat']));
end
