function [isGood, ixs, xsb, ysb, ysv, opts, ysv2, ysv3] = assessBehavior(D, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('muThresh', 0.5, 'varThresh', 0.5, ...
        'trialsInARow', 10, 'groupEvalFcn', @numel, ...
        'blockIndex', 2, 'xName', 'trial_index', ...
        'minGroupSize', 100, 'smoothBinSz', 150, ...
        'varBinSz', 100, 'behavNm', 'trial_length');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % load data    
    B = D.blocks(opts.blockIndex);
    xs = B.(opts.xName);
    ys = B.(opts.behavNm);
    if strcmpi(opts.behavNm, 'progress')
        ys = -ys;
    end
    
    % get mean value per trial
    xsb = unique(xs);
    ysb0 = grpstats(ys, xs);
    if numel(ysb0) < opts.smoothBinSz
        warning('Not enough trials to smooth.');
        isGood = []; ixs = {}; xsb = []; ysb = []; ysv = []; return;
    end
    
    % get smoothed mean and smoothed running var
    ysb = smooth(xsb, ysb0, opts.smoothBinSz);
    ysv = runningVar(ysb, opts.varBinSz);
    
    % normalize mean and var to be in [0,1]
    ymn = nanmin(ysb(26:end-10));
    ymx = max(ysb(1:25));
    ysb = normToZeroOne(ysb, ymn, ymx);
    vmn = nanmin(ysv);
    vmx = nanmax(ysv(1:ceil(numel(ysv)/2)));
    ysv = normToZeroOne(ysv, vmn, vmx);
    ysv2 = runningVar(ysb, opts.varBinSz);
    ysv3 = runningVar(ysb0, opts.smoothBinSz);
    
    % find best set of consecutive trials below threshold for mean and var
    ix1 = ysb <= opts.muThresh;
    ix2 = ysv <= opts.varThresh;
    ix = ix1 & ix2;
    ix1 = findBestRun(xsb, ysb, ix1, opts.groupEvalFcn, opts.trialsInARow);
    ix2 = findBestRun(xsb, ysb, ix2, opts.groupEvalFcn, opts.trialsInARow);
    ix = findBestRun(xsb, ysb, ix, opts.groupEvalFcn, opts.trialsInARow);
    ixs = {ix, ix1, ix2};
    
    isGood = [];
    isGood(1) = numel(ysb(~isnan(ysb))) > 0;
    isGood(2) = true; % tTestOfBestAgainstFirst(ysb, Ysc) <= 0.05;
    if sum(ix) == 0
        isGood(3) = false;
    else
        isGood(3) = max(xsb(ix))-min(xsb(ix)) >= opts.minGroupSize;
    end
    
%     ms = runningCalc(ysb0, opts.smoothBinSz, @nanmean);
%     msl = runningCalc(ysb0, opts.smoothBinSz, @(v) prctile(v, 25));
%     msu = runningCalc(ysb0, opts.smoothBinSz, @(v) prctile(v, 75));
%     plot.init;
%     plot(xsb, smooth(xsb, ysb0, opts.smoothBinSz));
%     plot(xsb, ysb0, '.');
%     plot(xsb, ms, 'k-');
%     plot(xsb, msl, 'k-');
%     plot(xsb, msu, 'k-');
%     ylim([0 1.2*ceil(max(msu))]);
%     yl = ylim;
%     plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
%         'r-', 'LineWidth', 2);
%     
end

function vs = runningCalc(x, m, fcn)
    vs = nan(numel(x),1);
    d = floor(m/2);
    for ii = d:numel(x)-d
        vs(ii) = fcn(x(ii-d+1:ii+d));
    end
end

function v = runningVar(x, m)
    n=size(x,1);
    f=zeros(m,1)+1/m;
    v=filter2(f,x.^2,'valid')-filter2(f,x,'valid').^2;
    m2=floor(m/2);
    n2=ceil(m/2)-1;
    v=v([zeros(1,m2)+m2+1,(m2+1):(n-n2),zeros(1,n2)+(n-n2)]-m2,:);
    assert(isequal(numel(v), numel(x)));
end

function ixBest = findBestRun(xs, ys, ix, evalFcn, trialsInARow)
    % for groups of consecutive xs, find best set of corresponding ys
    xsc = xs(ix);
    ysc = ys(ix);
    temp = abs(diff(xsc));
    inds = [1 find(temp > trialsInARow)' numel(xsc)];
    ymx = -inf;
    bestInds = [];
    for kk = 2:numel(inds)
       ixc = (inds(kk-1)+1):inds(kk);
       ycur = evalFcn(ysc(ixc));
       if ycur > ymx
           ymx = ycur;
           bestInds = ixc;
       end
    end
    
    % make mask same size as ix, but with bestInds marked
    yx = double(ix);
    yx(ix>0) = 1:sum(ix>0);
    ixBest = ismember(yx, bestInds);
end

function vs = normToZeroOne(vs, mn, mx)
    vs = (vs - mn)./(mx - mn);
end
