
dts = {'20120516', '20120525', '20131205', '20160405', '20160722'};
for ii = 5%1:numel(dts)
    dtstr = dts{ii};
    plot.plotCursorTrace(dtstr, 1); title(dtstr);
    plot.plotCursorTrace(dtstr, 2, ...
        struct('maxTracesPerTarget', 5)); title(dtstr);
    plot.plotCursorTrace(dtstr, 3, ...
        struct('maxTracesPerTarget', 5)); title(dtstr);
%     plot.setPrintSize(gcf, struct('width', 6, 'height', 6));
end

%%

params = io.setUnfilteredDefaults;
params.REMOVE_INCORRECTS = false;

dtstr = '20160722';
D = io.quickLoadByDate(dtstr, params);

%%

% params = io.setUnfilteredDefaults;
% params.REMOVE_INCORRECTS = true;
dts = {'20120516', '20120525', '20131205', '20160405', '20160722'};
clrs = cbrewer('div', 'RdYlGn', 8);

for ii = 1:numel(dts)
    dtstr = dts{ii};
%     D = io.quickLoadByDate(dtstr, params);
%     D = dtstr;
    D = io.loadRawDataByDate(dtstr, true);
    D.params = io.setUnfilteredDefaults;
%     D.params.MIN_DISTANCE = 50;
%     D.params.MAX_DISTANCE = 125;
    D.params.REMOVE_INCORRECTS = false;
    [D.blocks, D.trials] = io.getDataByBlock(D);
    close all;

    fnm = fullfile('data', 'plots', 'cursorsWashout', dtstr);
    plot.plotCursorTrace(D, 1, struct('traceColors', clrs));
    title([dtstr '_1']);
    export_fig(gcf, [fnm '_1.pdf']);
    
    plot.plotCursorTrace(D, 1, ...
        struct('maxTracesPerTarget', 5, 'traceColors', clrs, ...
        'showIncorrects', false, 'startAtEnd', true));
    title([dtstr '_1b']);
    export_fig(gcf, [fnm '_1b.pdf']);

    plot.plotCursorTrace(D, 2, ...
        struct('maxTracesPerTarget', 5, 'traceColors', clrs, ...
        'showIncorrects', false));
    title([dtstr '_2a']);
    export_fig(gcf, [fnm '_2a.pdf']);
    
    plot.plotCursorTrace(D, 2, ...
        struct('maxTracesPerTarget', 5, 'traceColors', clrs, ...
        'showIncorrects', false, 'startAtEnd', true));
    title([dtstr '_2b']);
    export_fig(gcf, [fnm '_2b.pdf']);

    plot.plotCursorTrace(D, 3, ...
        struct('maxTracesPerTarget', 5, 'traceColors', clrs, ...
        'showIncorrects', true));
    title([dtstr '_3']);
    export_fig(gcf, [fnm '_3.pdf']);
end
