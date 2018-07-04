function plotSSSErrorFig(errs, hypnms, dts, mnkNms, ...
    hypsToShow, doSave, doAbbrev, saveDir, fnm)
    if nargin < 4
        mnkNms = {};
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
    if nargin < 8
        saveDir = 'data/plots';
    end
    if nargin < 9
        fnm = 'SSS_avg';
    end

    hypDispNms = cellfun(@(h) plot.hypDisplayName(h, doAbbrev), ...
        hypnms, 'uni', 0);
    hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

    % plot avg error
    if ~isempty(mnkNms)
        dtInds = io.getMonkeyDateFilter(dts, mnkNms);
        errs = errs(dtInds,:);
    end
    if ~isempty(hypsToShow)
        hypInds = ismember(hypnms, hypsToShow);
        hypDispNms = hypDispNms(hypInds);
        errs = errs(:,hypInds);
        hypClrs = hypClrs(hypInds,:);
    end

    opts = struct('clrs', hypClrs, 'showZeroBoundary', true, ...
        'ylbl', ['Change in variance (log ratio)' char(10) ...
        '\leftarrow Decrease     Increase \rightarrow'], ...
        'width', 4, 'height', 5.5, ...
        'doBox', false, 'starBaseName', '', 'ymin', -3, 'ymax', 3, ...
        'doSave', doSave, 'saveDir', saveDir, 'filename', fnm);
    plot.plotError(errs, hypDispNms, opts);
end
