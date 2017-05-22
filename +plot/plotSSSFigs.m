%% load

fitName = 'Int2Pert_yIme';
exInds = [14 1]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms] = plot.getSSS(fitName, 8, exInds);

%% plot avgs

doSave = false;
mnkNms = {'Jeffy', 'Lincoln'};
% mnkNms = {'Nelson'};
mnkNms = {};

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
% hypsToShow = hypnms;
cerrs = squeeze(nanmean(log(errs),2));
dtsc = dts(~all(isnan(cerrs),2));
cerrs = cerrs(~all(isnan(cerrs),2),:); % drop nans if all in session
plot.plotSSSErrorFig(cerrs, hypnms, dtsc, mnkNms, hypsToShow, doSave, false);

% [~,exInd] = min((cerrs(:,end) - mean(cerrs(:,end))).^2 + ...
%     (cerrs(:,end-1) - mean(cerrs(:,end-1))).^2);
% alternatively:
% tmp1 = log(errs(:,:,end));
% tmp2 = log(errs(:,:,end-1));
% [vs,exInds] = min((tmp1 - mean(tmp1(:))).^2 + (tmp2 - mean(tmp2(:))).^2);

%% plot ellipses - data

doSave = true;

hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
% hypClrs = [plot.hypColor('data'); [17, 135, 48]/255];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'XRotation', 0, ...
    'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C1s, C2s(:,:,end), opts);

%% plot example ellipse - data

doSave = true;
hypClrs = [plot.hypColor('data'); [0.6 0.6 0.6]];
% hypClrs = [plot.hypColor('data'); [17, 135, 48]/255];

hypNmA = 'Output-potent'; %plot.hypDisplayName('int-data');
hypNmB = 'Output-null'; %plot.hypDisplayName('pert-data');
opts = struct('clrs', hypClrs, 'doSave', doSave, ...
    'TextNoteA', hypNmA, 'TextNoteB', hypNmB);
plot.plotSSSEllipseSingle(Ys{end-1}, Ys{end}, ...
    C1s{exInds(1), exInds(2)}, C2s{exInds(1), exInds(2), end}, opts);

%% plot ellipses - cloud

doSave = false;
hypToCompare = 'constant-cloud';

% dtIx = io.getMonkeyDateFilter(dts, {'Jeffy'});
hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'dts', cellfun(@str2double, dts));
% plot.plotSSSEllipseFig(C2s(~dtIx,:,end), C2s(~dtIx,:,hypInd), opts);
plot.plotSSSEllipseFig(C2s(:,:,end), C2s(:,:,hypInd), opts);

%% plot example ellipse - cloud

doSave = false;
hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];

hypNm = plot.hypDisplayName(hypToCompare);
opts = struct('clrs', hypClrs, 'doSave', doSave, ...
    'TextNoteA', 'Data', 'TextNoteB', hypNm);
plot.plotSSSEllipseSingle(Ys{end}, Ys{hypInd}, ...
    C2s{exInds(1),exInds(2),end}, C2s{exInds(1),exInds(2),hypInd}, opts);

%%

close all;
C1 = errs(:,:,end);
Cc = errs(:,:,end-1);
Ch = errs(:,:,end-2);
C1 = log(C1); Cc = log(Cc); Ch = log(Ch);
plot.init; plot(nanmean(C1')); plot(nanmean(Cc')); plot(nanmean(Ch'))
plot(xlim, [0 0], 'k--');

cm = cbrewer('div', 'RdGy', 11);
plot.init; imagesc(C1'); axis off; colormap(cm); caxis([-2 2]); title('data');
plot.init; imagesc(Cc'); axis off; colormap(cm); caxis([-2 2]); title('cloud');
plot.init; imagesc(Ch'); axis off; colormap(cm); caxis([-2 2]); title('hab');

[nanmedian(nanmedian(C1,2)) nanmedian(nanmedian(Cc,2)) nanmedian(nanmedian(Ch,2))]

[nanmean(nanmean(((C1)-(Cc)).^2,2)') nanmean(nanmean(((C1)-(Ch)).^2,2)')]
