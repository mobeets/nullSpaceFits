function [ps, vs] = posAndVelFromActivity(Y, M0, M1, M2, gain)
    if nargin < 5
        gain = 45/1000;
    end
    vsd = bsxfun(@plus, Y*M2', M0');
    vs = zeros(size(vsd));
    ps = zeros(size(vsd));
    for ii = 2:size(vsd,1)        
        vs(ii,:) = vsd(ii-1,:) + vs(ii-1,:)*M1;
        ps(ii,:) = ps(ii-1,:) + gain*vs(ii,:);
    end
end
