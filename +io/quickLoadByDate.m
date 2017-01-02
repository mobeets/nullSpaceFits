function D = quickLoadByDate(dtstr, params, ~)
    if nargin < 2 || isempty(params)
        params = struct();
    end
    D = io.loadDataByDate(dtstr);
    D.params = io.updateParams(D.params, params, true);
    [D.blocks, D.trials] = io.getDataByBlock(D);
    D = io.addDecoders(D);
    D = io.addImeDecoders(D);
    D = io.rotateLatentsUpdateDecoders(D, true);
end
