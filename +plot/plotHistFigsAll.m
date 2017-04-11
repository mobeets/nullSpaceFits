
doSave = false;
dt = '20131205';
fitName = 'Int2Pert_yIme';

hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};
hypsToShow = {'habitual-corrected', 'constant-cloud', 'minimum'};

%% plot grid of hists

doSave = true;
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave, ...
    'doPca', true);
opts.ymax = nan;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% plot singleton hists

doSave = true;
opts = struct('grpInds', 8, 'dimInds', 1, 'doSave', doSave, 'doPca', true);
opts.ymax = 0.7931;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% make wedges

doSave = true;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave));
end
