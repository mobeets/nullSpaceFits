function [X,Y,Yp,ixGood] = makeDesignMat(B, trialRange, timeRange)
    if nargin < 2
        trialRange = [];
    end
    if nargin < 3
        timeRange = [];
    end

    % Y = [B.Yn B.Yr];
    Y = B.latents;
    Yp = Y(1:end-1,:);
    Y = Y(2:end,:);
    ix = diff(B.time) == 1;
    Yp(~ix,:) = 0; % history is null when time steps aren't sequential
    
    ixGood = ~any(isnan(Y),2);
    if ~isempty(trialRange)
        trs = B.trial_index;
        ixtr = trs >= trialRange(1) & trs <= trialRange(2);
        ixGood = ixGood & ixtr(2:end);
    end
    if ~isempty(timeRange)
        tms = B.time;
        ixtm = tms >= timeRange(1) & tms <= timeRange(2);
        ixGood = ixGood & ixtm(2:end);
    end

    X1 = B.trial_index;
    X2 = B.time;
    trgs = bsxfun(@minus, B.target, mean(unique(B.target, 'rows')));
    trgAngGrp = round(tools.computeAngles(trgs))/45 + 1;
    ngrps = max(trgAngGrp);
    X3 = zeros(size(trgAngGrp,1), ngrps);
    for ii = 1:ngrps
        X3(trgAngGrp == ii,ii) = 1;
    end
    X4 = B.thetas;
    X4 = [cosd(X4) sind(X4)];
    X4p = X4(1:end-1,:);
    X4p(~ix,:) = 0;
    X4 = X4(2:end,:);
    
    X = [X1(2:end,:) X2(2:end,:) X3(2:end,:) X4 X4p];
%     X = X(2:end,:);

    X = X(ixGood,:);
    Y = Y(ixGood,:);
    Yp = Yp(ixGood,:);

end
