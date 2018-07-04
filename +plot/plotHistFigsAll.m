
doSave = false;
% exampleSession = '20131218';
exampleSession = '20120628';

runName = '_20180619';
fitName = 'Int2Pert_yIme';
hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};
hypsToShow = {'habitual-corrected', 'constant-cloud'};

%% plot grid of hists

close all;
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave, ...
    'doPca', true);
opts.ymax = nan;
plot.plotHistFigs(fitName, runName, exampleSession, hypsToShow, opts);

%% plot singleton hists

close all;
opts = struct('grpInds', 3, 'dimInds', 1, 'doSave', doSave, 'doPca', true);
plot.plotHistFigs(fitName, runName, exampleSession, hypsToShow, opts);

%% make wedges

doSave = false;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave, 'wedgeClr', 0.7*ones(3,1)));
end
