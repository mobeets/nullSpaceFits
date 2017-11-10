function [v, p] = inConvexHull(y, Y)
% y [1 x d] is the query point
% Y [n x d] are points defining the convex hull
% 
% y is in the convex hull of Y if it can be written as y' = Y'*p
%   where p is in the simplex
% 
% v is true if p is in convex hull, false if it is not, and nan if
%   optimization did not converge
% 

    % constraints: y' = Y'*p and sum(p) = 1, with p non-negative
    n = size(Y,1);
    Aeq = [Y'; ones(1,n)];
    Beq = [y'; 1];
    
	% initial guess: find point in Y closest to y
    p0 = zeros(n,1);
    [~,ix] = min(sum(bsxfun(@minus, Y, y).^2,2));    
    p0(ix) = 0.95;
    p0(ix+1) = 0.05;
    
    % solve
    opts = optimoptions('fmincon', ...
        'Algorithm', 'active-set', 'MaxFunEvals', 1e4);
    [p, ~, exitflag] = fmincon(@(p) 1, p0, ...
        [], [], Aeq, Beq, zeros(n,1), [], [], opts);
    if exitflag == -2
        v = false;
    elseif exitflag == 1
        v = true;
    else
        v = nan;
    end

end
