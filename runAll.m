%% fit behavior (select trials)

behav.asymptotesAll;
% ensure correct trials are now selected by io.shuffleStarts;
dts = io.getDates;

%% fit ime

opts = struct('plotdir', 'data/plots/ime', 'doCv', false, ...
    'doSave', true, 'fitPostLearnOnly', true, 'doLatents', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
    if mod(ii,5) == 0
        close all;
    end
end

%% make preprocessed data

io.makePreprocessed(dts, 'preprocessed');

%% fit hypotheses

pred.fitAndScoreAll;

%% make plots

plot.plotHistFigsAll; % Figs. 2-4
plot.plotErrorFigs; % Fig. 5
plot.plotSSSFigs; % Fig. 6
