function trials = makeTrials(D)

    % collect the fields we'll need, and compute a few more
    d = D.simpleData;    
    ts = struct([]);
    ntrials = numel(d.spikeBins);
    tblkinds = io.getTrialsByBlock(D);
    for tr = 1:ntrials        
        trial = struct();        
        ntimes = size(d.spikeBins{tr},1);
        
%         trial.spikes = d.spikeBins{tr};
        % the below shifts all timepoints of spikes by 1 (what pete did)
        spikes = d.spikeBins{tr};
        if isempty(spikes)
            warning(['Missing trial: in ' D.datestr ': ' num2str(tr)]);
            continue;
        end
        trial.spikes = nan(size(spikes));
        trial.spikes(1:end-1,:) = spikes(2:end,:);
        
        trial.pos = d.decodedPositions{tr};
        trial.vel = d.decodedVelocities{tr};
        trial.spd = arrayfun(@(ii) norm(trial.vel(ii,:)), 1:ntimes)';        
        trial.target = repmat(d.targetLocations(tr, 1:2), ntimes, 1);
        trial.targetAngle = d.targetAngles(tr)*ones(ntimes,1);
        trial.trial_length = repmat(ntimes, ntimes, 1);
        trial.isCorrect = repmat(double(d.trialStatus(tr)), ntimes, 1);
        trial.trial_index = repmat(tr, ntimes, 1);
        trial.block_index = repmat(tblkinds(tr), ntimes, 1);
        trial = addNewFields(trial, D);
        ts = [ts trial];
    end

    % flatten trials so that each timepoint is now a trial
    trials = struct();
    fns = fieldnames(ts);
    for ii = 1:numel(fns)
        val = cell2mat(cellfun(@(x) x', {ts.(fns{ii})}, 'uni', 0));
        trials.(fns{ii}) = val';
    end
    
    trials.thetas = mod(trials.thetas, 360);
    trials.thetaActuals = mod(trials.thetaActuals, 360);
    trials.thetaGrps = tools.thetaGroup(trials.thetas, ...
        tools.thetaCenters(8));

    % add latents
    trials.latents = tools.convertRawSpikesToRawLatents(...
        D.simpleData.nullDecoder, trials.spikes');
	
    % add other stuff
    trials = addExtraFields(trials);
end

function trial = addNewFields(trial, D)

    trial.vec2target = trial.target - trial.pos;
    movementVector = diff(trial.pos);
%     trial.movementVector = [nan nan; movementVector];
    trial.movementVector = [movementVector; nan nan];

%     pos_tp1 = trial.pos(:,T_START+1:end);
%     pos_t = trial.pos(:,T_START:end-1);
%     [angles, theta, phi, p] = angular_error_from_perimeter(pos_t, ...
%         pos_tp1, trial.target(1,:), TARGET_RADIUS);
    
    ntimes = size(trial.spikes,1);
    trial.time = (1:ntimes)';
    trial.rs = nan(ntimes,1);
    trial.thetas = nan(ntimes,1);
    trial.thetaActuals = nan(ntimes,1);
    trial.angError = nan(ntimes,1);
    trial.velStar = nan(ntimes,2);
    trial.velPrev = nan(ntimes,2);
    trial.velNext = nan(ntimes,2);
    trial.progress = nan(ntimes,1);
    % we must skip last entry so we can use movementVector
    for t = 1:ntimes-1
        vec2trg = trial.vec2target(t,:);
        movVec = trial.movementVector(t,:);
        r = norm(vec2trg);
        theta = tools.computeAngle(vec2trg, [1; 0]);
        thetaActual = tools.computeAngle(movVec, [1; 0]);
        prog = movVec*vec2trg'/norm(vec2trg);
        angErr = tools.computeAngle(movVec, vec2trg);
        velStar = D.params.IDEAL_SPEED*vec2trg/norm(vec2trg);
        if t > 1
            velPrev = trial.vel(t-1,:);
        else
            velPrev = [0 0];
        end
        trial.progress(t) = prog;
        trial.rs(t) = r;        
        trial.thetas(t) = theta;
        trial.thetaActuals(t) = thetaActual;
        trial.angError(t) = angErr;
        trial.velStar(t,:) = velStar;
        trial.velPrev(t,:) = velPrev;
        trial.velNext(t,:) = trial.vel(t+1,:);
    end

end

function trials = addExtraFields(trials)
    trials.angErrorAbs = abs(trials.angError);
    trials.thetaActualGrps = tools.thetaGroup(trials.thetaActuals, ...
        tools.thetaCenters(8));
    trials.thetaActualGrps16 = tools.thetaGroup(trials.thetaActuals, ...
        tools.thetaCenters(16));
    trials.thetaGrps16 = tools.thetaGroup(trials.thetas, ...
        tools.thetaCenters(16));
    trials.progressOrth = addProgressOrth(trials);
end

function progOrth = addProgressOrth(trials)

    progOrth = nan(size(trials.progress));
    for t = 1:numel(trials.progress)
        vec2trg = trials.vec2target(t,:);
        vec2trgOrth(1) = vec2trg(2);
        vec2trgOrth(2) = -vec2trg(1);
        movVec = trials.movementVector(t,:);
        progOrth(t) = -(movVec*vec2trgOrth'/norm(vec2trg));
    end
end
