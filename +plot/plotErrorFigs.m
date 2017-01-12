
doSave = false;

% fitName = 'Int2Int_nIme';
% hypsToShow = {'minimum', 'baseline', 'best-mean', 'uncontrolled-uniform'};
% errNms = {'histError'};

fitName = 'Int2Pert_nIme';
% fitName = 'Int2Pert_yIme_optSig';
% fitName = 'Int2Pert_yIme';
% fitName = 'Pert2Int_yIme';

hypsToShow = {'minimum', 'baseline', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
errNms = {'meanError', 'covError', 'histError'};

% errNms = {'covError'};
% mnkNms = {'Lincoln'};
mnkNms = io.getMonkeys;
close all;
for ii = 1:numel(errNms)
    for jj = 1:numel(mnkNms)
        errs = plot.plotErrorFig(fitName, errNms{ii}, mnkNms{jj}, ...
            hypsToShow, doSave, false);
    end
end
