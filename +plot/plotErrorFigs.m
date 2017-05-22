
doSave = false;

% fitName = 'Int2Pert_nIme_v3';
% fitName = 'Pert2Int_yIme';
fitName = 'Int2Pert_yIme';

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};

% hypsToShow = {'habitual-corrected', 'constant-cloud'};
% hypsToShow = {'minimum'};

errNms = {'meanError', 'covError', 'histError'};
% mnkNms = io.getMonkeys;
mnkNms = {'ALL'};
% errNms = {'covError'};

% close all;
showYLabel = true;
showMnkNm = false;
doAbbrev = false;
for ii = 1:numel(errNms)
    for jj = 1:numel(mnkNms)
        if strcmpi(errNms{ii}, 'histError')
            showMnkNm = false;
        else
            showMnkNm = false;
        end
        if strcmpi(mnkNms{jj}, 'Nelson')
            doAbbrev = false;
        else
            doAbbrev = true;
        end
        if strcmpi(mnkNms{jj}, 'ALL')
            mnkNm = '';
            showYLabel = true;
            doAbbrev = false;
        else
            mnkNm = mnkNms{jj};
        end
        errs = plot.plotErrorFig(fitName, errNms{ii}, mnkNm, ...
            hypsToShow, doSave, doAbbrev, showYLabel, showMnkNm);
    end
end
