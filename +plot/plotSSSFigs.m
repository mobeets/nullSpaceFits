%% load
% fitName = 'Int2Pert_yIme_final';
fitName = 'Int2Pert_yIme_20170605';
% fitName = 'Int2Pert_yIme';
exInds = [13 1]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms, es] = plot.getSSS(fitName, exInds);

%% plot avgs

doSave = false;
mnkNms = {};

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
% hypsToShow = {};
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
    'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot example ellipse - data

doSave = false;
hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
% hypClrs = [plot.hypColor('data'); [17, 135, 48]/255];

hypNmA = 'Output-potent';
hypNmB = 'Output-null';
opts = struct('clrs', hypClrs, 'doSave', doSave, ...
    'TextNoteA', hypNmA, 'TextNoteB', hypNmB);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), end}, opts);
