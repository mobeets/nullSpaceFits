%% load

d = load('data/Lincoln/20131205/20131205simpleData.mat');
e = load('data/Lincoln/20131205/kalmanInitParamsFA20131205_11.mat');

clear D;
D.simpleData = d.simpleData;
D.kalmanInitParams = e.kalmanInitParams;

%% init

% 1 = intuitive trial, 2 = perturbation trial, 3 = washout trial
D.trial_blocks = getTrialsByBlock(D);

% convert spikes on one trial to factor activity
sps = D.simpleData.spikeBins{1};
[lts, beta] = convertRawSpikesToRawLatents(D.simpleData.nullDecoder, sps);

% adds M0,M1,M2 for all blocks, for spike and factor decoder
D = addDecoders(D);
confirmDecoder; % read this to see how BCI equation works

%% visualize cursor traces for each intuitive trial

figure; set(gcf, 'color', 'w'); hold on;
for ii = 1:numel(D.simpleData.decodedPositions)
    if D.trial_blocks(ii) ~= 1 % only show intuitive trials
        continue;
    end
    pos = D.simpleData.decodedPositions{ii};
    trg = D.simpleData.targetLocations(ii,1:2);
    plot(pos(1,1), pos(1,1), 'k+'); % origin
    plot(trg(1), trg(2), 'ko', 'MarkerSize', 25); % target
    plot(pos(:,1), pos(:,2), 'k-'); % cursor position
end
axis equal;
