function [D, Stats, LLs] = fitSession(dtstr, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('doLatents', false, 'doSave', false, ...
        'doPlot', true, 'doCv', false, 'plotdir', '', ...
        'fitPostLearnOnly', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    params = io.setUnfilteredDefaults();
    if opts.fitPostLearnOnly
        goodTrials = io.setBlockStartTrials(dtstr);
        params = io.updateParams(params, goodTrials, true);
    end
    doRotate = false;
    D = io.quickLoadByDate(dtstr, params, doRotate);
    fnm = io.pathToIme(dtstr);

    LLs = cell(3,1);
    Stats = cell(3,1);
    for ii = 1:2%3
        [estParams, LL, stats] = imefit.fitBlock(D.blocks(ii), opts);        
        D.ime(ii) = estParams;
        
        if opts.doPlot
            fig = imefit.plotImeStats(D, ii, ...
                stats.mdlErrs, stats.cErrs, stats.by_trial);
            savePlot(fig, opts.plotdir, [D.datestr '-' num2str(ii) '-stats']);
            plot.init; plot(LL); title([D.datestr '-Blk' num2str(ii) ' ime LL']);
        end
        LLs{ii} = LL; Stats{ii} = stats;
    end
    
    if opts.doPlot
        fig = imefit.plotErrByBlock(Stats{1}, Stats{2}); title(D.datestr);
        if ~isempty(opts.plotdir)
            savePlot(fig, opts.plotdir, [D.datestr '-bytrial']);
        else
            savePlot(fig, 'plots', 'tmp');
        end
    end
    if opts.doSave
%         error('You sure?');
        saveIme(D.ime, fnm, Stats, LLs);
    end
end

function saveIme(ime, fnm, Stats, LLs)
    if exist(fnm, 'file')
        resp = input('File exists. Continue? (y/n) ', 's');
        if resp(1) ~= 'y'
            error('Not saving...file already exists.');
        end
    end
    disp(['Saving ime model to ' fnm]);
    save(fnm, 'ime', 'Stats', 'LLs');
end

function savePlot(fig, fldr, nm)
    if isempty(fldr)
        return;
    end
    if ~exist(fldr, 'dir')
        mkdir(fldr);
    end
    saveas(fig, fullfile(fldr, nm), 'png');
end

