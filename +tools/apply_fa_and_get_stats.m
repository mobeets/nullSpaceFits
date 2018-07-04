function [d_shared, prop_shared_var, fa_obj] = apply_fa_and_get_stats(Y, maxdim)
% addpath(genpath('~/code/fa'))
    if nargin < 2
        maxdim = 50;
    end

    % preprocess: remove nans, and z-score
    ix = ~any(isnan(Y),2);
    Y = Y(ix,:);
    mu = mean(Y);
    sdev = std(Y);
    Y = bsxfun(@minus, Y, mu);
    Y = bsxfun(@rdivide, Y, sdev);
    
    % fit fa to choose dimensionality
    ndims = 1:min(size(Y,2), maxdim);
    dim = crossvalidate_fa(Y', 'zDimList', ndims, ...
        'verbose', false, 'showPlots', false);
    istar = ([dim.sumLL] == max([dim.sumLL]));
    if find(istar) == max(ndims)
        warning('Picked maximum dimensionality. Maybe increase the range.');
    end
    fa_obj = dim(istar);
    
    % compile stats
    params = fa_obj.estParams;
    L = params.L;
    Ph = params.Ph;
    nd = size(Y,2);
    
    % compute avg percent shared variance across neurons
    prop_shared_vars = nan(nd,1);
    for k = 1:nd
        Lc = L(k,:)*L(k,:)';
        prop_shared_vars(k) = Lc/(Lc + Ph(k));
    end
    prop_shared_var = mean(prop_shared_vars);
    
    Lc = L*L';
    es = svd(Lc);
    prop_shared_var_modes = cumsum(es)./sum(es);
    d_shared = find(prop_shared_var_modes >= 0.95, 1, 'first');

end
