function [G,F,D] = loadCleanSession(dtstr, keepIncorrects, unfiltered)
    if nargin < 2
        keepIncorrects = false;
    end
    if nargin < 3
        unfiltered = true;
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
    G = make_struct(F, '', true);
end
