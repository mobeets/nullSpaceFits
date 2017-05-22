
dtstr = '20160722';
params = io.setUnfilteredDefaults();
params = io.updateParams(params, io.setBlockStartTrials(dtstr), true);
doRotate = false;
D = io.quickLoadByDate(dtstr, params, doRotate);

%%

opts = struct('doLatents', true, 'TAU', 3, 'TARGET_RADIUS', 20+18);
sI = imefit.imeStats(D.blocks(3), D.ime(1), opts);
sP = imefit.imeStats(D.blocks(3), D.ime(2), opts);
sI_0 = imefit.imeStats(D.blocks(1), D.ime(1), opts);
sP_0 = imefit.imeStats(D.blocks(1), D.ime(2), opts);
sI_1 = imefit.imeStats(D.blocks(2), D.ime(1), opts);
sP_1 = imefit.imeStats(D.blocks(2), D.ime(2), opts);

%%

imefit.plotImeStats(D, 3, sI.mdlErrs, sI.cErrs, sI.by_trial);
imefit.plotImeStats(D, 3, sP.mdlErrs, sP.cErrs, sP.by_trial);

%%

dts = io.getDates;
% dts = {'20120516', '20120525', '20131205', '20160405', '20160722'};
% dts = {'20120323', '20120403', '20160714', '20160727', '20160810'};
stats = cell(numel(dts),1);
scores = stats;
for ii = 1:numel(dts)
    dtstr = dts{ii}
    [stats{ii}, scores{ii}] = washout.allImeErrs(dtstr);
end

%%

for ii = 1%:numel(dts)
    washout.plotBlockErrors(stats{ii}, dts{ii});
end

%%

close all;
popts = struct('doSave', true, 'saveDir', '+washout/data/imeErrs', ...
    'ext', 'pdf', 'width', 7, 'height', 4);
scs = nan(numel(dts),3,3);
for ii = 1:numel(dts)
    cstats = washout.allImeErrs(dts{ii});
    ys = washout.plotBlockErrors(cstats, dts{ii});    
%     ys = washout.plotBlockErrors(stats{ii}, dts{ii});
    scs(ii,:,:) = cellfun(@median, ys);
    pcts = 100*(scs(:,1,3) - scs(:,3,3))./scs(:,1,3);
    [nanmedian(pcts) pcts(ii)]
    plot.setPrintSize(gcf, popts);    
    if popts.doSave
        fnm = dts{ii};
        export_fig(gcf, fullfile(popts.saveDir, ...
            [fnm '.' popts.ext]));
    else
        pause(0.1);
    end
end

%%

close all;

xpct = scs(:,1,3);
ypct = scs(:,3,3);

xpct = scs(:,2,2) - scs(:,1,2);
ypct = scs(:,3,2) - scs(:,2,2);

xpct = scs(:,2,2) - scs(:,1,2);
ypct = scs(:,3,3) - scs(:,1,3);

plot.init; plot(xpct, ypct, 'ko');
plot(xlim, [0 0], 'k--');
xlabel({'Predicted amount of washout', ...
    '(Int. IME error during Pert. - Int.)'});
ylabel({'Amount of memory trace', ...
    '(Pert. IME error in Wash. - Int.)'});
% xlim([-1 1]); ylim([-1 1]);
