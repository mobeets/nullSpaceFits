function [F,S,D] = fitSession(dtstr, hnms, grpName, opts)
    if nargin < 3
        grpName = 'thetaActualGrps16';
    end
    if nargin < 4
        opts = struct();
    end
    if ~isfield('fieldsToAdd', opts) || ~ismember(grpName, opts.fieldsToAdd)
        opts.fieldsToAdd = {grpName};
    end
    
    % load
    D = pred.loadSession(dtstr); % load preprocessed session data
    D = pred.prepSession(D, opts); % split into train/test    
    
    % fit
    hyps = pred.getDefaultHyps(hnms); % get hyp fitting functions
    F = pred.fitHyps(D, hyps); % make predictions with each hyp
    
    % score
    gs = F.test.(grpName); % define groups for scoring
    S = score.scoreAll(F, gs, grpName); % score each hyp

end
