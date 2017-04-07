
doSave = false;
dtstr = '20131205';

prms = struct('START_SHUFFLE', nan, 'REMOVE_INCORRECTS', false);
D = io.quickLoadByDate(dtstr, prms);

%%

plot.plotBehavMeanAndVar(D, struct('behavNm', 'trial_length'), ...
    struct('doSave', doSave));

%%

plot.plotBehavSmoothed(D, struct('behavNm', 'isCorrect', ...
    'doSave', doSave));

%%

plot.plotBehavSmoothed(D, struct('behavNm', 'trial_length', ...
    'doSave', doSave));
