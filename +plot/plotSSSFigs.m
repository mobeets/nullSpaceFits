%% load
fitName = 'Int2Pert_yIme_20180606';
% fitName = 'Pert2Int_yIme_final_20180606';
% fitName = 'Int2Pert_yIme';
exInds = [11 1]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms, es] = plot.getSSS(fitName, exInds);

%% plot avgs

doSave = false;
mnkNms = {};

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
hypsToShow = {'habitual-corrected', 'constant-cloud', 'data'};
cerrs = squeeze(nanmean(log(errs),2));
dtsc = dts(~all(isnan(cerrs),2));
cerrs = cerrs(~all(isnan(cerrs),2),:); % drop nans if all in session
plot.plotSSSErrorFig(cerrs, hypnms, dtsc, mnkNms, hypsToShow, doSave, false);

% [~,exInd] = min((cerrs(:,end) - mean(cerrs(:,end))).^2 + ...
%     (cerrs(:,end-1) - mean(cerrs(:,end-1))).^2);
% % alternatively:
% tmp1 = log(errs(:,:,end));
% tmp2 = log(errs(:,:,end-1));
% [vs,exInds] = min((tmp1 - mean(tmp1(:))).^2 + (tmp2 - mean(tmp2(:))).^2);

%% plot ellipses - data

doSave = false;
hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot ellipses - cloud

doSave = false;
hypClrs = [plot.hypColor('data'); plot.hypColor('constant-cloud')];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'LineWidth', 2, 'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C1s, C2s(:,:,end-1), opts);

%% plot example ellipse - data

doSave = false;
% hypClrs = [plot.hypColor('data'); 0.7*ones(1,3)];
hypClrs = [plot.hypColor('data'); plot.hypColor('constant-cloud')];

hypNmA = 'Output-potent';
hypNmB = 'Output-null';
hypNmA = '';
hypNmB = '';
opts = struct('clrs', hypClrs, 'doSave', doSave, 'LineWidth', 3, ...
    'TextNoteA', hypNmA, 'TextNoteB', hypNmB);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), 6}, opts);
