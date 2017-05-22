function [errs, es1, es3, errs2, es2] = errorImprovement(D, grpNm, decNm, ...
    compareToTrue, useTrueDecoder)
    if nargin < 2
        grpNm = 'thetasIme';
    end
    if nargin < 3
        decNm = 'fImeDecoder';
    end
    if nargin < 4
        compareToTrue = false;
    end
    if nargin < 5
        useTrueDecoder = false;
    end
    
    d = D.blocks(1).(decNm);
    velf_Int = @(Z) ((eye(2) - d.M1)\bsxfun(@plus, d.M2*Z', d.M0))';
    
    if useTrueDecoder
        % find angular error using Intuitive ("true") decoder
        bind = 1;
    else
        % find angular error using WMP decoder
        bind = 2;
    end
    d = D.blocks(bind).(decNm);
    velf = @(Z) ((eye(2) - d.M1)\bsxfun(@plus, d.M2*Z', d.M0))';
    
    [errs1, es1] = angularError(D.blocks(1), velf, grpNm, ...
        velf_Int, compareToTrue, nan);
    [errs2, es2] = angularError(D.blocks(2), velf, grpNm, ...
        velf_Int, compareToTrue, nan);
    [errs3, es3] = angularError(D.blocks(3), velf, grpNm, ...
        velf_Int, compareToTrue, 0.3);
    errs = abs(errs1) - abs(errs3);
    errs2 = abs(errs1) - abs(errs2);
    
end

function [errs, es] = angularError(Blk, velf, grpNm, velf_Int, ...
    compareToTrue, pctRemove)
    vs = velf(Blk.latents);
    gs = Blk.(grpNm);
    vs_int = velf_Int(Blk.latents);
    
    angs = tools.computeAngles(vs);
    angs_int = tools.computeAngles(vs_int);
    
    if ~compareToTrue
        base_angs = gs;
    else
        base_angs = angs_int;
    end
    es = tools.angleDistance(angs, base_angs, false);
    
    if ~isnan(pctRemove)
        minTrialInd = min(Blk.trial_index) + ...
            pctRemove*range(Blk.trial_index);
        ix = Blk.trial_index >= minTrialInd;
    else
        ix = true(size(es));
    end
    es = es(ix,:);
    gs = gs(ix,:);
    errs = washout.groupErrorThroughDecoder(es, gs);
end
