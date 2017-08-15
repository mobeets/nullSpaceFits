function G = make_struct(Blk, fnm)
    if isfield(Blk, 'train')
        G = normalizeLatentsAndSplitBlocks(Blk);
    else
        G = makeBlock(Blk);
    end
    save(fullfile('data', 'input', [fnm '.mat']), 'G');
end

function Blk = makeBlock(Blk, doPca)
    if nargin < 2
        doPca = true;
    end
    if doPca
        [coeffs, score] = pca(Blk.latents);
        Blk.coeffs = coeffs;
        Blk.latentsPca = score;
    end
    zPos = mean(unique(Blk.target, 'rows'));
    
    % center target and cursor position
    Blk.target = bsxfun(@minus, Blk.target, zPos);
    if isfield(Blk, 'pos')
        Blk.pos = bsxfun(@minus, Blk.pos, zPos);
    end
    
    Blk.vel(Blk.time < 6,:) = 0.0; % zero out velocity during freeze period
    Blk.velNext(Blk.time < 5,:) = 0.0;
end

function G = normalizeLatentsAndSplitBlocks(Blk)
    Y = [Blk.train.latents; Blk.test.latents];
    mu = nanmean(Y);    
    Blk.train.latents = bsxfun(@minus, Blk.train.latents, mu);
    Blk.test.latents = bsxfun(@minus, Blk.test.latents, mu);
    coeffs = pca(Y, 'Centered', false);
    
    G.train = makeBlock(Blk.train, false);
    G.test = makeBlock(Blk.test, false);
    G.train.coeffs = coeffs;
    G.train.latentsPca = G.train.latents*coeffs;
    G.test.coeffs = coeffs;
    G.test.latentsPca = G.test.latents*coeffs;
end
