
doSave = false;
dt = '20131205';
fitName = 'Int2Pert_yIme';
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
% doSave = true;
opts = struct('grpInds', 1, 'dimInds', 1, 'doSave', doSave, 'doPca', true);
opts.ymax = 0.6;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% make wedges

doSave = false;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave, 'wedgeClr', 0.7*ones(3,1)));
end
