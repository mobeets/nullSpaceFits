function blk = getSpikes(d, trialTags, ctrg, ...
    ignoreIncorrects, useCTAngle, skipFreeze)
    if nargin < 3
        ctrg = nan;
    end
    if nargin < 4
        ignoreIncorrects = true;
    end
    if nargin < 5
        useCTAngle = true;
    end
    if nargin < 6
        skipFreeze = true;
    end
    % center targets and compute target angle
    trgpos = d.targetLocations(:,1:2);
    mutrgs = mean(unique(trgpos, 'rows'));
    trgs = bsxfun(@minus, trgpos, mutrgs);
    trgs = round(tools.computeAngles(trgs));
    trgs = mod(-trgs, 360); % need to flip y-axis

    % make trials
    trs = arrayfun(@(ii) ii*ones(numel(d.binTimes{ii}),1), ...
        1:size(d.binTimes,1), 'uni', 0)';
    trgs = arrayfun(@(ii) trgs(ii)*ones(numel(d.binTimes{ii}),1), ...
        1:size(d.binTimes,1), 'uni', 0)';
    trgpos = arrayfun(@(ii) repmat(trgpos(ii,:), ...
        numel(d.binTimes{ii}), 1), 1:size(d.binTimes,1), 'uni', 0)';
    
    % filter trials
    ix = ismember(d.trialTag, trialTags);
    if ignoreIncorrects
        ix = ix & (d.trialStatus == 1);
    end
    sps = cell2mat(d.spikeBins(ix));
    pos = cell2mat(d.decodedPositions(ix));
    vel = cell2mat(d.decodedVelocities(ix));
    trs = cell2mat(trs(ix));
    trgs = cell2mat(trgs(ix));
    trgpos = cell2mat(trgpos(ix,:));
    tms = cell2mat(d.binTimes(ix));
    ths = getCTAngle(d.decodedPositions(ix), d.targetLocations(ix,1:2));
    thgrps = tools.thetaGroup(ths, tools.thetaCenters);
    
    % filter time steps
    if skipFreeze
        ixt = tms > 45*7; % ignore freeze period
    else
        ixt = true(size(tms));
    end
    if ~isnan(ctrg)
        if useCTAngle                
            ixt = ixt & (thgrps == ctrg);
        else
            ixt = ixt & (trgs == ctrg);
        end
    end
    blk.sps = sps(ixt,:);
    blk.pos = pos(ixt,:);
    blk.vel = vel(ixt,:);
    blk.trs = trs(ixt,:);
    blk.trgs = trgs(ixt,:);
    blk.trgpos = trgpos(ixt,:);
    blk.ths = ths(ixt,:);
    blk.thgrps = thgrps(ixt,:);
    blk.opts.trialTags = trialTags;
    blk.opts.ctrg = ctrg;
    blk.opts.ignoreIncorrects = ignoreIncorrects;
    blk.opts.useCTAngle = useCTAngle;
    blk.opts.skipFreeze = skipFreeze;
end

function angs = getCTAngle(ps, trgs)
    ctf = @(pc, trg) tools.computeAngles(bsxfun(@plus, -pc, trg));
    angs = arrayfun(@(ii) ctf(ps{ii}, trgs(ii,:)), 1:size(ps,1), 'uni', 0);
    angs = cell2mat(angs');
    angs = mod(-angs, 360);
end
