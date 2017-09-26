function plotSmoothBehav(B, behNm, ts, bs, minTm, maxTm, fnm, saveDir)
    if nargin < 6
        saveDir = '';
    end
    plot.init;
    ix = B.time > minTm & B.time < maxTm;
    beh = B.(behNm);
    trs = grpstats(B.trial_index(ix), B.trial_index(ix));
    beh = grpstats(beh(ix), B.trial_index(ix));
    plot(trs, beh, '.');
%     plot(B.trial_index(ix), beh(ix), '.');
    plot(ts, bs, '.-');
    xlabel('trial #');
    ylabel(['smoothed behavior (' behNm ')']);
    
    popts = struct('width', 5, 'height', 5, 'margin', 0.25);
    plot.setPrintSize(gcf, popts);
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [fnm '.pdf']);
        export_fig(gcf, fnm);
    end
end
