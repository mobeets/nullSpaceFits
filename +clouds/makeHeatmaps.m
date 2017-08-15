D = clouds.loadData('20160722');

% figure; set(gcf, 'color', 'w'); clouds.showHeatmap(D.dat(1), D.ctrs);
% figure; set(gcf, 'color', 'w'); clouds.showHeatmap(D.dat(2), D.ctrs);

%%

opts1 = struct('trBinSz', 0, 'makeSubplots', false, ...
    'doSave', true, 'savePrefix', D.datestr, ...
    'savePostfix', '-3', 'timeRange', [19 30]);
opts2 = opts1; opts2.trBinSz = 20;
close all;

trgs = tools.thetaCenters;
for ii = 1:numel(trgs)
    clouds.showHeatmapSubset(D, 1, trgs(ii), opts1);
    clouds.showHeatmapSubset(D, 2, trgs(ii), opts2);
end
