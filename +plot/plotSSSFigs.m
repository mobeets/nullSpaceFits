%% load

[errs, C2s, C1s, dts, hypnms] = plot.getSSS('Int2Pert_yIme');

%% plot avgs

doSave = true;
mnkNm = '';

hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud', ...
    'data'};
cerrs = squeeze(mean(log(errs),2));
plot.plotSSSErrorFig(cerrs, hypnms, dts, mnkNm, hypsToShow, doSave, false);

%% plot ellipses

doSave = false;
hypToCompare = 'constant-cloud';

hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];
opts = struct('clrs', hypClrs, 'doSave', doSave);
plot.plotSSSEllipseFig(C2s(:,:,end), C2s(:,:,hypInd), opts);
