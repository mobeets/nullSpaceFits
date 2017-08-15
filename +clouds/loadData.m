function D = loadData(dtstr, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('removeCorrects', false, 'unfiltered', true, ...
        'inds', 1:2, 'binSz', 50);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if opts.unfiltered
        ps = io.setUnfilteredDefaults;
    else
        ps = io.setFilterDefaults(dtstr);
    end
    ps.REMOVE_INCORRECTS = opts.removeCorrects;
    D = io.quickLoadByDate(dtstr, ps);
    
    [~, score1] = pca(D.blocks(1).latents);
    [~, score2] = pca(D.blocks(2).latents);
    [~, score3] = pca(D.blocks(3).latents);
    
    % 2D slice of cloud
    D.dat = cell(3,1);
    D.dat{1} = score1(:,opts.inds);
    D.dat{2} = score2(:,opts.inds);
    D.dat{3} = score3(:,opts.inds);
    
    % boundaries of 2D slice
    D.bnd(1) = clouds.getBoundary(D.dat{1});
    D.bnd(2) = clouds.getBoundary(D.dat{2});
    D.bnd(3) = clouds.getBoundary(D.dat{3});
    
    % bins for heatmap
    D.ctrs = clouds.heatmapBins(cell2mat(D.dat), opts.binSz);
end
