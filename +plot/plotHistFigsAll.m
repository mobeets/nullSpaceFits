
doSave = false;
dt = '20131205';
% fitName = 'Int2Pert_yIme';
fitName = 'Int2Pert_yIme_20170605';
hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};

%% plot grid of hists

close all;
% hypsToShow = {'constant-cloud', 'habitual-corrected'};
% doSave = true;
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave, ...
    'doPca', true);
opts.ymax = nan;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% plot singleton hists

close all;
% hypsToShow = {'constant-cloud'};
% hypsToShow = {};
% doSave = true;
opts = struct('grpInds', 1, 'dimInds', 1, 'doSave', doSave, 'doPca', true);
opts.ymax = 0.6;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

% to do: scale values to be spikes/s

%% make wedges

doSave = false;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave));
end