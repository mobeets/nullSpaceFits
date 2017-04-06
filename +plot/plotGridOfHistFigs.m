function plotGridOfHistFigs(fitName, dt, hypsToShow, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('doSave', false, 'saveDir', 'data/plots', ...
        'saveExt', 'pdf', ...
        'doPca', true, 'grpInds', 1:8, 'dimInds', 1:3);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
end
