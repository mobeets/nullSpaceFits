%% load

[errs, C2s, C1s, dts, hypnms] = plot.getSSS('Int2Pert_yIme', 8);

%% plot avgs

doSave = false;
mnkNm = '';

hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
cerrs = squeeze(mean(log(errs),2));
plot.plotSSSErrorFig(cerrs, hypnms, dts, mnkNm, hypsToShow, doSave, false);

%% plot ellipses

doSave = true;
hypToCompare = 'constant-cloud';

hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];
opts = struct('clrs', hypClrs, 'doSave', doSave, ...
    'width', 12, 'height', 3, 'dstep', 6, 'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C2s(:,:,end), C2s(:,:,hypInd), opts);
