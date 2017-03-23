%% load

fitName = 'Int2Pert_yIme';
exInds = [24 4]; % from exInd, below
[errs, C2s, C1s, Ys, dts, hypnms] = plot.getSSS(fitName, 8, exInds);

%% plot avgs

doSave = false;
mnkNms = {'Jeffy', 'Lincoln'};
% mnkNms = {'Nelson'};
mnkNms = {};

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
hypsToShow = hypnms;
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

%% plot ellipses

doSave = true;
hypToCompare = 'constant-cloud';
% hypToCompare = 'habitual-corrected';

hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];
opts = struct('clrs', hypClrs, 'doSave', doSave, 'indsToMark', exInds, ...
    'width', 13, 'height', 3, 'dstep', 6, 'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C2s(:,:,end), C2s(:,:,hypInd), opts);
% plot.plotSSSEllipseFig(C2s(:,:,end), C1s, opts);
% plot.plotSSSEllipseFig(C1s, C2s(:,:,hypInd), opts);

%% plot example ellipse

doSave = true;
hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];

hypNm = plot.hypDisplayName(hypToCompare);
opts = struct('clrs', hypClrs, 'doSave', doSave, 'TextNote', hypNm);
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
