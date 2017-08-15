function [progs, ss, us] = findMaxFactorActivity(angs, beta, mu, ...
    lb, ub, inManifoldOnly)
% find range of factor activity possible in first two dims
% subject tonon-negative firing
    if nargin < 6
        inManifoldOnly = false;
    end

    if size(angs,1) == 1
        angs = angs';
    end
    nvs = numel(angs);
    vs = [cosd(angs) sind(angs)];
    us = zeros(nvs, numel(mu));
    progs = zeros(nvs, 2);
    ss = zeros(nvs, 1);
    for ii = 1:nvs
        vc = [vs(ii,:) zeros(1,8)]';
        betac = beta'*vc;
        if inManifoldOnly
            [us(ii,:), fval] = speed.findMaxProgress(beta', ...
                vc, beta', mu', lb', ub');
        else
            [us(ii,:), fval] = speed.findMaxProgress(beta', ...
                vc, [], [], lb', ub');
        end
        ss(ii) = fval - mu*betac;
        progs(ii,:) = ss(ii)*vs(ii,:);
    end
end
