%% load

exInds = [1 1];
[errs, C2s, C1s, Ys, dts, hypnms] = plot.getSSS('Int2Pert_yIme', 8, exInds);

%% plot avgs

doSave = true;
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
    'width', 13, 'height', 3, 'dstep', 6, 'dts', cellfun(@str2double, dts));
plot.plotSSSEllipseFig(C2s(:,:,end), C2s(:,:,hypInd), opts);

%%

doSave = true;
hypInd = strcmpi(hypnms, hypToCompare);
hypClrs = [plot.hypColor('data'); plot.hypColor(hypToCompare)];

hypNm = hypToCompare; hypNm(1) = upper(hypNm(1));
opts = struct('clrs', hypClrs, 'doSave', doSave, 'TextNote', hypNm);
plot.plotSSSEllipseSingle(Ys{end}, Ys{hypInd}, ...
    C2s{exInds(1),exInds(2),end}, C2s{exInds(1),exInds(2),hypInd}, opts);
