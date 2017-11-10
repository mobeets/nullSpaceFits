function clrs = scaleToColor(vs, cmap)
% map to scalars between 0 and 1 in vs to colors in cmap

    % bin vs to get indices into cmap
    [~,bs] = histc(vs, linspace(0, 1, size(cmap,1)));
    
    % handle values of vs below 0 or above 1
    bs(vs > 1) = size(cmap,1);
    bs(vs < 0) = 1;
    clrs = cmap(bs,:);
end
