function params = fitFA(Y, maxndims)
    if nargin < 2
        maxndims = 20;
    end
    ix = ~any(isnan(Y),2);
    Y = Y(ix,:);
    mu = mean(Y);
    sdev = std(Y);
    Y = bsxfun(@minus, Y, mu);
    Y = bsxfun(@rdivide, Y, sdev);
    dim = crossvalidate_fa(Y', 'zDimList', 1:maxndims);
    params = {dim.estParams};
    sumPE = [dim.sumPE];
    sumLL = [dim.sumLL];
    for ii = 1:numel(params)
        params{ii}.FactorAnalysisParams.L = params{ii}.L;
        params{ii}.FactorAnalysisParams.Ph = params{ii}.Ph;
        params{ii}.FactorAnalysisParams.d = params{ii}.d;
        params{ii}.NormalizeSpikes.mean = mu;
        params{ii}.NormalizeSpikes.std = sdev;
        params{ii}.sumPE = sumPE(ii);
        params{ii}.sumLL = sumLL(ii);
        params{ii} = rmfield(params{ii}, 'L');
        params{ii} = rmfield(params{ii}, 'Ph');
        params{ii} = rmfield(params{ii}, 'd');
    end
    
end
