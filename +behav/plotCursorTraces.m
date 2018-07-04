function fig = plotCursorTraces(dtstr, fnm, D)
    if nargin < 3
        cd ~/code/bciDynamics;
        D = io.loadData(dtstr, false, false);
        cd ~/code/nullSpaceFits;
    else
        assert(strcmpi(D.datestr, dtstr));
    end

    d = load(fnm);
    objs = d.objs{2};
    opts = d.opts;
    ixWMP = ismember({objs.datestr}, dtstr);
    B = objs(ixWMP);
    firstTrials = B.xsb(1:50);
    goodTrials = B.xsb(B.ix);    
    
    tsz = 30; % target size
    fig = plot.init;
    
    B = D.blocks(1);
    trs = unique(B.trial_index);
    lastIntTrials = trs(end-50:end);
    ixtr = ismember(B.trial_index, lastIntTrials);
    ix = ixtr;% & B.isCorrect;
    B = io.filterTrialsByIdx(B, ix);
    xoffset = 0;
    plotTraces(B, xoffset, tsz);
    
    B = D.blocks(2);
    ixtr = ismember(B.trial_index, firstTrials);
    ix = ixtr;% & B.isCorrect;
    B = io.filterTrialsByIdx(B, ix);
    xoffset = 500;
    plotTraces(B, xoffset, tsz);
    
    B = D.blocks(2);
    trs = B.trial_index(ismember(B.trial_index, goodTrials) & B.isCorrect);
    atrs = unique(trs);
    ixtr = ismember(B.trial_index, atrs(end-50:end));
%     goodTrials = goodTrials(end-50:end);
%     ixtr = ismember(B.trial_index, goodTrials);
    ix = ixtr;% & B.isCorrect;
    B = io.filterTrialsByIdx(B, ix);
    xoffset = 1000;
    plotTraces(B, xoffset, tsz);

    axis off;    
    plot.setPrintSize(gcf, struct('width', 8, 'height', 2.3));
    
end

function plotTraces(B, xoffset, tsz)
    
    grps = tools.thetaCenters;
%     clrs = cbrewer('div', 'RdYlGn', numel(grps));
    clrs = cbrewer('qual', 'Dark2', numel(grps));
    clrs2 = cbrewer('qual', 'Set1', numel(grps)+1);
    clrs(end-1,:) = clrs2(2,:);
    trs = B.trial_index;
    atrs = unique(trs);
    
    for ii = 1:numel(atrs)
        ix = trs == atrs(ii);
        pos = B.pos(ix,:);
        cen = B.pos(1,:);
        clr = clrs(unique(B.trgs(ix)) == grps,:);
        if B.isCorrect(ix)
            lnst = '-';
        else
            lnst = '--';
        end
        
        dist = sqrt(sum(bsxfun(@minus, pos, cen).^2,2));
        ixd = dist > 200;
        ind = find(ixd, 1, 'first');
        if isempty(ind)
            plot(xoffset + pos(:,1), pos(:,2), lnst, 'Color', clr);
        else
            plot(xoffset + pos(1:ind,1), pos(1:ind,2), lnst, 'Color', clr);
        end
    end
    
    trgpos = unique([B.trgpos B.trgs], 'rows');
    [~,ix] = sort(trgpos(:,3));
    trgpos = trgpos(ix,1:2);
    for ii = 1:size(trgpos,1)
        cpos = trgpos(ii,:);
        clr = clrs(ii,:);
%         plot(xoffset + cpos(1), cpos(2), '.', 'MarkerSize', tsz, ...
%             'Color', clr);
        plot(xoffset + cpos(1), cpos(2), 'o', 'MarkerSize', tsz, ...
            'Color', clr, 'LineWidth', 2);
    end
end
