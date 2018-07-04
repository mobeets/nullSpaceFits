%% find trials used for all fits

dts = io.getDates;
fitName = 'Int2Pert_yIme_20180606';
[S,F] = plot.getScoresAndFits(fitName, dts);
dts = {F.datestr};

trialsUsed = cell(numel(dts), 2);
for ii = 1:numel(F)
    D = F(ii);
    trialsUsed{ii,1} = unique(D.train.trial_index);
    trialsUsed{ii,2} = unique(D.test.trial_index);
end

%% for each session, plot behavior, and highlight trials used

cd ~/code/bciDynamics;

kSmooth = 16;
boxSmooth = ones(kSmooth,1)/kSmooth;

objs = [];
for ii = 1:numel(dts)
    dtstr = dts{ii}
    D = io.loadData(dtstr, false, false);
    vfcn_wmp = tools.makeVelFcn(D.blocks(2).fDecoder, false);
        
    trs = {trialsUsed{ii,1}, trialsUsed{ii,2}};
    acqTimes = cell(2,1);
    progress = cell(2,1);
    progressInferred = cell(2,1);
    for jj = 1:2
        B = D.blocks(jj);
        incorrectTrials = unique(B.trial_index(~B.isCorrect));
        
        for kk = 1:3
            if kk == 1
                % progress
                ix = (B.time >= 7);% & (B.isCorrect);            
                ys = tools.getProgress([], B.pos, B.trgpos, [], B.vel);
                xs = B.trial_index;
                ys = grpstats(ys(ix), xs(ix)); % avg per trial
                xs = unique(xs(ix));
            elseif kk == 2
                % acquisition time
                ys = (45/1000)*grpstats(B.time, B.trial_index, @numel);
                xs = unique(B.trial_index);
            else
                % inferred progress
                % (ignoring v_{t-1} term, to infer progress using Int activity)
                ix = (B.time >= 7);
                ys = tools.getProgress(B.latents, B.pos, B.trgpos, vfcn_wmp);
                xs = B.trial_index;
                ys = grpstats(ys(ix), xs(ix)); % avg per trial
                xs = unique(xs(ix));
            end
            
            % smooth and filter
            ysSmooth = conv2(ys, boxSmooth, 'same');
            ixToShow = false(size(ys)); % only show 'valid' inds
            ixToShow((kSmooth/2):(numel(ys)-(kSmooth/2))) = true;
            ixHighlight = ismember(xs, trs{jj});
            ixIncorrect = ismember(xs, incorrectTrials);
            
            % save
            clear cobj;
            cobj.xs = xs;
            cobj.ys = ys;
            cobj.ysSmooth = ysSmooth;
            cobj.ixToShow = ixToShow;
            cobj.ixHighlight = ixHighlight;
            cobj.ixIncorrect = ixIncorrect;
            if kk == 1
                progress{jj} = cobj;
            elseif kk == 2
                acqTimes{jj} = cobj;
            else
                progressInferred{jj} = cobj;
            end
        end
    end
    clear obj;
    obj.datestr = dtstr;
    obj.trials = trs;
    obj.progress = progress;
    obj.progressInferred = progressInferred;
    obj.acqTimes = acqTimes;
    objs = [objs; obj];
end

%%

% behNm = 'progress';
% behNm = 'progressInferred';
behNm = 'acqTimes';

showBaselineOnly = false; % if true: plot WMP data only; avg Int is a line

kSmooth = 100;
boxSmooth = ones(kSmooth,1)/kSmooth;

ptClr = 0.8*ones(3,1);
lnClr = 0.6*ones(3,1);
ptHighlightClr = 0.6*ones(3,1);
lnHighlightClr = [0.8 0.2 0.2]; %0.2*ones(3,1);
lw = 2;

plot.init;
for ii = 1:numel(objs)
    obj = objs(ii);
    mnkNm = io.dtToMnkNm(obj.datestr);
    subplot(7,6,ii); hold on;% set(gca, 'FontSize', 14);
    for jj = 1:2
        cobj = obj.(behNm){jj};
        xs = cobj.xs;
        ys = cobj.ys;
        ixHighlight = cobj.ixHighlight;
        
        ix = ~cobj.ixIncorrect;
        xs = xs(ix);
        ys = ys(ix);
        ixHighlight = ixHighlight(ix);
        
        % smooth ys
        ysSmooth = smooth(xs, ys, kSmooth);
%         ysSmooth = conv2(ys, boxSmooth, 'same');
        ixToShow = false(size(ys)); % only show 'valid' inds
        ixToShow((kSmooth/2):(numel(ys)-(kSmooth/2))) = true;
        if showBaselineOnly
            if jj == 1
                yBaseline = median(ys);
                continue;
            else
                xs = xs - min(xs);
            end
        end
        
%         plot(xs, ys, '.', 'Color', ptClr);
        plot(xs(ixToShow), ysSmooth(ixToShow), '-', ...
            'LineWidth', lw, 'Color', lnClr);
%         plot(xs(ixHighlight), ys(ixHighlight), '.', 'Color', ptHighlightClr);
        plot(xs(ixToShow & ixHighlight), ...
            ysSmooth(ixToShow & ixHighlight), '-', ...
            'LineWidth', lw, 'Color', lnHighlightClr);
        
        if jj == 1
            xChange = max(xs);
        end
    end    
    yl = ylim;
%     yl(2) = 70;
    ylim([0 yl(2)]);
    if showBaselineOnly
        xlim([0 1000]);
        plot(xlim, [yBaseline yBaseline], '-', 'Color', 0.8*ones(3,1));
    else
        xlim([0 1500]);
        plot([xChange xChange], ylim, '-', 'Color', 0.8*ones(3,1));
    end
    title([mnkNm(1) obj.datestr]);
end
plot.setPrintSize(gcf, struct('width', 9, 'height', 6.8));
