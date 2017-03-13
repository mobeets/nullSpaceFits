function errs = plotErrorFig(fitName, errNm, mnkNm, hypsToShow, ...
    doSave, doAbbrev, showYLabel)
    if nargin < 3
        mnkNm = '';
    end
    if nargin < 4
        hypsToShow = {};
    end
    if nargin < 5
        doSave = false;
    end
    if nargin < 6        
        doAbbrev = false; % abbreviate x-axis names
    end
    if nargin < 7
        showYLabel = true;
    end
    
    % if abbreviated, shorten figure
    if doAbbrev
        hght = 4;
    else
        hght = 5.5;
    end    
    
    % load scores
    S = plot.getScoresAndFits(fitName);
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
    if ismember('constant-cloud', hypnms(hypInds))
        starBaseName = plot.hypDisplayName('constant-cloud', doAbbrev);
    else
        starBaseName = '';
    end
    errs = plot.getScoreArray(S, errNm, dtInds, hypInds);
    errs = errs(~any(isinf(errs),2),:);
    if strcmpi(errNm, 'histError')
        errs = 100*errs;
        ymax = 105;
        errDispNm = 'histograms (%)';
        lblDispNm = 'histograms (%)';
    elseif strcmpi(errNm, 'meanError')
        errDispNm = 'mean';
        lblDispNm = 'mean';
        ymax = 16;
    else
        errDispNm = 'covariance';
        lblDispNm = 'covariance';
        ymax = 11;
%         ymax = 70;
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
    if ~isempty(mnkNm)
        mnkTitle = ['Monkey ' mnkNm(1)];
    else
        mnkTitle = '';
    end
    % title = ['Error in ' errDispNm ', ' mnkTitle];
%     ttl = [errDispNm ', ' mnkTitle];
%     ttl = ['Error in ' errDispNm];
    ttl = '';
    % title = mnkTitle;
    if ~isempty(mnkNm)
        fnm = [errNm '_' fitName '_' mnkNm(1)];
    else
        fnm = [errNm '_' fitName '_ALL'];
    end
    opts = struct('doSave', doSave, 'filename', fnm, ...
        'width', wdth, 'height', hght, ...
        'doBox', true, ...
        'starBaseName', starBaseName, ...
        'ylbl', ylbl, ...
        'title', ttl, 'ymax', ymax, ...
        'TextNote', mnkTitle, ...
        'clrs', hypClrs(hypInds,:));
    % close all;
    plot.plotError(errs, hypDispNms(hypInds), opts);
    % breakyaxis([22 41]);
end
