
doSave = false;
dt = '20131205';
fitName = 'Int2Pert_yIme';
fitName = 'minEnergy_L1';

if strcmpi(fitName, 'Int2Int_nIme')
    hypsToShow = {'minimum', 'baseline', ...
        'uncontrolled-uniform'};
else
    hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};
end

% close all;
% hypsToShow = {'best-mean'};
hypsToShow = {'baseline', 'baseline-L1'};
% hypsToShow = {'minimum', 'best-mean'};
hypsToShow = {'baseline'};
% hypsToShow = {'constant-cloud', 'habitual-corrected'};
% hypsToShow = {'uncontrolled-empirical'};
 
% show singleton
opts = struct('grpInds', 1, 'dimInds', 1, 'doSave', doSave);
doPca = true;
for ii = 1:numel(hypsToShow)
    if strcmpi(hypsToShow{ii}, 'minimum') || strcmpi(hypsToShow{ii}, 'baseline') || strcmpi(hypsToShow{ii}, 'best-mean')
        opts.ymax = 1.0;
    elseif isfield(opts, 'ymax')
        opts = rmfield(opts, 'ymax');
    end
    plot.plotHistFig(fitName, dt, hypsToShow(ii), doPca, opts);
end

% show all
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave);
doPca = false;
for ii = 1:numel(hypsToShow)
    if strcmpi(hypsToShow{ii}, 'minimum') || strcmpi(hypsToShow{ii}, 'baseline')  || strcmpi(hypsToShow{ii}, 'best-mean')
        opts.ymax = 1.0;
    elseif isfield(opts, 'ymax')
        opts = rmfield(opts, 'ymax');
    end
    plot.plotHistFig(fitName, dt, hypsToShow(ii), doPca, opts);
end

%% make wedges

doSave = true;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave));
end
