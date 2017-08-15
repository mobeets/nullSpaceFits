
doSave = false;

fitName = 'Int2Pert_yIme';
% fitName = 'Int2Pert_nIme';
% fitName = 'Pert2Int_yIme';

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
% hypsToShow = {'minimum'};
hypsToShow = {};

errNms = {'meanError', 'covError', 'histError'};
mnkNms = io.getMonkeys;
mnkNms = {'ALL'};
errNms = {'histError'};

close all;
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

%% report # of skipped timepoints

fitName = 'Int2Pert_yIme_final';
[Ss,Fs] = plot.getScoresAndFits(fitName);
scs = nan(numel(Fs), numel(Fs(1).fits));
for ii = 1:numel(Fs)
    F = Fs(ii);
    for jj = 1:numel(F.fits)
        scs(ii,jj) = mean(any(isnan(F.fits(jj).latents),2));
    end
end
round(100*scs)
{F.fits.name}
