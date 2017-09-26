function isOk = everythingIsGonnaBeOkay(Blk, dec, useIme, confirmNoFreeze)
% confirm all things are as they should be
    if nargin  < 4
        confirmNoFreeze = false;
    end
    
    matSum = @(A) max(sum(A.^2,2));
    trMeanTooHigh = @(A) cellfun(@(a) nanmean(a.^2), A) > 1e-5;
    mapAngle = @(a, b) rad2deg(subspace(a, b));
    
    % confirm Nul and Row bases are orthogonal
    v1 = assertAndPrint(matSum(Blk.NB'*Blk.RB), 'NB orth RB');
    v2 = assertAndPrint(matSum(Blk.NB_spikes'*Blk.RB_spikes), ...
        'NBs orth RBs');
    
    % confirm decoder matches Row basis
    v3 = assertAndPrint(mapAngle(orth(Blk.M2'), Blk.RB), 'M2 RB angle', 0);
    v4 = assertAndPrint(mapAngle(orth(Blk.M2'), Blk.NB), 'M2 NB angle', 90);
    v5 = assertAndPrint(mapAngle(Blk.RB, Blk.NB), 'RB NB angle', 90);
    
    % check spike and latent space bases are consistent
    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);
    v6 = assertAndPrint(mapAngle(beta'*Blk.RB, Blk.RB_spikes), ...
        'bRB RBs angle', 0);
    v7 = assertAndPrint(mapAngle(beta'*Blk.RB, Blk.NB_spikes), ...
        'bRB NBs angle', 90);
    
    % confirm decoder produces velocities
    if ~useIme
        errs = checkDecoderVelocities(Blk, Blk.latents);
        v8 = assertAndPrint(sum(trMeanTooHigh(errs)), ...
            'latent decoder errors', 0, 2);
        errs = checkDecoderVelocities(Blk, Blk.spikes);
        v9 = assertAndPrint(sum(trMeanTooHigh(errs)), ...
            'spike decoder errors', 0, 2);
    else
        % IME velocities are not as easily verified... :(
        v8 = true; v9 = true;
    end
    if confirmNoFreeze
        v10 = all(Blk.time >= 5); % no freeze period activity
    else
        v10 = true;
    end
    isOk = all([v1 v2 v3 v4 v5 v6 v7 v8 v9 v10]);
    
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
    tm = Blk.time;
    vel = Blk.vel;
    velNext = Blk.velNext;
    
    trs = sort(unique(ts));
    errs = cell(numel(trs),1);
    for ii = 1:numel(trs)
        ix = trs(ii) == ts & tm > 5; % freeze period
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
%     errs = cell2mat(errs);
end

function isOk = assertAndPrint(val, msg, goal, tol)
    if nargin < 4
        tol = 1e-5;
    end
    if nargin < 3
        goal = 0;
    end
    isOk = true;
    if abs(val - goal) > tol
        isOk = false;
        warning([msg ' (goal: ' num2str(goal) ', val: ' num2str(val) ')']);
    end
end
