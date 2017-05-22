
doSave = false;
showWashout = true;
dtstr = '20131205';

prms = struct('START_SHUFFLE', nan, 'END_SHUFFLE', nan, ...
    'REMOVE_INCORRECTS', false);
D1 = io.quickLoadByDate(dtstr, prms);
prms = struct('START_SHUFFLE', nan);
D = io.quickLoadByDate(dtstr, prms);

%%

plot.plotBehavMeanAndVar(D, struct('behavNm', 'trial_length'), ...
    struct('doSave', doSave));

%%

plot.plotBehavSmoothed(D, struct('behavNm', 'trial_length', ...
    'doSave', doSave, 'showWashout', showWashout));

%%

plot.plotBehavSmoothed(D1, struct('behavNm', 'isCorrect', ...
    'doSave', doSave));

%%

% dts = io.getDates;
% dts = {'20120516', '20120525', '20131205', '20160405', '20160722'};
dts = {'20160722'};

% behavNm = 'trial_length';
behavNm = 'isCorrect';
doSave = false;
showWashout = true;

prms = struct('START_SHUFFLE', nan, 'END_SHUFFLE', nan, ...
    'REMOVE_INCORRECTS', ~strcmpi(behavNm, 'isCorrect'));
opts = struct('behavNm', behavNm, ...
    'doSave', doSave, 'showWashout', true, 'binSz', 10);
pts = cell(numel(dts),1);
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.loadRawDataByDate(dtstr, true);
    D.params = io.setUnfilteredDefaults;
    D.params.REMOVE_INCORRECTS = ~strcmpi(behavNm, 'isCorrect');
    [D.blocks, D.trials] = io.getDataByBlock(D);
%     D = io.quickLoadByDate(dts{ii}, prms);
    pts{ii} = plot.plotBehavSmoothed(D, opts);
end
