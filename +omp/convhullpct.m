function [K,V] = convhullpct(X,FRACTION_ENCLOSED)
% [K,V] = convhullpct(X,FRACTION_ENCLOSED)
%
% Outlier-robust version of Matlab's convhull. 
%
% INPUTS:
%
% X is of size mpts-by-ndim, where mpts is the number of points and ndim is
% the dimension of the space where the points reside, 2 <= ndim <= 3.
%
% FRACTION_ENCLOSED is the fraction of points to enclose in the resulting
% convex hull. Using values less than 1 reduces the hull's sensitivity to 
% extremal values. When FRACTION_ENCLOSED<1, the appropriate number of
% points will be dropped from the hull. Those points are chosen by
% computing successive convex hulls over the points that have not been
% dropped. At each iteration, all points on the current convex hull are
% dropped. If doing so would result in too many points being dropped, those
% furthest from the mean of the original data are dropped first until the
% correct number of points have been dropped. Distances are Mahalanobis
% relative to the covariance of the original data.
%
% OUTPUTS:
%
% K represents the outlier-robust convex hull as a a vector of indices into
% X. The points on the hull can be recovered using X(K,:).
%
% V is the volume bounded by the convex hull.
%
% See also convhull
%
% @ Matt Golub, December 2016. Version 1.0

% Find indices of points on perimeter of convex hull
activeSetIdx = convhull(X);
Xhull = X(activeSetIdx,:);

% Matlab returns a duplicate point for plotting purposes.
% Get rid of it so it doesn't throw off the count of points to
% drop.
if activeSetIdx(1)==activeSetIdx(end) && length(activeSetIdx)>1
    activeSetIdx = activeSetIdx(1:end-1);
    Xhull = Xhull(1:end-1,:);
end

if FRACTION_ENCLOSED<1
    nX = size(X,1);
    nRemainingToDrop = round((1-FRACTION_ENCLOSED)*nX);
    m = mean(X,1);
    C = cov(X,1);
    Xc = bsxfun(@minus,X,m);
    d = sqrt(sum(Xc'.*(inv(C)*Xc'))'); % Mahalanobis distances from the mean
    Xkeep = X; % Begin with all points
    
    while nRemainingToDrop>0
        % If current hull is defined by fewer points than are remaining to
        % drop, drop all the points on the perimeter of the current hull.
        if length(activeSetIdx)<=nRemainingToDrop
            Xkeep(activeSetIdx,:) = [];
            d(activeSetIdx) = [];
            nRemainingToDrop = nRemainingToDrop - length(activeSetIdx);
        else
            % If dropping all points defining the current hull would result
            % in dropping too many points, drop points in order by
            % Mahalanobis distance from the mean, relative to the covariance
            % of the original (i.e., complete) data.
            activeSetDistances = d(activeSetIdx);
            [sortedActiveSetDistances,sortedActiveSetIdx] = sort(activeSetDistances,'descend');
            dropIdx = activeSetIdx(sortedActiveSetIdx(1:nRemainingToDrop));
            Xkeep(dropIdx,:) = [];
            d(dropIdx) = [];
            nRemainingToDrop = 0;
        end
        
        [activeSetIdx, V] = convhull(Xkeep);
        Xhull = Xkeep(activeSetIdx,:);
        
        % Get rid of the duplicate point (see comment above)
        if activeSetIdx(1)==activeSetIdx(end) && length(activeSetIdx)>1
            activeSetIdx = activeSetIdx(1:end-1);
            Xhull = Xhull(1:end-1,:);
        end
    end
end

% Find indexes of hull points in X (to match output format of convhull)
nHull = length(activeSetIdx);
K = nan(nHull,1);
for n = 1:nHull
    idx = find(all(bsxfun(@eq,X,Xhull(n,:)),2),1,'first');
    if ~isempty(idx)
        K(n) = idx;
    else
        warning('Hull point does not match any points in the input X.');
    end
end
K(end) = K(1); % Add back the duplicate point to conform to Matlab convention