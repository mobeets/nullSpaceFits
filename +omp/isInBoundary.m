function isIn = isInBoundary(pt, pts)
    newPts = [pts; pt];
    % note: going to assume we've already ensured pt is not in pts
%     if sum(bsxfun(@minus, pts, pt).^2,2) < eps % if pt already in pts
%         isIn = true;
%         return;
%     end
    % if the added pt is not part of the new boundary, it isIn
    isIn = max(boundary(newPts(:,1), newPts(:,2))) == size(newPts,1);
end
