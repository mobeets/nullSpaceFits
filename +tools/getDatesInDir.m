function dts = getDatesInDir(baseDir)
    if nargin < 2
        baseDir = 'data/preprocessed';
    end
    ds = dir(baseDir); ds = ds(~[ds.isdir]); ds = {ds.name};
    dts = cellfun(@(d) strrep(d, '.mat', ''), ds, 'uni', 0);
    dts = dts(~cellfun(@(d) strcmp(d, '.DS_Store'), dts));
end
