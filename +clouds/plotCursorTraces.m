function plotCursorTraces(B, tr1, tr2, tr3, tr4, fnm, saveDir)
    if nargin < 7
        saveDir = '';
    end
    
    mu = mean(unique(B.target, 'rows'));
    B.target = bsxfun(@minus, B.target, mu);
    B.pos = bsxfun(@minus, B.pos, mu);
    mxv = 1.5*max(abs(B.target(:)));
    
    plot.init;    
    
    subplot(1,2,1); hold on;
    showTrialTraces(B.pos, B.trial_index, B.targetAngle, tr1:tr2);
    xlim([-mxv mxv]); ylim(xlim);
    
    subplot(1,2,2); hold on;
    showTrialTraces(B.pos, B.trial_index, B.targetAngle, tr3:tr4);
    xlim([-mxv mxv]); ylim(xlim);
    
    popts = struct('width', 8, 'height', 4, 'margin', 0.25);
    plot.setPrintSize(gcf, popts);
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [fnm '.pdf']);
        export_fig(gcf, fnm);
    end

end

function showTrialTraces(pos, trs, trgs, ts)
    grps = sort(unique(trgs));
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    for t = ts
        ix = (trs == t);
        posc = pos(ix,:);
        clr = clrs(grps == mode(trgs(ix,:)),:);
        plot(posc(:,1), posc(:,2), '-', 'Color', clr);
    end
    axis square;
end
