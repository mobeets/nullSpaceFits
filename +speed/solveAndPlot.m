%% init

B = F.test; % single session
lb = min(B.spikes); % [1 x 88]
ub = max(B.spikes); % [1 x 88]
M2 = B.M2_spikes; % [2 x 88]
M0 = B.M0_spikes; % [2 x 1]
mu = F.dec.spikeCountMean; % [1 x 88]
beta = speed.getBetaFromFA(F.dec); % [10 x 88]

%% find firing rates maximizing progress in different movement directions

angs = linspace(0, 360, 100)';
[progs, vels, ss, us] = speed.findAllMaxProgress(angs, M2, M0, ...
    beta, mu, lb, ub);

%% plot maximal progress along with actual observed velocities

speed.plotMaxProgress(progs, nan, false);
vs_emp = (45/1000)*bsxfun(@plus, M2*B.spikes', M0)';
% plot(vs_emp(:,1), vs_emp(:,2), 'k.');
