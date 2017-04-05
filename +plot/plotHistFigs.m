
doSave = false;
dt = '20131205';
% fitName = 'Int2Pert_yIme';
fitName = 'Int2Pert_yIme_v2';

hypsToShow = {'minimum' 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', ...
        'constant-cloud'};

% hypsToShow = {'best-mean'};
% hypsToShow = {'minimum', 'minimum-L1'};
% hypsToShow = {'minimum', 'best-mean'};
% hypsToShow = {'constant-cloud'};
% hypsToShow = {'constant-cloud', 'habitual-corrected'};
% hypsToShow = {'uncontrolled-empirical'};

% show all
opts = struct('grpInds', 1:8, 'dimInds', 1:3, 'doSave', doSave);
doPca = true;
for ii = 1:numel(hypsToShow)
    if strcmpi(hypsToShow{ii}, 'minimum') || strcmpi(hypsToShow{ii}, 'baseline')  || strcmpi(hypsToShow{ii}, 'best-mean')
        opts.ymax = 1.0;
    elseif isfield(opts, 'ymax')
        opts = rmfield(opts, 'ymax');
    end
    plot.plotHistFig(fitName, dt, hypsToShow(ii), doPca, opts);
end

%%

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

%% make wedges

doSave = true;
close all;
for ii = 1:8
    plot.plotWedge(ii, struct('doSave', doSave));
end
