
dts = io.getDates;
[~,Fs] = plot.getScoresAndFits('Int2Pert_yIme_alltrials', dts);
[Ss_nrm,~] = plot.getScoresAndFits('Int2Pert_yIme', dts);
grpName = 'thetaActualImeGrps';

trSize = 100;
Ss = cell(numel(Fs), 1);
for ii = 1:numel(Fs)
    F = Fs(ii);
    gsBase = F.test.(grpName);
    trs = F.test.trial_index;
    trStarts = min(trs):trSize:max(trs);
    trStarts = trStarts(1:end-1);
    nBins = numel(trStarts);
    ss = [];
        
    for jj = 1:nBins
        trStart = trStarts(jj);
        trEnd = trStart + trSize;
        ix = (trs >= trStart) & (trs <= trEnd);
        
        gsCur = gsBase;
        gsCur(ix) = nan; % so it won't score these timepoints
        F.test.(grpName) = gsCur;
        ss = [ss score.scoreAll(F, grpName)];
    end
    Ss{ii} = ss;
    
    prms = io.setBlockStartTrials(F.datestr);
    css = [ss.scores];
    
    plot.init;
    scoreNms = {'histError', 'meanError', 'covError'};
    nScores = numel(scoreNms);
    nms = unique({css.name});
    for jj = 1:nScores
        subplot(1,3,jj); hold on;
        scNm = scoreNms{jj};
        for kk = 1:numel(nms)
            ix = ismember({css.name}, nms{kk});
            cs = [css(ix).(scNm)];
            plot(trStarts, cs, '-', 'Color', plot.hypColor(nms{kk}));
            
%             bss = Ss_nrm(ii).scores;
%             bss = bss(ismember({bss.name}, nms{kk})).(scNm);
%             plot(xlim, [bss bss], '--', 'Color', plot.hypColor(nms{kk}));
        end        
        
        yl = ylim;
        plot([prms.START_SHUFFLE prms.START_SHUFFLE], yl, 'r-');
        plot([prms.END_SHUFFLE prms.END_SHUFFLE], yl, 'r-');
        ylim(yl);
        xlabel('trial #');
        ylabel(scNm);
    end
    plot.setPrintSize(gcf, struct('width', 9, 'height', 2.5));
    export_fig(gcf, ['data/plots/scoresByTrial/' F.datestr '.pdf']);
    
end
