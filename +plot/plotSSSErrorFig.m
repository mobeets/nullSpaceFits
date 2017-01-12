function plotSSSErrorFig(errs, hypnms, dts, mnkNm, hypsToShow, ...
    doSave, doAbbrev)
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
        doAbbrev = false;
    end

    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, doAbbrev), ...
        hypnms, 'uni', 0);
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

    % plot avg error
    if ~isempty(mnkNm)
        dtInds = io.getMonkeyDateFilter(dts, {mnkNm});
        errs = errs(dtInds,:);
    end
    if ~isempty(hypsToShow)
        hypInds = ismember(hypnms, hypsToShow);
        hypDispNms = hypDispNms(hypInds);
        errs = errs(:,hypInds);
        hypClrs = hypClrs(hypInds,:);
    end

    opts = struct('clrs', hypClrs, 'showZeroBoundary', true, ...
        'ylbl', ['Variance log-ratio' char(10) ...
        '\leftarrow Contraction  Expansion \rightarrow'], ...
        'doBox', false, 'starBaseName', '', 'ymin', nan, ...
        'doSave', doSave, 'filename', 'SSS_avg');
    plot.plotError(errs, hypDispNms, opts);
end
