function D = quickLoadByDate(dtstr, params, doRotate)
    if nargin < 2 || isempty(params)
        params = struct();
    end
    if nargin < 3
        doRotate = true;
    end
    D = io.loadRawDataByDate(dtstr, true); % (tries to load preprocessed)
    D.params = io.setFilterDefaults(D.datestr);
    D.params = io.updateParams(D.params, params, true);
    [D.blocks, D.trials] = io.getDataByBlock(D);
    D = io.addDecoders(D);
    D = io.addImeDecoders(D);
    if doRotate
        D = io.rotateLatentsUpdateDecoders(D, true);
    end
end
