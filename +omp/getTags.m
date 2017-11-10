%% multi-day intuitive sessions

dts = {'20150212', '20150308', '20160717'};

for jj = 1:numel(dts)
    dtstr = dts{jj}
    d = load(['data/omp/multiDayIntuitive/' dtstr '.mat']);

    days = [];
    for ii = 1:numel(d.longTerm)
        day.dayInd = ii;
        day.name = 'Intuitive';
        day.trialTags = unique(d.longTerm{ii}.simpleData.trialTag);
        days = [days day];
    end

    save(fullfile('data', 'omp', 'multiDayIntuitive', ...
        [dtstr '-tags.mat']), 'days');
end

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 3 4 5 6 8 9 10 11 12]
% full OMP tag = [15 4 3 5 4 4 7 4 5 4]
% washout tag = 5 (day 12)

dtstr = '20141211';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

daynums = [1 3 4 5 6 8 9 10 11 12];
daytags = [15 4 3 5 4 4 7 4 5 4];
for ii = 1:numel(daynums)
    day.dayInd = daynums(ii);
    day.name = 'OMP';
    day.trialTags = daytags(ii);
    days = [days day];
end

day.dayInd = 12;
day.name = 'Washout';
day.trialTags = 5;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 7]
% full OMP tag = [14 7]
% washout tag = 6 (day 8)

dtstr = '20141202';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

daynums = [1 7];
daytags = [14 7];
for ii = 1:numel(daynums)
    day.dayInd = daynums(ii);
    day.name = 'OMP';
    day.trialTags = daytags(ii);
    days = [days day];
end

day.dayInd = 8;
day.name = 'Washout';
day.trialTags = 6;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 4 5 6 8 9]
% full OMP tag = [16 3 1 7 4 3]
% washout tag = 4 (day 9)

dtstr = '20141117';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

daynums = [1 4 5 6 8 9];
daytags = [16 3 1 7 4 3];
for ii = 1:numel(daynums)
    day.dayInd = daynums(ii);
    day.name = 'OMP';
    day.trialTags = daytags(ii);
    days = [days day];
end

day.dayInd = 9;
day.name = 'Washout';
day.trialTags = 4;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 6 7 11 12 13]
% full OMP tag = [15 3 1 4 3 7]
% washout tag = 8 (day 13)

dtstr = '20141104';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

daynums = [1 6 7 11 12 13];
daytags = [15 3 1 4 3 7];
for ii = 1:numel(daynums)
    day.dayInd = daynums(ii);
    day.name = 'OMP';
    day.trialTags = daytags(ii);
    days = [days day];
end

day.dayInd = 13;
day.name = 'Washout';
day.trialTags = 8;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 5 6 7 8 9 10 11 12 13 14 15 16]
% full OMP tag = [15 3 4 3 3 2 2 1 1 1 1 1 1]
% washout tag = 2 (day 16)

dtstr = '20141013';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

daynums = [1 5 6 7 8 9 10 11 12 13 14 15 16];
daytags = [15 3 4 3 3 2 2 1 1 1 1 1 1];
for ii = 1:numel(daynums)
    day.dayInd = daynums(ii);
    day.name = 'OMP';
    day.trialTags = daytags(ii);
    days = [days day];
end

day.dayInd = 16;
day.name = 'Washout';
day.trialTags = 2;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

% intuitive day 1 tag =  [7 8]
% full OMP day = [1 5 6 7 8]
% full OMP tag = [13 1 1 1 1]
% washout tag = n/a (day 8)

dtstr = '20140929';

days = [];
day.dayInd = 1;
day.name = 'Intuitive';
day.trialTags = [7 8];
days = [days day];

day.dayInd = 1;
day.name = 'OMP';
day.trialTags = 13;
days = [days day];

day.dayInd = 5;
day.name = 'OMP';
day.trialTags = 1;
days = [days day];

day.dayInd = 6;
day.name = 'OMP';
day.trialTags = 1;
days = [days day];

day.dayInd = 7;
day.name = 'OMP';
day.trialTags = 1;
days = [days day];

day.dayInd = 8;
day.name = 'OMP';
day.trialTags = 1;
days = [days day];

day.dayInd = 8;
day.name = 'Washout';
day.trialTags = nan;
days = [days day];

save(fullfile('data', 'omp', dtstr, 'tags.mat'), 'days');

%%

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
