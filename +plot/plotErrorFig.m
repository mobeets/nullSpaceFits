function errs = plotErrorFig(fitName, errNm, mnkNm, hypsToShow, ...
    doSave, doAbbrev)
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
        % abbreviate names
        if strcmpi(errNm, 'covError')
            doAbbrev = false;
        else
            doAbbrev = true;
        end
    end
    
    % if abbreviated, shorten figure
    if doAbbrev
        hght = 4;
    else
        hght = 5.5;
    end
    
    % load scores
    fitsDir = fullfile('data', ['fits_' fitName]);
    S = plot.loadScoresAndFits(fitsDir);
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
    if strcmpi(errNm, 'histError')
        errs = 100*errs;
        ymax = 100;
        errDispNm = 'histograms (%)';
        lblDispNm = 'histograms (%)';
    elseif strcmpi(errNm, 'meanError')
        errDispNm = 'mean';
        lblDispNm = 'mean';
        ymax = 17;
    else
        errDispNm = 'covariance';
        lblDispNm = 'covariance';
        ymax = 11;
    end
    mnkTitle = ['Monkey ' mnkNm(1)];
    % title = ['Error in ' errDispNm ', ' mnkTitle];
%     ttl = [errDispNm ', ' mnkTitle];
    ttl = ['Error in ' errDispNm];
    % title = mnkTitle;
    fnm = [errNm '_' fitName '_' mnkNm(1)];
    opts = struct('doSave', doSave, 'filename', fnm, ...
        'width', 4, 'height', hght, ...
        'starBaseName', starBaseName, ...
        'ylbl', ['Avg. error in ' lblDispNm], ...
        'title', ttl, 'ymax', ymax, ...
        'TextNote', ['Monkey ' mnkNm(1)], ...
        'clrs', hypClrs(hypInds,:));
    % close all;
    plot.plotError(errs, hypDispNms(hypInds), opts);
    % breakyaxis([22 41]);
end
