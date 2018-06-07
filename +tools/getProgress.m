function p = getProgress(y, curPos, trgPos, vfcn, v)
    if nargin < 5
        v = vfcn(y);
    end
    goal = trgPos - curPos;
    nrm = sqrt(sum(goal.*goal,2));
    goal = bsxfun(@times, goal, 1./nrm);
    [nt1, nd1] = size(v);
    [nt2, nd2] = size(goal);
    assert((nt1 == nt2) & (nd1 == nd2));
    p = sum(v.*goal, 2);
end
