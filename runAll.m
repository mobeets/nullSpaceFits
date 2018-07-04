%% fit behavior (select trials)

behav.asymptotesAll; % also plot behavior figures
% ensure correct trials are now selected by io.shuffleStarts;

%% fit ime

dts = io.getDates;
opts = struct('plotdir', 'data/plots/ime', 'doCv', false, ...
    'doSave', true, 'fitPostLearnOnly', true, 'doLatents', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
    if mod(ii,5) == 0
        close all;
    end
end

%% make preprocessed data

dts = io.getDates;
io.makePreprocessed(dts, 'preprocessed');

%% fit hypotheses

runName = '_20180619';
pred.fitAndScoreAll;

%% make plots

plot.plotHistFigsAll; % Figs. 2-4
plot.findErrFloor;
plot.plotErrorFigs; % Fig. 5, S2a-c, S3, S4
plot.plotSSSFigs; % Fig. 6, S2d-e
plot.plotDistFromMDFigs; % Fig. S6
plot.williamsonAnalysis; % Fig. S7

%% report numbers
p
runName = '_20180619';
% runName = '';
fitName = 'Int2Pert_yIme';
[Ss,Fs] = plot.getScoresAndFits([fitName runName]);
dts = {Fs.datestr};

disp('++++++++++++++++++++');
disp([fitName runName]);
disp('++++++++++++++++++++');
disp('# of sessions per monkey: ');
mnks = io.getMonkeys;
ns = nan(numel(mnks), 1);
for ii = 1:numel(mnks)
    ns(ii) = sum(io.getMonkeyDateFilter(dts, mnks(ii)));
    disp(['    ' mnks{ii} ': ' num2str(ns(ii))]);
end
disp('------');

disp('avg firing rate per monkey: ');
scale = 1000/45;
for ii = 1:numel(mnks)
    ix = io.getMonkeyDateFilter(dts, mnks(ii));
    Fc = Fs(ix);
    sps = nan(numel(Fc),1);
    for jj = 1:numel(Fc)
        csps = Fc(jj).test.spikes;
        sps(jj) = mean(mean(csps));
    end
    mu = scale*mean(sps);
    sd = scale*std(sps);
    disp(['    ' mnks{ii} ': ' sprintf('%0.0f +/- %0.0f', [mu sd])]);
end
disp('------');

