function [isOutOfBoundsFcn, whereOutOfBounds] = boundsFcn(Y, kind, dec, inSpikes)
    if nargin < 2
        kind = 'spikes';
    end
    if nargin < 4
        inSpikes = false;
    end
    
    mns = min(Y);
    mxs = max(Y);
    
    if strcmpi(kind, 'marginal')
        whereOutOfBounds = @(z) isnan(z) | z < mns | z > mxs;
        isOutOfBoundsFcn = @(z) any(whereOutOfBounds(z));        
    elseif strcmpi(kind, 'kde')
        Phatfcn = ksdensity_nd(Y, 1);
        ps = Phatfcn(Y);
        thresh = prctile(ps, 0.05);
        isOutOfBoundsFcn = @(z) Phatfcn(z) < thresh;
        whereOutOfBounds = nan;
    elseif strcmpi(kind, 'hull')
        thresh = 0.001;
        isOutOfBoundsFcn = @(z) mean(arrayfun(@(ii) ...
            all(z < Y(ii,:)) | all(z > Y(ii,:)), 1:size(Y,1))) > thresh;
    elseif strcmpi(kind, 'spikes')
        minSps = 0;
        maxSps = 2*max(mxs);
        
        if inSpikes
            % in spike space already
            whereOutOfBounds = @(u) u < minSps | u > maxSps;
            isOutOfBoundsFcn = @(u) any(whereOutOfBounds(u),2);
            return;
        end

        whereOutOfBounds = @(u) u < minSps | u > maxSps;
        isOutOfBoundsFcn = @(z) any(whereOutOfBounds(...
            tools.latentsToSpikes(z, dec, false, true)),2);

    elseif strcmpi(kind, 'none')
        isOutOfBoundsFcn = @(z) false;
    end
end
