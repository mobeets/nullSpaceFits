
% dataDir = '~/code/wmpCode/data/preprocessed';
% dr = dir(dataDir); nms = {dr(~[dr.isdir]).name};
% dts = cellfun(@(d) d(1:end-4), nms, 'uni', 0);
% dts = dts(~ismember(dts, {'.DS_Store', 'errors'}));
dts = io.getDates(false, true);

doSave = false;
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

% opts.behavNm = 'isCorrect';

saveDir = fullfile('data', 'sessions');
fnm = fullfile(saveDir, ['goodTrials_' opts.behavNm '_v2.mat']);

%% find best trials (using opts)

Trs = cell(2,1);
Trs{1} = nan(numel(dts), 4);
Trs{2} = nan(numel(dts), 4);
objs = cell(2,1);

for ii = 1:numel(dts)
    dtstr = dts{ii};
    if ~isDebug
        try
            d = load(fullfile(dataDir, [dtstr '.mat'])); D = d.D;
%             cd ~/code/bciDynamics;
%             D = io.loadData(dtstr, false, false);
%             cd ~/code/nullSpaceFits;
        catch
            warning(['Could not load ' dtstr]);
            Trs{1}(ii,1) = str2double(dtstr);
            Trs{2}(ii,1) = str2double(dtstr);
            continue;
        end
    end
    for bind = 1:2
        B = D.blocks(bind);
        xs = B.trial_index;
        if strcmpi(opts.behavNm, 'trial_length') && ~isfield(B, 'trial_length')
            B.trial_length = nan(size(B.trial_index));
            axs = unique(xs);
            for jj = 1:numel(axs)
                ixt = B.trial_index == axs(jj);
                B.trial_length(ixt) = sum(ixt);
            end
        elseif strcmpi(opts.behavNm, 'progress') && ~isfield(B, 'progress')
            cd ~/code/bciDynamics;
            B.progress = tools.getProgress([], B.pos, B.trgpos, [], B.vel);
            cd ~/code/nullSpaceFits;
        end
        ys = B.(opts.behavNm);

        % if ignoring incorrects, set behavior to nan on those trials
        if strcmpi(opts.behavNm, 'trial_length') || ...
                strcmpi(opts.behavNm, 'progress')
            ys(~B.isCorrect) = nan;
        end

        % flip sign so that learning is a decreasing value
        if strcmpi(opts.behavNm, 'progress') || strcmpi(opts.behavNm, 'isCorrect')
            ys = -ys;
        end
        obj = behav.plotThreshTrials(xs, ys, opts);
        obj.datestr = dtstr;
        if isfield(obj, 'xsb')
            objs{bind} = [objs{bind}; obj];
        end

        if ~obj.isGood || isempty(obj.xsb(obj.ix))
            tmn = nan; tmx = nan;
        else
            tmn = min(obj.xsb(obj.ix));
            tmx = max(obj.xsb(obj.ix));        
        end
        Trs{bind}(ii,:) = [str2double(dtstr) tmn tmx obj.isGood];
    end
end

if doSave
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    save(fnm, 'Trs', 'opts', 'objs');
    behav.plotAllThreshTrials(fnm);
end

%% make all behavior figures

doSave = false;
saveDir = 'data/plots/behav';
fnm = 'data/sessions/goodTrials_trial_length.mat';
fnm2 = 'data/sessions/goodTrials_isCorrect.mat';
% dtstr = '20120525';
dtstr = '20160726';

% close all;
% f1 = behav.plotSingleSession(dtstr, fnm, fnm, [0 2.2]); f1nm = ['acqTime_' dtstr];
% f2 = behav.plotAvgBehavPerMonkey(fnm); f2nm = 'acqTime';
% f3 = behav.plotSingleSession(dtstr, fnm2, fnm, [25 100]); f3nm = ['pctCor_' dtstr];
% f4 = behav.plotAvgBehavPerMonkey(fnm2); f4nm = 'pctCor';
f5 = behav.plotCursorTraces(dtstr, fnm); f5nm = ['cursor_' dtstr];

if doSave
%     export_fig(f1, fullfile(saveDir, [f1nm '.pdf']));
%     export_fig(f2, fullfile(saveDir, [f2nm '.pdf']));
%     export_fig(f3, fullfile(saveDir, [f3nm '.pdf']));
%     export_fig(f4, fullfile(saveDir, [f4nm '.pdf']));
    export_fig(f5, fullfile(saveDir, [f5nm '.pdf']));
end
