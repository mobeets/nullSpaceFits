function [Z, inds] = minEnergySampleFit(Tr, Te, dec, opts)
    if nargin < 2
        opts = struct();
    end
    assert(isa(opts, 'struct'));
    defopts = struct('minType', 'baseline', ...
        'fitInLatent', false, 'kNN', nan, 'addSpikeNoise', true);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if opts.fitInLatent
        Y1 = Tr.latents;
        Y2 = Te.latents;
        RB2 = Te.RB;
        NB2 = Te.NB;
    else
        Y1 = Tr.spikes;
        Y2 = Te.spikes;
        RB2 = Te.RB_spikes;
        NB2 = Te.NB_spikes;
    end
    Un1 = Y1*(NB2*NB2');
    Ur = Y2*(RB2*RB2');

    if strcmpi(opts.minType, 'baseline') && opts.fitInLatent
        mu = zeros(1,size(Y2,2));
    elseif strcmpi(opts.minType, 'baseline') && ~opts.fitInLatent
        mu = dec.spikeCountMean;        
    elseif strcmpi(opts.minType, 'minimum') && opts.fitInLatent        
        zers = zeros(size(Tr.spikes,2), 1);
        mu = tools.convertRawSpikesToRawLatents(dec, zers);
    elseif strcmpi(opts.minType, 'minimum') && ~opts.fitInLatent
        mu = zeros(1,size(Y2,2));
    end
    maxSps = max(Y1(:));
    
    nt = size(Y2,1);
    sigma = dec.spikeCountStd;
    nse = normrnd(zeros(nt, numel(sigma)), repmat(sigma, nt, 1));
    
    Un = nan(size(Ur));
    inds = nan(nt,1);
    nInvalids = 0;
    for t = 1:nt
        Unc = Un1;
%         Unc = Un1(curinds(t,:),:);        
        usc = bsxfun(@plus, Unc, Ur(t,:)); % current spikes considered
        ixKeep = ~any(usc<0|usc>2*maxSps,2);
        if sum(ixKeep) == 0
            nInvalids = nInvalids + 1;
            continue;
        end
        
        usc = usc(ixKeep,:); % ignore oob spikes
        Unc = Unc(ixKeep,:);
        
        % only consider Un1 for kNN closest points to current row space val
        if ~isnan(opts.kNN)            
            curinds = getRowDists(Y1(ixKeep,:), Y2(t,:), RB2, opts.kNN);
            Unc = Un1(curinds,:);
            usc = usc(curinds,:);
        end
        
        % find ind of us s.t. us is nearest zero spikes
        ds = sqrt(sum(bsxfun(@plus, usc, -mu).^2,2));
        [~, ind] = min(ds);        
        inds(t) = ind;
        
        unc = Unc(ind,:);
        if ~opts.fitInLatent && opts.addSpikeNoise
            unc0 = unc;
            c = 0;
            unc = normrnd(unc0, sigma);
            while (any(unc + Ur(t,:)<0) || any(unc + Ur(t,:) > 2*maxSps)) && c < 10
                unc = normrnd(unc0, sigma);
                c = c + 1;
            end
        end        
        Un(t,:) = unc;
    end
    if nInvalids > 0
        warning(['minEnergySampleFit: ' num2str(nInvalids) ...
            ' samples had no valid points.']);
    end    

    U = Ur + Un;
    % now convert to latents
    if opts.fitInLatent
        Z = U;
    else
        Z = tools.convertRawSpikesToRawLatents(dec, U');
    end
%     NBz = D.blocks(2).fDecoder.NulM2;
%     RBz = D.blocks(2).fDecoder.RowM2;
%     Z = Z*(NBz*NBz') + D.blocks(2).latents*(RBz*RBz');
end

function inds = getRowDists(Y1, Y2, RB2, kNN)
    dsR = pdist2(Y2*RB2, Y1*RB2);
    [~,inds] = sort(dsR,2);
    if numel(inds) > kNN
        inds = inds(:,1:kNN);
    end
end

