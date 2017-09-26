%% confirm spiking decoder

ndec = D.blocks(1).nDecoder; % intuitive spikes decoder
fdec = D.blocks(1).fDecoder; % intuitive spikes decoder
trs = 1:numel(D.simpleData.decodedPositions); % all trials
trs = trs(D.trial_blocks == 1); % keep intuitive trials only
gain = 45/1000; % each time bin is 45 msec

for ii = 1:numel(trs)
    tr = trs(ii);
    sps = D.simpleData.spikeBins{tr}; % spikes on this trial
    fac = convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps);
    pos = D.simpleData.decodedPositions{tr}; % cursor position
    vel = D.simpleData.decodedVelocities{tr}; % cursor velocity
    
    % cursor is frozen for first 6 time steps
    sps = sps(6:end,:);
    fac = fac(6:end,:);
    pos = pos(6:end,:);
    vel = vel(6:end,:);

    nt = size(sps,1); % length of trial (in time steps)
    for jj = 2:nt
        p1 = pos(jj,:)'; % current position
        p0 = pos(jj-1,:)'; % previous position
        v1 = vel(jj,:)'; % current velocity        
        v0 = vel(jj-1,:)'; % previous velocity
        
        % check spiking decoder
        u1 = sps(jj,:)'; % current spiking activity        
        v1_h = ndec.M1*v0 + ndec.M2*u1 + ndec.M0; % decoder update equation
        assert(norm(v1_h - v1) < 1e-3); % ensure we can reproduce vel
        
        % check factor decoder
        z1 = fac(jj,:)'; % current factor activity
        v1_h = fdec.M1*v0 + fdec.M2*z1 + fdec.M0; % decoder update equation
        assert(norm(v1_h - v1) < 1e-3); % ensure we can reproduce vel
        
        % confirm position matches
        p1_h = p0 + gain*v1; % position update equation
        assert(norm(p1_h - p1) < 1e-3); % ensure we can reproduce pos
    end
end
