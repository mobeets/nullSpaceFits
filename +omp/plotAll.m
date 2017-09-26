%% load

dts = {'20160415', '20160505', '20160513', '20160529', ...
    '20160617', '20160628'};
for ii = 1:numel(dts)
    dtstr = dts{ii};
    [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr);
    omp.progInNewDims;
    close all;
end
