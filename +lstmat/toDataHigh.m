function D = toDataHigh(B)
    % D(itr).epochColors : 1x3
    % D(itr).condition : 1x1 [str]
    % D(itr).data : (num_latents x num_timebins)
    
    trs = B.trial_index;
    alltrs = sort(unique(trs));
    D = struct();
    trgs = tools.thetaCenters;
    clrs = cbrewer('div', 'RdYlGn', numel(trgs));    
    for ii = 1:numel(alltrs)
        ix = trs == alltrs(ii);
        sps = B.spikes(ix,:);
        it = ~any(isnan(sps),2);
        D(ii).data = sps(it,:)';
        D(ii).epochStarts = 1;
        trg = mode(B.target(ix,:)); % assumes these are mean-centered
        trg = round(tools.computeAngles(trg));
        D(ii).condition = num2str(['trg' num2str(trg)]);
        D(ii).epochColors = clrs(trgs == trg,:);
    end

end
