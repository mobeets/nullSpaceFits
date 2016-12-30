function Hs = marginalHist(Y, gs, Xs)
    grps = sort(unique(gs));
    ngrps = numel(grps);
    nfeats = size(Y,2);
    nbins = size(Xs{1},1);
    Hs = cell(ngrps,1);
    for jj = 1:ngrps
        Hs{jj} = nan(nbins, nfeats);
        for ii = 1:nfeats
            xs = Xs{jj}(:,ii);
            Hs{jj}(:,ii) = singleMarginal(Y(grps(jj) == gs,ii), xs);
        end
    end
end

function ysh = singleMarginal(Y, xs)
    [c,b] = hist(Y, xs);
    ysh = c./trapz(b,c);
end
