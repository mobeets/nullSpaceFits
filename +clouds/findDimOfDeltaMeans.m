

% saveDir = 'data/plots/conditional_change';
saveDir = '';

ps = io.setUnfilteredDefaults;
ps.REMOVE_INCORRECTS = false;
grps = tools.thetaCenters;
dts = io.getDates;
clrs = cbrewer('div', 'RdYlGn', numel(grps));
for jj = 1:numel(dts)
    dts{jj}
    D = io.quickLoadByDate(dts{jj}, ps);
    
    psc = io.setFilterDefaults(dts{jj});
    tr_0 = psc.START_SHUFFLE;
    tr_1 = psc.END_SHUFFLE;

    bind = 1;
    gs = D.blocks(bind).thetaGrps;
    lts1 = grpstats(D.blocks(bind).latents, gs);

    bind = 2;
    gs = D.blocks(bind).thetaGrps;
    ix0 = ~isnan(gs);
    trs = D.blocks(bind).trial_index;
    ts = grpstats(trs, trs, 'mode');

    ts_st_inds = [1 41 numel(ts)+1];
    lts2 = cell(numel(ts_st_inds)-1,1);
    for ii = 1:numel(ts_st_inds)-1
        tsc = ts(ts_st_inds(ii):(ts_st_inds(ii+1)-1));
        ix = ismember(trs, tsc) & ix0;
        if ii > 1
            ix = ix & D.blocks(bind).isCorrect & ...
                D.blocks(bind).trial_index >= tr_0 & ...
                D.blocks(bind).trial_index < tr_1;
        end
        lts2{ii} = grpstats(D.blocks(bind).latents(ix,:), gs(ix));
    end

    d1 = lts2{1} - lts1;
    d2 = lts2{2} - lts2{1};
    [coeff1,score1,~,~,exp1] = pca(d1, 'Centered', false);
    [coeff2,score2,~,~,exp2] = pca(d2, 'Centered', false);

    plot.init;
    
    subplot(3,2,1); hold on;    
    d01 = lts1*coeff1;
    d11 = d1*coeff1;
    d21 = d2*coeff1;
    plot(d11(:,1), d11(:,2), '.', 'MarkerSize', 20);
    plot(d21(:,1), d21(:,2), '.', 'MarkerSize', 20);
    plot(0, 0, 'k+');
    xlabel('coeff1');

    subplot(3,2,2); hold on;
    d02 = lts2{1}*coeff2;
    d12 = d1*coeff2;
    d22 = d2*coeff2;
    plot(d12(:,1), d12(:,2), '.', 'MarkerSize', 20);
    plot(d22(:,1), d22(:,2), '.', 'MarkerSize', 20);
    plot(0, 0, 'k+');
    xlabel('coeff2');
    
    subplot(3,2,3); hold on;    
    p1 = d01;
    p2 = p1 + d11;
    p3 = p2 + d21;
    for ii = 1:numel(grps)        
        plot([p1(ii,1) p2(ii,1)], [p1(ii,2) p2(ii,2)], ...
            '.--', 'Color', clrs(ii,:));
        plot([p2(ii,1) p3(ii,1)], [p2(ii,2) p3(ii,2)], ...
            '.-', 'Color', clrs(ii,:));
    end
    plot(0, 0, 'k+');
    xlabel('coeff1');

    subplot(3,2,4); hold on;
    p1 = d02;
    p2 = p1 + d12;
    p3 = p2 + d22;
    for ii = 1:numel(grps)        
        plot([p1(ii,1) p2(ii,1)], [p1(ii,2) p2(ii,2)], ...
            '.--', 'Color', clrs(ii,:));
        plot([p2(ii,1) p3(ii,1)], [p2(ii,2) p3(ii,2)], ...
            '.-', 'Color', clrs(ii,:));
    end
    plot(0, 0, 'k+');
    xlabel('coeff2');

    subplot(3,2,5); hold on;
    plot(100*sum(d11.^2)/sum(sum(d11.^2)), '--');
    plot(100*sum(d21.^2)/sum(sum(d21.^2)));
    ylim([0 100]);
    xlabel('# dims');
    ylabel('% variance explained');
    legend({'first 10 of pert', 'post-learning'});
    legend boxoff;

    subplot(3,2,6); hold on;
    plot(100*sum(d12.^2)/sum(sum(d12.^2)), '--');
    plot(100*sum(d22.^2)/sum(sum(d22.^2)));
    ylim([0 100]);
    xlabel('# dims');
    ylabel('% variance explained');
    legend({'first 10 of pert', 'post-learning'});
    legend boxoff;
    
    popts = struct('width', 6, 'height', 6, 'margin', 0.25);
    plot.setPrintSize(gcf, popts);
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [D.datestr '.pdf']);
        export_fig(gcf, fnm);
    end
    if mod(jj, 5) == 0
        close all;
    end
    
end
