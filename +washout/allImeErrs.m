function [stats, scores] = allImeErrs(dtstr)
    opts = struct('doLatents', true, 'TAU', 3, 'TARGET_RADIUS', 20+18);
    params = io.setUnfilteredDefaults();
%     params = io.updateParams(params, io.setBlockStartTrials(dtstr), true);
    doRotate = false;
    D = io.quickLoadByDate(dtstr, params, doRotate);
    
    stats = cell(numel(D.ime), numel(D.blocks));
    scores = stats;
    for ii = 1:numel(D.ime)
        for jj = 1:numel(D.blocks)
            stats{ii,jj} = imefit.imeStats(D.blocks(jj), D.ime(ii), opts);
            scores{ii,jj} = imeScores(stats{ii,jj}.by_trial);
        end
    end
end

function stats = imeScores(by_trial)
    scale = 1.96/sqrt(numel(by_trial.cErrs));
    cErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrAvg = nanmean(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    cErrMed = nanmedian(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrMed = nanmedian(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    cErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.cErrs));
    mErrStd = scale*nanstd(cellfun(@(e) nanmean(abs(e)), by_trial.mdlErrs));
    stats = [cErrAvg mErrAvg cErrStd mErrStd cErrMed mErrMed];
end
