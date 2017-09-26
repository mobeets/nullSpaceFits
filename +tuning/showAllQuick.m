

err = nan(numel(Fs), 10);
for ii = 1:numel(Fs)
    F = Fs(ii);
    dec = F.test;
    NB = dec.NB;
    RB = dec.RB;
    
    B = F.train;
    Y = B.latents;
    Y = [Y*RB Y*NB];
%     vs = bsxfun(@plus, Y*dec.M2', dec.M0');
%     vs = ((eye(size(dec.M1)) - dec.M1)\vs')';
%     gs = tools.thetaGroup(tools.computeAngles(vs), tools.thetaCenters);
    gs = tools.thetaGroup(B.thetas, tools.thetaCenters);
    gs(isnan(gs)) = -1;
    gs(B.time < 6) = -1;
    yt = grpstats(Y, gs);
    if sum(gs == -1) > 0
        yt = yt(2:end,:);
    end
    y1 = yt;
    
    B = F.test;
    Y = B.latents;
    Y = [Y*RB Y*NB];
%     vs = bsxfun(@plus, Y*dec.M2', dec.M0');
%     vs = ((eye(size(dec.M1)) - dec.M1)\vs')';
%     gs = tools.thetaGroup(tools.computeAngles(vs), tools.thetaCenters);
    gs = tools.thetaGroup(B.thetas, tools.thetaCenters);
    gs(isnan(gs)) = -1;
    gs(B.time < 6) = -1;
    yt = grpstats(Y, gs);
    if sum(gs == -1) > 0
        yt = yt(2:end,:);
    end
    y2 = yt;
    
    err(ii,:) = sum((y2 - y1).^2);
end

%%

% err_pot = err;
% err_ths = err;
err1 = sqrt(sum(err_ths,2));
err2 = sqrt(sum(err_pot,2));

plot.init;
plot(err1, err2, 'o');
vmn = 0;
vmx = max(max([err1 err2]));
xlim([vmn vmx]); ylim(xlim);
xlabel('tuning change, using thetas');
ylabel('tuning change, using cursor angle under pert. decoder');
title(sprintf('corr = %0.2f', corr(err1, err2)));
