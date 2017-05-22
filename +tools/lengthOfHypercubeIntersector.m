function l = lengthOfHypercubeIntersector(p)
    if size(p,1) == 1
        p = p';
    end
    p = abs(p); % sign doesn't matter
    d = size(p,1);
    p0 = zeros(size(p));

    vs = eye(d);
    for ii = 1:d
        [v, check] = tools.planeLineIntersect(vs(:,ii), vs(:,ii), p0, p);
        assert(check ~= 1, 'p lies in the hypercube...should not happen');
        if check == 0 % no intersection
            continue;
        end
        if all(v >= 0) && all(v <= 1) % intersection in hypercube
            l = norm(v);
            return;
        end
    end
    l = nan;
end
