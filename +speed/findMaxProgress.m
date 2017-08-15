function [u, fval, exitflag] = findMaxProgress(M, v, beta, mu, lb, ub)
% [u, fval, exitflag] = findMaxProgress(M, v, beta, mu, lb, ub)
% 
% M = decoder [90 x 2]
% v = speed along particular direction [2 x 1]
% beta = manifold [90 x 10]
% mu = spike count mean; used with beta [90 x 1]
% lb = lower-bound on spike counts [90 x 1], or scalar
% ub = lower-bound on spike counts [90 x 1], or scalar
% (n.b. 90 can be any number)
%
% returns:
%   u = spiking activity [90 x 1] where:
%       u = argmax_u u'Mv
%           s.t. Nul(beta)'u = 0
%                lb <= u <= ub
%   fval = u'*M*v
% 

    nd = size(M,1); % # of neurons
    if numel(mu) == 1
        mu = mu*ones(nd,1);
    end
    if numel(lb) == 1
        lb = lb*ones(nd,1);
    end
    if numel(ub) == 1
        ub = ub*ones(nd,1);
    end
    
    f = M*v;
    Aeq = null(beta')'; % want Nul(beta)'*(u - mu) = 0
    beq = Aeq*mu;
    opts = optimset('Display', 'off');
    [u, fval, exitflag] = linprog(-f', [], [], Aeq, beq, lb, ub, [], opts);
    if exitflag ~= 1
        warning('linprog did not converge to solution.');
    end
    fval = -fval; % negate so that output is u'*M*v

end
