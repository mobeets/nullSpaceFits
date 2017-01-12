%% init

% fitType = 'Int2Int_nIme';
% fitType = 'Int2Pert_nIme';
% fitType = 'Int2Pert_yIme';
fitType = 'Int2Pert_yIme2';
% fitType = 'Pert2Int_yIme';
fitsDir = fullfile('data', ['fits_' fitType]);

%% load scores

S = plot.loadScoresAndFits(fitsDir);
dts = {S.datestr};
hypnms = {S(1).scores.name};
hypDispNms = cellfun(@plot.hypDisplayName, hypnms, 'uni', 0);
hypClrs = cell2mat(cellfun(@plot.hypColor, hypnms, 'uni', 0)');

%% avg error

errNm = 'covError';
mnkNm = 'Nelson';
% hypsToShow = {'minimum', 'baseline', 'best-mean', 'uncontrolled-uniform'};
hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};

dtInds = io.getMonkeyDateFilter(dts, {mnkNm});
hypInds = cellfun(@(c) find(ismember(hypnms, c)), hypsToShow);
errs = plot.getScoreArray(S, errNm, dtInds, hypInds);
if strcmpi(errNm, 'histError')
    errs = 100*errs;
    ymax = 100;
    errDispNm = 'Histograms';
    lblDispNm = 'histograms (%)';
elseif strcmpi(errNm, 'meanError')
    errDispNm = 'Mean';
    lblDispNm = 'mean';
    ymax = 15;
else
    errDispNm = 'Covariance';
    lblDispNm = 'covariance';
    ymax = 15;
end
mnkTitle = ['Monkey ' mnkNm(1)];
% title = ['Error in ' errDispNm ', ' mnkTitle];
ttl = [errDispNm ', ' mnkTitle];
% title = mnkTitle;
fnm = [errNm '_' fitType '_' mnkNm(1)];
opts = struct('doSave', false, 'filename', fnm, ...
    'width', 4, ...
    'ylbl', ['Avg. error in ' lblDispNm], ...
    'title', ttl, 'ymax', ymax, ...
    'clrs', hypClrs(hypInds,:));
% close all;
plot.plotAvgError(errs, hypDispNms(hypInds), opts);
% breakyaxis([22 41]);
