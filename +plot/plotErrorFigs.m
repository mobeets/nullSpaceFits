
doSave = false;
doSaveData = true;

runName = '_20180619';
fitName = 'Int2Pert_yIme'; showErrFloor = false;
% fitName = 'Int2Pert_nIme'; showErrFloor = false;
% fitName = 'Pert2Int_yIme'; showErrFloor = false;
exampleSession = '20131218';

% from plot.findErrFloor:
if showErrFloor
    fnm = fullfile('data', 'fits', [fitName runName], 'errorFloor.mat');
    d = load(fnm); errFloorMu = d.mu; errFloorSd = d.sd;
    errFloorScale = [100 1000/45 1];
else
    errFloorMu = []; errFloorSd = []; errFloorScale = [];
end

hypsToShow = {'minimum', 'best-mean', 'uncontrolled-uniform', ...
    'uncontrolled-empirical', 'habitual-corrected', 'constant-cloud'};
hypsToShow = {'habitual-corrected', 'constant-cloud'};
hypsToShow = {};

errNms = {'histError', 'meanError', 'covError'};
% mnkNms = io.getMonkeys;
mnkNms = {'ALL'};
% mnkNms = {'Lincoln'};
% errNms = {'meanError'};

close all;
showYLabel = true;
showMnkNm = false;
doAbbrev = false;
disp('-----');
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
        if showErrFloor
            errFloor = errFloorScale(ii)*[errFloorMu(ii) errFloorSd(ii)];
        else
            errFloor = [];
        end
        errs = plot.plotErrorFig(fitName, runName, errNms{ii}, mnkNm, ...
            hypsToShow, doSave, doAbbrev, showYLabel, showMnkNm, ...
            errFloor, doSaveData);
        
        vs = [mean(errs(:,end)) std(errs(:,end))/sqrt(size(errs,1))];
        disp(['Avg ' errNms{ii} ' of last hyp: ' ...
            sprintf('%0.1f +/- %0.1f (mean +/- SE)', vs)]);
        ev = errs(ismember(dts, exampleSession),end);
        disp([errNms{ii} ' of last hyp for example session (' ...
            exampleSession '): ' sprintf('%0.1f', ev)]);
        
        if strcmpi(errNms{ii}, 'histError')
            vs = [mean(errs); std(errs)/sqrt(size(errs,1))];
            for kk = 1:size(errs,2)
                vs = [mean(errs(:,kk)) std(errs(:,kk))/sqrt(size(errs,1))];
                disp(['Avg ' errNms{ii} ' of hyp ' num2str(kk) ': ' ...
                    sprintf('%0.1f +/- %0.1f (mean +/- SE)', vs)]);
            end
        end
    end
end
disp('-----');

%% report # of skipped timepoints

runName = '_20180619';
fitName = 'Int2Pert_yIme';
[Ss,Fs] = plot.getScoresAndFits([fitName runName]);
scs = nan(numel(Fs), numel(Fs(1).fits));
for ii = 1:numel(Fs)
    F = Fs(ii);
    for jj = 1:numel(F.fits)
        scs(ii,jj) = mean(any(isnan(F.fits(jj).latents),2));
    end
end
round(100*scs)
{F.fits.name}
