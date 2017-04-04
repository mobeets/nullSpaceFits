
dts = io.getDates();
% dts = {'20120306'};

opts = struct('plotdir', 'data/plots/ime', 'doCv', false, ...
    'doSave', true, 'fitPostLearnOnly', true, 'doLatents', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
end
