function everythingIsGonnaBeOkay(Blk, dec)
% confirm all things are as they should be    
    
    matSum = @(A) max(sum(A.^2,2));
    mapAngle = @(a, b) rad2deg(subspace(a, b));
    
    % confirm Nul and Row bases are orthogonal
    assertAndPrint(matSum(Blk.NB'*Blk.RB), 'NB orth RB');
    assertAndPrint(matSum(Blk.NB_spikes'*Blk.RB_spikes), ...
        'NBs orth RBs');
    
    % confirm decoder matches Row basis
    assertAndPrint(mapAngle(orth(Blk.M2'), Blk.RB), 'M2 RB angle', 0);
    assertAndPrint(mapAngle(orth(Blk.M2'), Blk.NB), 'M2 NB angle', 90);
    assertAndPrint(mapAngle(Blk.RB, Blk.NB), 'RB NB angle', 90);
    
    % check spike and latent space bases are consistent
    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);
    assertAndPrint(mapAngle(beta'*Blk.RB, Blk.RB_spikes), ...
        'bRB RBs angle', 0);
    assertAndPrint(mapAngle(beta'*Blk.RB, Blk.NB_spikes), ...
        'bRB NBs angle', 90);
    
    % confirm decoder produces velocities
    errs = checkDecoderVelocities(Blk, Blk.latents);
    assertAndPrint(matSum(errs), 'latent decoder errors', 0);
    errs = checkDecoderVelocities(Blk, Blk.spikes);
    assertAndPrint(matSum(errs), 'spikes decoder errors', 0);
    
end

function errs = checkDecoderVelocities(Blk, Y)    
    if size(Y,2) > 10
        M0 = Blk.M0_spikes;
        M1 = Blk.M1_spikes;
        M2 = Blk.M2_spikes;
    else
        M0 = Blk.M0;
        M1 = Blk.M1;
        M2 = Blk.M2;
    end
    
    ts = Blk.trial_index;
    vel = Blk.vel;
    velNext = Blk.velNext;
    
    trs = sort(unique(ts));
    errs = cell(numel(trs),1);
    for ii = 1:numel(trs)
        ix = trs(ii) == ts;
        vs = vel(ix,:);
        vsn = velNext(ix,:);
        us = Y(ix,:);
        errs{ii} = nan(size(vs,1),1);
        for jj = 1:size(vs,1)
            x1 = vsn(jj,:)';
            x0 = vs(jj,:)';
            z1 = us(jj,:)';
            x1_h = M1*x0 + M2*z1 + M0;
            errs{ii}(jj) = norm(x1_h - x1);
        end
    end
    errs = cell2mat(errs);
end

function assertAndPrint(val, msg, goal, tol)
    if nargin < 4
        tol = 1e-5;
    end
    if nargin < 3
        goal = 0;
    end
    if abs(val - goal) > tol
        warning([msg ' (goal: ' num2str(goal) ' val: ' num2str(val) ')']);
    end
end
