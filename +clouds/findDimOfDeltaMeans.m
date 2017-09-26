
% saveDir = 'data/plots/cond_change';
% saveDirBehav = 'data/plots/cond_change/behav';
saveDir = '';
saveDirBehav = '';

ps = io.setUnfilteredDefaults;
ps.REMOVE_INCORRECTS = false;

grpNm = 'thetaGrps';
% grpNm = 'targetAngle';
minTm = 5;
maxTm = inf;
tr0 = 25; % number of trials in each early/late epoch

dts = io.getDates;
for ii = 1:numel(dts)
    dts{ii}
    D = io.quickLoadByDate(dts{ii}, ps);
    psc = io.setFilterDefaults(dts{ii});    
    
    behNm = 'progress'; fcn = @max;
%     behNm = 'angErrorAbs'; fcn = @min;
%     tr1 = psc.START_SHUFFLE; tr2 = psc.END_SHUFFLE;
    [tr1, tr2, bs, ts] = clouds.identifyTopLearningRange(D.blocks(2), ...
        tr0, behNm, fcn, minTm, maxTm);
    if (tr1 < min(ts) + tr0)
        warning(['Error: best learning happened early for ' dts{ii}]);
    end
    [tr1 tr2]
    clouds.plotSmoothBehav(D.blocks(2), behNm, ts, bs, minTm, maxTm, ...
        [dts{ii} '-b'], saveDirBehav);
    clouds.plotCursorTraces(D.blocks(2), min(ts), min(ts)+tr0, tr1, tr2, ...
        [dts{ii} '-c'], saveDirBehav);
    if mod(ii,5) == 0
        close all;
    end
    continue;
    
    [lts1, lts2, dEarly, dLate, pcsEarly, pcsLate] = ...
        clouds.findDimOfDeltaMeansSession(D, grpNm, [tr0, tr1, tr2], ...
        minTm, maxTm);
    clouds.plotDimOfDeltaMeans(lts1, lts2, dEarly, dLate, ...
        pcsEarly, pcsLate, dts{ii}, saveDir);
    if mod(ii, 5) == 0
        close all;
    end    
end
