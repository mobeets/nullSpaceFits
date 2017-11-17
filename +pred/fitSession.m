function [F,D] = fitSession(dtstr, hyps, grpName, opts)
    if nargin < 3
        grpName = 'thetaActualGrps';
    end
    if nargin < 4
        opts = struct();
    end
    if ~isfield(opts, 'fieldsToAdd')
        opts.fieldsToAdd = {};
    end
    if ~ismember(grpName, opts.fieldsToAdd)
        opts.fieldsToAdd = [opts.fieldsToAdd grpName];
    end
    
    % load preprocessed session data
    if isfield(opts, 'prepName')
        prepName = opts.prepName;
    else
        prepName = 'preprocessed';
    end
    D = io.loadPrepDataByDate(dtstr, prepName);
    
    % split into train/test
    D = pred.prepSession(D, opts);

    % fit
    F = pred.fitHyps(D, hyps); % make predictions with each hyp

end
