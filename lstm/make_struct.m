function G = make_struct(F, fnm, skipExtras)
% ps = io.setFilterDefaults(dtstr);
% ps.MIN_DISTANCE = nan; ps.MAX_DISTANCE = nan;
% D = io.quickLoadByDate(dtstr, ps);
% F = pred.prepSession(D, struct('skipFreezePeriod', false));

    if nargin < 2
        fnm = '';
    end
    if nargin < 3
        skipExtras = false;
    end
    
    assert(isfield(F, 'train'));
    G.train = makeBlock(F, false, skipExtras);
    G.test = makeBlock(F, true, skipExtras);
    if ~isempty(fnm)
        save(fullfile('lstm', 'data', 'input', [fnm '.mat']), 'G');
    end
end

function G = makeBlock(F, isPert, skipExtras)
% 1. LSTM-null: Y^n(t) = f( Y^n(<t), Y^r(?t), X(?t) )
% 	- can train simply using intuitive activity through perturbation mapping
% 2. LSTM-potent: Y^r(t) = f( Y^n(<t), Y^r(<t), X(?t), H(t) )
% 	- H(t) is the current activity goal
% 		- during perturbation, this is the intuitive activity that would yield the nearest value of the desired potent activity
% 		- during intuitive session, this is the intuitive activity that would yield the best velocity towards the target
% 	- can train using intuitive activity through perturbation mapping
    
    N = F.test.NB;
    R = F.test.RB;
    
    if isPert
        G = prepBlock(F.test);
%         Y = F.test.latents;
%         ths = F.test.thetas;
%         dec = F.test;
%         vels = F.test.vel;
    else
        G = prepBlock(F.train);
%         Y = F.train.latents;
%         ths = F.train.thetas;
%         dec = F.train;
%         vels = F.train.vel;
    end
    if skipExtras
        return;
    end
    Y = G.latents;
    ths = G.thetas;
    dec = G;
    
    G.Yn = Y*N;
    G.Yr = Y*R;
    G.X_on = G.time >= 6; % freeze period over
    
%     gs = tools.computeAngles(velsThroughDec(Y, F.test));
    gs = ths;
    gs = tools.thetaGroup(gs, tools.thetaCenters);
    gs(isnan(gs)) = -1;
    gs(~G.X_on) = -1;
    G.gs = gs;
    
%     ix = any(isnan(Y),2) | any(isnan(ths),2) | any(isnan(vels),2);
    
    % find intuitive time step achieving maximum progress given theta
    vs = velsThroughDec(F.train.latents, dec);
    angs = [cosd(ths) sind(ths)];
    progs = vs*angs';
    [~,inds] = max(progs);
    Yh = F.train.latents(inds,:);
    G.Yr_maxprog = Yh*R;
    G.Yn_maxprog = Yh*N;
    
    if isPert
        % do normal cloud goal
        Yr1 = F.train.latents*R;
        Yr2 = F.test.latents*R;
        ds = pdist2(Yr2, Yr1); % nz2 x nz1
        [~, inds] = min(ds, [], 2);
        Yh = F.train.latents(inds,:);
        G.Yr_goal = Yh*R;
        G.Yn_goal = Yh*N;
    else
        % do normal cloud goal
        Yr1 = F.test.latents*R;
        Yr2 = F.train.latents*R;
        ds = pdist2(Yr2, Yr1); % nz2 x nz1
        [~, inds] = min(ds, [], 2);
        Yh = F.test.latents(inds,:);
        G.Yr_goal = Yh*R;
        G.Yn_goal = Yh*N;
    end

end

function vs = velsThroughDec(Y, dec)
% v = (I - A)\(Bu + c)
    vs = bsxfun(@plus, Y*dec.M2', dec.M0');
    vs = ((eye(size(dec.M1)) - dec.M1)\vs')';
end

function Blk = prepBlock(Blk)
    
    % center target and cursor position
    zPos = mean(unique(Blk.target, 'rows'));
    Blk.target = bsxfun(@minus, Blk.target, zPos);
    Blk.targetAngle = round(tools.computeAngles(Blk.target));
    if isfield(Blk, 'pos')
        Blk.pos = bsxfun(@minus, Blk.pos, zPos);
    end
    
    Blk.vel(Blk.time < 6,:) = 0.0; % zero out velocity during freeze period
    Blk.velNext(Blk.time < 5,:) = 0.0;
end
