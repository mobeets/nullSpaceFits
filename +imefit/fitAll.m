
dts = io.getDates();
% dts = {'20131205'};

opts = struct('plotdir', 'data/plots/ime', 'doCv', false, ...
    'doSave', true, 'fitPostLearnOnly', true, 'doLatents', true);
for ii = 1:numel(dts)
    [D, Stats, LLs] = imefit.fitSession(dts{ii}, opts);
    if mod(ii,5) == 0
        close all;
    end
end
