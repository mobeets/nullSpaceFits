function bnd = getBoundary(dat)
    x = dat(:,1); x = x(~isnan(x));
    y = dat(:,2); y = y(~isnan(y));
    k = boundary(x,y);
    bnd.x = x(k); bnd.y = y(k);
end
