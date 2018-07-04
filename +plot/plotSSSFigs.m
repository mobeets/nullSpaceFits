%% load

runName = '_20180619';
% fitName = 'Int2Pert_yIme';
% fitName = 'Int2Pert_nIme';
fitName = 'Pert2Int_yIme';
doSave = false;

exInds = [12 1]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms, es] = plot.getSSS([fitName runName], exInds);

saveDir = fullfile('data', 'plots', 'figures', runName, 'SSS');
if doSave && ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

%% plot avgs

doSave = false;
mnkNms = {};

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
% hypsToShow = {'habitual-corrected', 'constant-cloud', 'data'};
cerrs = squeeze(nanmean(log(errs),2));
dtsc = dts(~all(isnan(cerrs),2));
cerrs = cerrs(~all(isnan(cerrs),2),:); % drop nans if all in session
plot.plotSSSErrorFig(cerrs, hypnms, dtsc, mnkNms, ...
    hypsToShow, doSave, false, saveDir, [fitName '_avg']);

% report avg
if strcmpi(hypnms{end}, 'data')
    disp(['Avg. change in variance (data): ' ...
        sprintf('%0.2f', nanmean(cerrs(:,end)))]);
    [h,p,ci] = ttest(cerrs(:,end));
    disp(['P-value for whether data are not = 0: ' ...
        sprintf('%0.2f', p)]);
end
if strcmpi(hypnms{end-1}, 'constant-cloud')
    disp(['Avg. change in variance (constant-cloud): ' ...
        sprintf('%0.2f', nanmean(cerrs(:,end-1)))]);
    [h,p,ci] = ttest(cerrs(:,end-1));
    disp(['P-value for whether constant-cloud is not = 0: ' ...
        sprintf('%0.2f', p)]);
end

% for selecting example session/target:
% dataErr = cerrs(:,end);
% avgDataErr = nanmean(dataErr);
% [~,ix] = sort((dataErr - avgDataErr).^2);

%% plot ellipses - data

doSave = false;
hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts), ...
    'saveDir', saveDir, 'filename', [fitName '_ellipses']);
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot example ellipse - data

doSave = true;
hypClrs = [plot.hypColor('data'); 0.7*ones(1,3)];
% hypClrs = [plot.hypColor('data'); plot.hypColor('constant-cloud')];

hypNmA = 'Output-potent';
hypNmB = 'Output-null';
hypNmA = '';
hypNmB = '';
opts = struct('clrs', hypClrs, 'doSave', doSave, 'LineWidth', 3, ...
    'TextNoteA', hypNmA, 'TextNoteB', hypNmB, 'MarkerSize', 10, ...
    'saveDir', saveDir, 'filename', [fitName '_example']);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), 6}, opts);

%% plot ellipses - cloud

doSave = false;
hypClrs = [plot.hypColor('data'); plot.hypColor('constant-cloud')];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts), ...
    'saveDir', saveDir, 'filename', [fitName '_cloud']);
plot.plotSSSEllipseFig(C1s, C2s(:,:,end-1), opts);
