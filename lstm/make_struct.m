function G = make_struct_2(F, fnm)
%     D = io.quickLoadByDate(dtstr);
%     F = pred.prepSession(D, struct('skipFreezePeriod', false));
    if nargin < 2
        fnm = '';
    end
    
    assert(isfield(F, 'train'));
    G.train = makeBlock(F, false);
    G.test = makeBlock(F, true);
    if ~isempty(fnm)
        save(fullfile('lstm', 'data', 'input', [fnm '.mat']), 'G');
    end
end

function G = makeBlock(F, isPert)
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
    Y = G.latents;
    ths = G.thetas;
    dec = G;
    vels = G.vel;
    
    G.Yn = Y*N;
    G.Yr = Y*R;
    G.X_on = G.time >= 6; % freeze period over
    
    % find intuitive time step achieving maximum progress given theta
    vs = velsThroughDec(F.train.latents, dec);
    angs = [cosd(ths) sind(ths)];
    progs = vs*angs';
    [~,inds] = max(progs);
    Yh = F.train.latents(inds,:);
    G.Yr_goal = Yh*R;
    G.Yn_goal = Yh*N;
    
    gs = tools.thetaGroup(tools.computeAngles(vels), tools.thetaCenters);
    gs(isnan(gs)) = -1;
    G.gs = gs;
    
%     if isPert
%         % do normal cloud goal
%         Yr1 = F.train.latents*R;
%         Yr2 = F.test.latents*R;
%         ds = pdist2(Yr2, Yr1); % nz2 x nz1
%         [~, inds] = min(ds, [], 2);
%         Yh = F.train.latents(inds,:);
%         G.Yr_goal = Yh*R;
%         G.Yn_goal = Yh*N;
%     end

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
    if isfield(Blk, 'pos')
        Blk.pos = bsxfun(@minus, Blk.pos, zPos);
    end
    
    Blk.vel(Blk.time < 6,:) = 0.0; % zero out velocity during freeze period
    Blk.velNext(Blk.time < 5,:) = 0.0;
end
