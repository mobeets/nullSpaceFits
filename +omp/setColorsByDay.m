function blks = setColorsByDay(blks)
    clrs = cbrewer('seq', 'Blues', numel(blks)-1);
    clrs = [0.8 0.2 0.2; clrs(2:end,:); 0.8 0.6 0.6];
    for ii = 1:numel(blks)
        blks(ii).clr = clrs(ii,:);
    end
end
