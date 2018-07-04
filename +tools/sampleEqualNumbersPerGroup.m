function [ix1, ix2, N] = sampleEqualNumbersPerGroup(gs1, gs2, N)
    if nargin < 3
        N1 = min(grpstats(gs1, gs1, @numel));
        N2 = min(grpstats(gs2, gs2, @numel));
        N = min([N1 N2]);
    end
    ix1 = getIxPerGroupGivenN(gs1, N);
    ix2 = getIxPerGroupGivenN(gs2, N);
end

function ix = getIxPerGroupGivenN(gs, N)
    ix = false(size(gs,1),1);
    grps = unique(gs(~isnan(gs)));
    for ii = 1:numel(grps)
        ixc = gs == grps(ii);
        assert(sum(ixc) >= N, 'Not enough ix to start');
        inds = rand(sum(ixc), 1);
        [~,ir] = sort(inds);
        indsAll = find(ixc);
        indsToKeep = indsAll(ir(1:N));
        assert(numel(indsToKeep) == N, 'Wrong # left');
        ix(indsToKeep) = true;
    end
end
