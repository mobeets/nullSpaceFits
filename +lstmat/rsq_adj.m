function r = rsq_adj(Y, Yh, p)
    
    SST = sum((Y - mean(Y)).^2);
    SSE = sum((Y - Yh).^2);
    n = size(Y);
    if nargin < 3
        a = 1; % no adjustment
    else
        a = (n-1)/(n-p); % adjusted
    end
    r = 1 - a*SSE/SST;
    
end
