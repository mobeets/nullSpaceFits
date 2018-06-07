
dts = io.getDates(false, true);
doSave = true;
isDebug = false;

% set opts
opts = struct();
opts.muThresh = 0.5;
opts.varThresh = 0.5;
opts.meanBinSz = 100; % smoothing for mean
opts.varBinSz = 100; % bin size for running var
opts.maxTrialSkip = 10; % max change that we can still count as one group
opts.minGroupSize = 100; % want at least N consecutive trials
opts.behavNm = 'trial_length'; % 'progress'
opts.lastBaselineTrial = 50;
opts.ignoreIncorrects = false;

saveDir = fullfile('data', 'sessions');
fnm = fullfile(saveDir, ['goodTrials_' opts.behavNm '.mat']);

%% find best trials (using opts)

Trs = nan(numel(dts), 4);
objs = [];
for ii = 1:numel(dts)
    dtstr = dts{ii};
    if ~isDebug
        try
            cd ~/code/bciDynamics;
            D = io.loadData(dtstr, opts.ignoreIncorrects, false);
            cd ~/code/nullSpaceFits;
        catch
            warning(['Could not load ' dtstr]);
            Trs(ii,1) = str2double(dtstr);
            continue;
        end
    end
    B = D.blocks(2);
    xs = B.trial_index;
    if strcmpi(opts.behavNm, 'trial_length') && ~isfield(B, 'trial_length')
        B.trial_length = nan(size(B.trial_index));
        axs = unique(xs);
        for jj = 1:numel(axs)
            ix = B.trial_index == axs(jj);
            B.trial_length(ix) = sum(ix);
        end
    elseif strcmpi(opts.behavNm, 'progress') && ~isfield(B, 'progress')
        cd ~/code/bciDynamics;
        B.progress = tools.getProgress([], B.pos, B.trgpos, [], B.vel);
        cd ~/code/nullSpaceFits;
    end
    ys = B.(opts.behavNm);
    if strcmpi(opts.behavNm, 'progress')
        ys = -ys;
    end
    obj = behav.plotThreshTrials(xs, ys, opts);
    obj.datestr = dtstr;
    if isfield(obj, 'xsb')
        objs = [objs; obj];
    end
    
    if ~obj.isGood || isempty(obj.xsb(obj.ix))
        tmn = nan; tmx = nan;
    else
        tmn = min(obj.xsb(obj.ix));
        tmx = max(obj.xsb(obj.ix));        
    end
    Trs(ii,:) = [str2double(dtstr) tmn tmx obj.isGood];
end

if doSave
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    save(fnm, 'Trs', 'opts', 'objs');
end

%% plot selected trials

% d = load('data/sessions/goodTrials_trial_length.mat');
% opts = d.opts;
% objs = d.objs;

showNormalized = true;
kind = 'Mean'; % 'Mean', 'Var'

lw = 1;
xmx = 1010;
ymx = 8;
scale = 45/1000; % 45/1000 for acquisition time

plot.init;

ncols = ceil(sqrt(numel(objs)));
nrows = ceil(numel(objs)/ncols);
for ii = 1:numel(objs)
    subplot(nrows, ncols, ii); hold on;
    obj = objs(ii);    
    ix = obj.ix;
    xsb = obj.xsb; xsb = xsb - min(xsb);
    if showNormalized
        ysb = obj.(['ysSmooth' kind 'Norm']);        
    else
        ysb = scale*obj.(['ysSmooth' kind]);
    end    
    
    if obj.isGood
        clr = 'k';
    else
        clr = 0.8*ones(3,1);
    end
    
    if showNormalized
        plot([0 xmx], [opts.muThresh opts.muThresh], ...
            '-', 'Color', 0.8*ones(3,1), 'LineWidth', lw);
        yl = [0 1.01];
        set(gca, 'YTick', [0 1.0]);
    else
        yl = [0 ymx];
        set(gca, 'YTick', [0 ymx]);
    end

    plot(xsb(1:end-10), ysb(1:end-10), '-', 'Color', clr, 'LineWidth', lw);
%     plot(xsb(ix), ysb(ix), 'r-', 'LineWidth', lw);
    
    if sum(ix) > 0
        plot([min(xsb(ix)) max(xsb(ix))], [yl(2) yl(2)], ...
            'r-', 'LineWidth', lw);
    end
%     xlabel('Trial #');

    if ii == 1
        ylabel([kind ' of ' opts.behavNm]);
    end    
    ylim(yl);
    xlim([min(xsb) max(xsb)]);
    set(gca, 'LineWidth', lw);
    set(gca, 'XTick', [500]);
    xlim([0 xmx]);
    title(obj.datestr);
end
plot.setPrintSize(gcf, struct('width', 7, 'height', 6));

pnm = fullfile(saveDir, ['goodTrials_' opts.behavNm '_' kind '.pdf']);
if doSave
    export_fig(gcf, pnm);
end
