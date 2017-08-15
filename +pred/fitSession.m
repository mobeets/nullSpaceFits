function [F,D] = fitSession(dtstr, hyps, grpName, opts)
    if nargin < 3
        grpName = 'thetaActualGrps16';
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
    
    % load
    D = io.loadPrepDataByDate(dtstr); % load preprocessed session data
    D = pred.prepSession(D, opts); % split into train/test

    % fit
    F = pred.fitHyps(D, hyps); % make predictions with each hyp

end
