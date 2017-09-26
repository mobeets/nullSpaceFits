
% intuitive day 1 tag =  [7 8]
% full OMP day = [1 5 6 7 8]
% full OMP tag = [9 6 4 3 4]
% washout tag = 5 (day 8)

dtstr = '20160415';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 5;
day.name = 'OMP';
day.trialTags = 6;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 7;
day.name = 'OMP';
day.trialTags = 3;
days = [days day];

day.dayInd = 8;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 8;
day.name = 'Washout';
day.trialTags = 5;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 5 6 7 8]
% full OMP tag = [9 4 4 3 3]
% washout tag = 4 (day 8)

dtstr = '20160505';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 5;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 7;
day.name = 'OMP';
day.trialTags = 3;
days = [days day];

day.dayInd = 8;
day.name = 'OMP';
day.trialTags = 3;
days = [days day];

day.dayInd = 8;
day.name = 'Washout';
day.trialTags = 4;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 4 5 6]
% full OMP tag = [9 4 4 4]
% washout tag = 5 (day 6)

dtstr = '20160513';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 4;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 5;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 6;
day.name = 'Washout';
day.trialTags = 5;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 5 7]
% full OMP tag = [9 4 4]
% washout tag = 5 (day 7)

dtstr = '20160529';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 5;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 7;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 7;
day.name = 'Washout';
day.trialTags = 5;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

dtstr = '20160617';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 7;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 8;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 8;
day.name = 'Washout';
day.trialTags = 5;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 6 9 10 11]
% full OMP tag = [9 4 4 3 3]
% washout tag = 4 (day 11)

dtstr = '20160628';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 9;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 9;
day.name = 'OMP';
day.trialTags = 4;
days = [days day];

day.dayInd = 10;
day.name = 'OMP';
day.trialTags = 3;
days = [days day];

day.dayInd = 11;
day.name = 'OMP';
day.trialTags = 3;
days = [days day];

day.dayInd = 11;
day.name = 'Washout';
day.trialTags = 4;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');
