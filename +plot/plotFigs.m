%% init

fitsDir = 'data/fits_Int2Int_nIme';

%% load scores

S = plot.loadScoresAndFits(fitsDir);
dts = {S.datestr};
hypnms = {S(1).scores.name};
hypDispNms = cellfun(@plot.hypDisplayName, hypnms, 'uni', 0);
hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

%% avg error

errNm = 'histError';
mnkNm = 'Lincoln';
hypsToShow = {'minimum', 'baseline', 'best-mean', 'uncontrolled-uniform'};
% hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
%     'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
ymax = nan;

dtInds = io.getMonkeyDateFilter(dts, {mnkNm});
hypInds = cellfun(@(c) find(ismember(hypnms, c)), hypsToShow);
errs = plot.getScoreArray(S, errNm, dtInds, hypInds);
if strcmpi(errNm, 'histError')
    errs = 100*errs;
    ymax = 100;
    errDispNm = 'histograms';
elseif strcmpi(errNm, 'meanError')
    errDispNm = 'mean';
else
    errDispNm = 'covariance';
end
opts = struct('doSave', true, 'filename', [errNm '_11_' mnkNm(1)], ...
    'width', 5, ...
    'ylbl', ['Avg. error in ' errDispNm], ...
    'title', ['Error in ' errDispNm ', Monkey ' mnkNm(1)], 'ymax', ymax, ...
    'clrs', hypClrs(hypInds,:));
close all;
plot.plotAvgError(errs, hypDispNms(hypInds), opts);
