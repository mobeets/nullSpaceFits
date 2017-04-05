
doSave = false;

% fitName = 'Int2Int_nIme';
% fitName = 'Int2Pert_nIme';
% fitName = 'Pert2Int_yIme';
% fitName = 'Int2Pert_yIme';
fitName = 'Int2Pert_yIme_v2';

if strcmpi(fitName, 'Int2Int_nIme')
    hypsToShow = {'minimum', 'baseline', 'best-mean', ...
        'uncontrolled-uniform'};
    errNms = {'histError'};
else
    hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
        'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
    errNms = {'meanError', 'covError', 'histError'};
end
% mnkNms = io.getMonkeys;
mnkNms = {'ALL'};

% fitName = 'tmmmmm2';
% errNms = {'histError'};
% hypsToShow = {'minimum', 'best-mean', 'baseline'};
% hypsToShow = {'uncontrolled-empirical', 'constant-cloud', 'habitual-corrected'};
% hypsToShow = {};
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
        if strcmpi(mnkNms{jj}, 'ALL')
            mnkNm = '';
            showYLabel = true;
            doAbbrev = false;
        else
            mnkNm = mnkNms{jj};
        end
        errs = plot.plotErrorFig(fitName, errNms{ii}, mnkNm, ...
            hypsToShow, doSave, doAbbrev, showYLabel);
    end
end
