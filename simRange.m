function vs = simRange(rhos)
    if nargin < 1
        rhos = 0:0.1:1.0;
    end
    
    v1 = 9;
    v2 = 3;
    
    vs = nan(numel(rhos),2);
    for ii = 1:numel(rhos)
        rho = rhos(ii);
        Y = sampleY(rho);
        Y(:,1) = sqrt(v1)*Y(:,1);
        Y(:,2) = sqrt(v2)*Y(:,2);
        [~,~,v] = svd(Y, 'econ');
        Y2 = Y*v;
        vs(ii,:) = var(Y2);
    end
    
    lw = 3;
    plot.init;
    plot(0:0.1:1.0, vs(:,1), 'LineWidth', lw);
    plot(0:0.1:1.0, vs(:,2), 'LineWidth', lw);
    xlabel('\rho');
    ylabel('variance along PCs');
    title(['PCA on 2D Gaussian with \mu=0, \sigma^2=' ...
        '(' num2str(v1) ',' num2str(v2) '), corr=\rho']);

end

function Y = sampleY(rho, n)
% simulate 2D Gaussian with given correlation, zero mean and unit variance
    if nargin < 2
        n = 100000;
    end
    X = randn(n,2);
    Y = [X(:,1) rho*X(:,1) + sqrt(1 - rho^2)*X(:,2)];
end
