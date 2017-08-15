function [progs, vels, ss, us] = findAllMaxProgress(angs, M2, M0, ...
    beta, mu, lb, ub, inManifoldOnly)
% function [progs, vels, us] = findAllMaxProgress(angs, M, c, beta, mu, lb, ub)
% 
% find the firing rates maximizing progress in the angles provided (angs)
%    subject only to firing rates being within the lower bounds (lb) and
%    upper bounds (ub)
% assumes the decoder is v_t = M2*u_t + M0 (i.e., assumes v_{t-1} = 0)
%
% returns the progress (progs), velocities achieving that progress (vels),
%   speeds (ss), and the optimal firing rates (us)
%
    if nargin < 8
        inManifoldOnly = true;
    end
    nvs = numel(angs);
    vs = [cosd(angs) sind(angs)];
    us = zeros(nvs, numel(mu));
    vels = zeros(nvs, 2);
    progs = zeros(nvs, 2);
    ss = zeros(nvs, 1);
    for ii = 1:nvs
        if inManifoldOnly
            [us(ii,:), fval] = speed.findMaxProgress(M2', ...
                vs(ii,:)', beta', mu', lb', ub');
        else
            [us(ii,:), fval] = speed.findMaxProgress(M2', ...
                vs(ii,:)', [], [], lb', ub');
        end
        vels(ii,:) = M2*us(ii,:)' + M0;
        ss(ii) = fval + vs(ii,:)*M0;
        progs(ii,:) = ss(ii)*vs(ii,:);
    end
end
