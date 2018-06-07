function [G,F,D] = loadCleanSession(dtstr, keepIncorrects, unfiltered, nBestTrials)
    if nargin < 2
        keepIncorrects = false;
    end
    if nargin < 3
        unfiltered = true;
    end
    if nargin < 4
        % if not nan, only return the best nBestTrials in terms of progress
        %   during the WMP session
        nBestTrials = nan;
    end
    if unfiltered
        ps = io.setUnfilteredDefaults;
    else
        ps = io.setFilterDefaults(dtstr);
        ps.MIN_DISTANCE = nan; ps.MAX_DISTANCE = nan;
    end
    ps.REMOVE_INCORRECTS = ~keepIncorrects;
    D = io.quickLoadByDate(dtstr, ps, true, true);
    opts = struct('skipFreezePeriod', false, 'throwError', false);
    opts.fieldsToAdd = {'isCorrect'};
    F = pred.prepSession(D, opts);
    G = lstmat.make_struct(F, '', true, nBestTrials);
end
