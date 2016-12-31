function Z = randNulValInGrpFit(Tr, Te, dec, opts)
% choose intuitive pt within thetaTol
    if nargin < 4
        opts = struct();
    end
    defopts = struct('thetaTol', 20, 'obeyBounds', true, ...
        'boundsType', 'marginal');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    NB2 = Te.NB;
    RB2 = Te.RB;
    Z1 = Tr.latents;
    Z2 = Te.latents;
    ths1 = Tr.thetas;
    ths2 = Te.thetas;
    
    dsThs = pdist2(ths2, ths1, @tools.angleDistance);
    ix = dsThs <= opts.thetaTol;
    [Zsamp, nErrs] = getSamples(Z1, ix);
    
    Zr = Z2*(RB2*RB2');
    Z = Zr + Zsamp*(NB2*NB2');
    
    if opts.obeyBounds
        % resample invalid points
        isOutOfBounds = tools.boundsFcn(Z1, opts.boundsType, dec);
        ixOob = isOutOfBounds(Z);
        n0 = sum(ixOob);
        maxC = 10;
        c = 0;        
        while sum(ixOob) > 0 && c < maxC
            [Zsamp, nErrs] = getSamples(Z1, ix(ixOob,:));
            Z(ixOob,:) = Zr(ixOob,:) + Zsamp*(NB2*NB2');
            ixOob = isOutOfBounds(Z);
            c = c + 1;
        end
        if n0 - sum(ixOob) > 0
            warning(['Corrected ' num2str(n0 - sum(ixOob)) ...
                ' habitual samples to lie within bounds']);
        end
    end
    if nErrs > 0
        warning([num2str(nErrs) ...
            ' habitual samples had no neighbors within range.']);
    end

end

function [Zsamp, nZero] = getSamples(Z1, ix)
    nt = size(ix,1);
    nix = sum(ix,2);
    
    % if nothing is in range, sample from anything
    nZero = sum(nix == 0);
    ix(nix == 0,:) = true;
    nix(nix == 0) = size(ix,2);
    
    nums = 1:size(ix,2);
    inds = arrayfun(@(t) nums(ix(t,:)), 1:nt, 'uni', 0);
    Zsamp = cell2mat(arrayfun(@(t) Z1(inds{t}(randi(nix(t))),:), ...
        1:nt, 'uni', 0)');
end
