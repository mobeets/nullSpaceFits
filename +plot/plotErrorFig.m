function errs = plotErrorFig(fitName, runName, errNm, mnkNm, hypsToShow, ...
    doSave, doAbbrev, showYLabel, showMnkNm, errFloor)
    if nargin < 4
        mnkNm = '';
    end
    if nargin < 5
        hypsToShow = {};
    end
    if nargin < 6
        doSave = false;
    end
    if nargin < 7       
        doAbbrev = false; % abbreviate x-axis names
    end
    if nargin < 8
        showYLabel = true;
    end
    if nargin < 9
        showMnkNm = true; 
    end
    if nargin < 10
        errFloor = nan;
    end
    hypNmForSignificance = 'constant-cloud';
%     hypNmForSignificance = 'habitual-corrected';
    
    % if abbreviated, shorten figure
    if doAbbrev
        hght = 4;
    else
        hght = 5.5;
    end    
    
    % load scores
    S = plot.getScoresAndFits([fitName runName], io.getDates);
    dts = {S.datestr};
    hypnms = {S(1).scores.name};
    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, doAbbrev), ...
        hypnms, 'uni', 0);
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

    % plot avg error
    if ~isempty(mnkNm)
        dtInds = io.getMonkeyDateFilter(dts, {mnkNm});
    else
        dtInds = 1:numel(dts);
    end
    if ~isempty(hypsToShow)
        hypInds = cellfun(@(c) find(ismember(hypnms, c)), hypsToShow);
    else
        hypInds = 1:numel(hypnms);
    end
    if ismember(hypNmForSignificance, hypnms(hypInds))
        starBaseName = plot.hypDisplayName(hypNmForSignificance, doAbbrev);
    else
        starBaseName = '';
    end
    errs = plot.getScoreArray(S, errNm, dtInds, hypInds);
    errs = errs(~any(isinf(errs),2),:);
    if strcmpi(errNm, 'histError')
        errs = 100*errs;
        ymax = 105;
        lblDispNm = 'histograms (%)';
    elseif strcmpi(errNm, 'meanError')        
        errs = (1000/45)*errs;
        ymax = (1000/45)*16;
        lblDispNm = 'mean (spikes/s)';
    else
        lblDispNm = 'covariance (a.u.)';
        ymax = 11;
    end
    
    % no ylabel, shrink figure
    if ~showYLabel        
        ylbl = '';
        if doAbbrev
            wdth = 3.7;
        else
            wdth = 4;
        end
    else
        wdth = 4;
        ylbl = ['Error in ' lblDispNm];
    end
    if ~isempty(mnkNm) && showMnkNm
        mnkTitle = ['Monkey ' mnkNm(1)];
    else
        mnkTitle = '';
    end
    ttl = '';
    if ~isempty(mnkNm)
        fnm = [errNm '_' fitName '_' mnkNm(1)];
    else
        fnm = [errNm '_' fitName '_ALL'];
    end
    saveDir = fullfile('data', 'plots', 'figures', runName, 'errors');
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    opts = struct('doSave', doSave, 'filename', fnm, ...
        'saveDir', saveDir, ...
        'width', wdth, 'height', hght, ...
        'doBox', true, ...
        'starBaseName', starBaseName, ...
        'ylbl', ylbl, ...
        'title', ttl, 'ymax', ymax, ...
        'TextNote', mnkTitle, ...
        'errFloor', errFloor, ...
        'clrs', hypClrs(hypInds,:));
    plot.plotError(errs, hypDispNms(hypInds), opts);
end
