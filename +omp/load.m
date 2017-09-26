%% load 

fnm = 'data/omp/coaching20160617.mat';
knmI = 'data/omp/kalmanInitParamsFA20160617_6.mat';
knmP = 'data/omp/kalmanInitParamsFA20160617_12.mat';
d = load(fnm);
kI = load(knmI);
kP = load(knmP);

%% activity during intuitive mappings

% Intuitive activity
dayInd = 1;
trialTags = [7 8];
blkI = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkI.name = 'Intuitive';

% OMP activity - day 1
dayInd = 1;
trialTags = 9;
blkP_1 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_1.name = 'OMP-d1';

% OMP activity - day 6
dayInd = 6;
trialTags = 4;
blkP_6 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_6.name = 'OMP-d6';

% OMP activity - day 7
dayInd = 7;
trialTags = 4;
blkP_7 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_7.name = 'OMP-d7';

% OMP activity - day 8
dayInd = 8;
trialTags = 4;
blkP_8 = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkP_8.name = 'OMP-d8';

% Washout activity
dayInd = 8;
trialTags = 5;
blkW = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
blkW.name = 'Washout';

blks = [blkI, blkP_1, blkP_6, blkP_7, blkP_8, blkW];

% best 40 trials for each OMP, start trial:
% 220 (day 1)
% 47 (day 6)
% 199 (day 7)
% 348 (day 8)

%% decoders

decI.M0 = kI.kalmanInitParams.M0;
decI.M1 = kI.kalmanInitParams.M1;
decI.M2 = kI.kalmanInitParams.M2;
decP.M0 = kP.kalmanInitParams.M0;
decP.M1 = kP.kalmanInitParams.M1;
decP.M2 = kP.kalmanInitParams.M2;
decI.vfcn = @(y) bsxfun(@plus, decI.M2*y, decI.M0);
decP.vfcn = @(y) bsxfun(@plus, decP.M2*y, decP.M0);

% prgI = lstmat.getProgress(blks(1).sps, blks(1).pos, blks(1).trgpos, ...
%     decI.vfcn);
prgI = lstmat.getProgress(blks(1).sps, blks(1).pos, blks(1).trgpos, ...
    [], blks(1).vel);

%% re-fit FA

dayInd = 1;
trialTags = [7 8];
spsC = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags, nan, ...
    true, true, false); % include freeze activity
decs = omp.fitFA(spsC, 20);
