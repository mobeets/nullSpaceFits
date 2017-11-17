%% find range of factor activity possible in first two dims
% subject to non-negative firing

% saveDir = 'data/plots/omp/boundaries';
saveDir = '';

dts = omp.getDates(true);

for jj = 15%1:numel(dts)

    % load data
    dtstr = dts{jj}
%     [blks, decs, ks, d] = omp.loadCoachingSessions(dtstr);

    % init OMP mapping and FA manifold
    dec = ks(2).kalmanInitParams;
    mu = dec.NormalizeSpikes.mean; % [1 x 88]
    [~, beta] = omp.spikesToLatents(dec, []); % [10 x 88]

    % min/max firing across days    
    lb = min(cell2mat(arrayfun(@(d) min(d.sps), blks, 'uni', 0)'));
    ub = max(cell2mat(arrayfun(@(d) max(d.sps), blks, 'uni', 0)'));

%     % min/max firing after taking average per theta-group
%     avgPerGrp = @(b) grpstats(b.sps, b.thgrps);
%     lb = min(cell2mat(arrayfun(@(d) min(avgPerGrp(d)), blks, 'uni', 0)'));
%     ub = max(cell2mat(arrayfun(@(d) max(avgPerGrp(d)), blks, 'uni', 0)'));
%     
%     % find min/max firing based on speed limits in each direction
%     angs = linspace(0, 360, 100)';
%     rads = [cosd(angs) sind(angs)];
%     sps = [];
%     for ii = 1:numel(blks)
%         vs = bsxfun(@plus, blks(ii).sps*dec.M2', dec.M0')*rads';
%         [~,inds] = max(vs);
%         csps = blks(ii).sps(unique(inds),:);
%         sps = [sps; csps];
%     end
%     lb = min(sps);
%     ub = max(sps);    

    % find max speed in each direction
    angs = linspace(0, 360, 100)';
    
    progM = speed.findAllMaxProgress(angs, dec.M2, dec.M0, beta, mu, lb, ub, true);
    progA = speed.findAllMaxProgress(angs, dec.M2, dec.M0, beta, mu, lb, ub, false);

    % find speeds of data on each day
    Zs = cell(numel(blks),1);
    for ii = 1:numel(blks)
        Zs{ii} = bsxfun(@plus, blks(ii).sps*dec.M2', dec.M0');
    end
    
    reds = cbrewer('seq', 'Reds', 3);
    blues = cbrewer('seq', 'Blues', 8);
    clrs = [reds(3,:); blues(2:numel(blks)-1,:); reds(2,:)];
    zero = dec.M0';  

    % plot and save
    bnms = {blks.name};
    nms = [{'Boundary (any)', 'Boundary (in-manifold)'} ...
        bnms {'Zero firing'}];
    lbls = {'Control plane, dim 1', 'Control plane, dim 2'};
    speed.plotMaxFactorActivity({progA, progM}, ...
        [Zs; {zero}], nms, clrs, ['OMP-' dtstr], lbls, saveDir, 1000);
end
