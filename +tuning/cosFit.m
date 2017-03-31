function theta = cosFit(x, y)
% x in degrees
% y the mean value
% returns params of the best cosine fit:
%     [modulationDepth preferredDirection(deg) offset]
%
    cosfit = @(th, x) th(1) .* cosd(x - th(2)) + th(3);
    
    ix = ~isnan(y); x = x(ix); y = y(ix);

    % initial guess
    theta0 = [max(abs(y)) 0 mean(y)];
    [~,ind] = max(y); theta0(2) = x(ind);
    
    lb = [0, 0, -inf];
    ub = [inf, 360, inf];
    options = optimset('Display', 'off');
    theta = lsqcurvefit(cosfit, theta0, x, y, lb, ub, options);

%     if theta(1) < 0
%         yh = cosfit(theta, x);
%         plot.init;
%         plot(x, y, 'o-');
%         plot(x, yh, 'o-');
%         x=1;
%     end
end
