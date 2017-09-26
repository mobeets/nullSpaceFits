function D = quickLoadByDate(dtstr, params, doRotate, skipIme)
    if nargin < 2 || isempty(params)
        params = struct();
    end
    if nargin < 3
        doRotate = true;
    end
    if nargin < 4
        skipIme = false;
    end
    D = io.loadRawDataByDate(dtstr, true); % (tries to load preprocessed)
    D.params = io.setFilterDefaults(D.datestr);
    D.params = io.updateParams(D.params, params, true);
    [D.blocks, D.trials] = io.getDataByBlock(D);
    D = io.addDecoders(D);
    if ~skipIme
        D = io.addImeDecoders(D);
    end
    if doRotate
        D = io.rotateLatentsUpdateDecoders(D, true);
    end
end
