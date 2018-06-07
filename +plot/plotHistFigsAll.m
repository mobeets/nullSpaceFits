
doSave = false;
dt = '20131218';
saveDir = 'Int2Pert_yIme_20180606';
% fitName = 'Int2Pert_yIme';
hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};
hypsToShow = {'habitual-corrected', 'constant-cloud'};

%% plot grid of hists

% 1, 3, 12, 15, 20, 24, 31

close all;
% dt = dts{31}
% hypsToShow = {'constant-cloud', 'habitual-corrected'};
% doSave = true;
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave, ...
    'doPca', true);
opts.ymax = nan;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% plot singleton hists

close all;
% hypsToShow = {'habitual-corrected', 'constant-cloud'};
doSave = true;
opts = struct('grpInds', 3, 'dimInds', 1, 'doSave', doSave, 'doPca', true);
opts.ymax = 0.6;
plot.plotHistFigs(fitName, dt, hypsToShow, opts);

%% make wedges

doSave = false;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave, 'wedgeClr', 0.7*ones(3,1)));
end
