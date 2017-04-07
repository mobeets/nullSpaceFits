
doSave = false;
dtstr = '20131205';

prms = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
D1 = io.quickLoadByDate(dtstr, prms);
prms = struct('START_SHUFFLE', nan);
D = io.quickLoadByDate(dtstr, prms);

%%

plot.plotBehavMeanAndVar(D, struct('behavNm', 'trial_length'), ...
    struct('doSave', doSave));

%%

plot.plotBehavSmoothed(D, struct('behavNm', 'trial_length', ...
    'doSave', doSave));

%%

plot.plotBehavSmoothed(D1, struct('behavNm', 'isCorrect', ...
    'doSave', doSave));
