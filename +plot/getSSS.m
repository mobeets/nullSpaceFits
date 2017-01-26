function [errs, C2s, C1s, Ys, dts, hypnms] = getSSS(fitsName, nCenters, inds)
% inds will return data at inds
    
    % load
    [~,Fs] = plot.getScoresAndFits(fitsName);
    dts = {Fs.datestr};
    hypnms = [{Fs(1).fits.name} 'data'];
    
    % process
    covAreaFcn = @trace;
    errFcn = @(C, Ch) covAreaFcn(Ch)/covAreaFcn(C);
    grps = tools.thetaCenters(nCenters);
    errs = nan(numel(Fs), numel(grps), numel(Fs(1).fits)+1);
    C1s = cell(numel(Fs), numel(grps));
    C2s = cell(numel(Fs), numel(grps), numel(Fs(1).fits)+1);
    Ys = cell(numel(Fs(1).fits)+1, 1);
    for ii = 1:numel(Fs)
        F = Fs(ii);
        Y1 = F.train.latents;
        Y2 = F.test.latents;
        RB = F.train.RB;
        NB = F.test.NB;

        SS0 = (NB*NB')*RB; % when activity became irrelevant
        [SSS,s,v] = svd(SS0, 'econ');
        gs1 = tools.thetaGroup(tools.computeAngles(Y1*RB), grps);
        gs2 = tools.thetaGroup(tools.computeAngles(Y2*RB), grps);

        for jj = 1:numel(grps)
            ix1 = gs1 == grps(jj);
            ix2 = gs2 == grps(jj);
            C1 = nancov(Y1(ix1,:)*SSS);
            C1s{ii,jj} = C1;
            for kk = 1:numel(F.fits)
                C2 = nancov(F.fits(kk).latents(ix2,:)*SSS);
                C2s{ii,jj,kk} = C2;
                errs(ii,jj,kk) = errFcn(C1, C2);
                
                if ii == inds(1) && jj == inds(2)
                    Ys{kk} = F.fits(kk).latents(ix2,:)*SSS;
                end
            end
            C2 = nancov(Y2(ix2,:)*SSS);
            C2s{ii,jj,end} = C2;
            errs(ii,jj,end) = errFcn(C1, C2);
            if ii == inds(1) && jj == inds(2)
                Ys{end} = Y2(ix2,:)*SSS;
            end
        end
    end    
end
