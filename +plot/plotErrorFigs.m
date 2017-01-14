
doSave = true;

% fitName = 'Int2Int_nIme';
% fitName = 'Int2Pert_nIme';
% fitName = 'Int2Pert_yIme';
fitName = 'Pert2Int_yIme';

if strcmpi(fitName, 'Int2Int_nIme')
    hypsToShow = {'minimum', 'baseline', 'best-mean', ...
        'uncontrolled-uniform'};
    errNms = {'histError'};
else
    hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
    errNms = {'meanError', 'covError', 'histError'};
end
mnkNms = io.getMonkeys;

% errNms = {'histError', 'covError'};
% mnkNms = {'Lincoln'};
close all;
for ii = 1:numel(errNms)
    for jj = 1:numel(mnkNms)
        if strcmpi(errNms{ii}, 'covError') || ...
                strcmpi(fitName, 'Int2Int_nIme')
            doAbbrev = false;
        else
            doAbbrev = true;
        end
        if strcmpi(mnkNms{jj}, 'Jeffy')
            showYLabel = true;
        else
            showYLabel = false;
        end
        errs = plot.plotErrorFig(fitName, errNms{ii}, mnkNms{jj}, ...
            hypsToShow, doSave, doAbbrev, showYLabel);
    end
end
