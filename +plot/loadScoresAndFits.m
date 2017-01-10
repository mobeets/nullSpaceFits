function [S,F] = loadScoresAndFits(fitsDir)
%
    fnms = dir(fullfile(fitsDir, '*_scores.mat'));
    F = [];
    S = [];
    for ii = 1:numel(fnms)
        fnm = fnms(ii).name;        
        X = load(fullfile(fitsDir, fnm));
        S = [S X.S];
        if nargout > 1
            fnm = strrep(fnm, '_scores', '_fits');
            X = load(fullfile(fitsDir, fnm));
            F = [F X.F];
        end        
    end
end
