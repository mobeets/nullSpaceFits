
dts = omp.getDates(false);
dtstr = dts{1};

fnm = ['data/omp/multiDayIntuitive/' dtstr '.mat'];
knmI = ['data/omp/multiDayIntuitive/kalmanInitParamsFA' dtstr '_6.mat'];
fnmTags = ['data/omp/multiDayIntuitive/' dtstr '-tags.mat'];
d = load(fnm);
kI = load(knmI);
tags = load(fnmTags);

%% activity during intuitive mappings

% Intuitive activity
ndays = numel(d.longTerm);
blks = [];
for dayInd = 1:ndays
    trialTags = tags.days(dayInd).trialTags;
    blk = omp.getSpikes(d.longTerm{dayInd}.simpleData, trialTags, ...
        nan, false, false, false);
    blk.name = 'Intuitive';
    blk.dayInd = dayInd;
    blks = [blks blk];
end

%% daily averages

clrs = cbrewer('seq', 'Reds', ndays+2);
plot.init;

for ii = 1:numel(blks)
    blk = blks(ii);
    ix = (blk.tms >= 3) & (blk.tms <= 9);
    sps = blk.sps(ix,:);
    mus = grpstats(sps, blk.trgs(ix), @nanmean);
    sds = grpstats(sps, blk.trgs(ix), @nanstd);
    trgs = unique(blk.trgs(ix));
    
    for jj = 1:size(blk.sps,2)
        subplot(10,10,jj); hold on;
%         plot(mus(:,jj), sds(:,jj), '.', 'Color', clrs(ii+2,:));
        plot(trgs, mus(:,jj), '-', 'Color', clrs(ii+2,:));
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
%         plot(ii, mean(sps), 'k.');
    end
end
% xlabel('mean'); ylabel('s.d.');

%% delta averages

clrs = cbrewer('seq', 'Reds', ndays+2);
plot.init;

lastmus = [];
lastsds = [];

for ii = 1:numel(blks)
    blk = blks(ii);
    ix = (blk.tms >= 3) & (blk.tms <= 9);
    sps = blk.sps(ix,:);
    mus = grpstats(sps, blk.trgs(ix), @nanmean);
    sds = grpstats(sps, blk.trgs(ix), @nanstd);
    trgs = unique(blk.trgs(ix));
    if ii == 1
        lastmus = mus;
        lastsds = sds;
        continue;
    end
    
    for jj = 1:size(blk.sps,2)
        subplot(10,10,jj); hold on;
        
        plot(mus(:,jj) - lastmus(:,jj), ...
            sds(:,jj) - lastsds(:,jj), '-', 'Color', clrs(ii+2,:));
%         plot(trgs, mus(:,jj) - lastmus(:,jj), ...
%             '-', 'Color', clrs(ii+2,:));
%         plot(trgs, sds(:,jj) - lastsds(:,jj), ...
%             '-', 'Color', clrs(ii+2,:));
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
%         plot(ii, mean(sps), 'k.');
    end
    lastmus = mus;
    lastsds = sds;
end
xlabel('\Delta mean'); ylabel('\Delta s.d.');
% % xlabel('target'); ylabel('\Delta mean');
% xlabel('target'); ylabel('\Delta s.d.');

%% delta averages vs. correlations

clrs = cbrewer('seq', 'Reds', ndays+2);
plot.init;

lastmus = [];
lastsds = [];
neuronIndex = 61;

for ii = 1:numel(blks)
    blk = blks(ii);
    ix = (blk.tms >= 3) & (blk.tms <= 9);
    sps = blk.sps(ix,:);
    mus = grpstats(sps, blk.trgs(ix), @nanmean);
    sds = grpstats(sps, blk.trgs(ix), @nanstd);
    crs = corr(sps);
    
    trgs = unique(blk.trgs(ix));
    if ii == 1
        lastmus = mus;
        lastsds = sds;
        continue;
    end
    
    for jj = 1:size(blk.sps,2)
        subplot(10,10,jj); hold on;
        
        plot(norm(mus(:,neuronIndex) - lastmus(:,neuronIndex)), ...
            crs(jj,neuronIndex), '.', 'Color', clrs(ii+2,:));
%         plot(norm(mus(:,neuronIndex) - lastmus(:,neuronIndex)), ...
%             norm(mus(:,jj) - lastmus(:,jj)), '.', 'Color', clrs(ii+2,:));
        
%         plot(mus(:,jj) - lastmus(:,jj), ...
%             sds(:,jj) - lastsds(:,jj), '-', 'Color', clrs(ii+2,:));
%         plot(trgs, mus(:,jj) - lastmus(:,jj), ...
%             '-', 'Color', clrs(ii+2,:));
%         plot(trgs, sds(:,jj) - lastsds(:,jj), ...
%             '-', 'Color', clrs(ii+2,:));
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        plot(xlim, [0 0], 'k-');
        ylim([-1 1]);
%         plot(ii, mean(sps), 'k.');
    end
    lastmus = mus;
    lastsds = sds;
end
% xlabel('\Delta mean'); ylabel('\Delta s.d.');
% % xlabel('target'); ylabel('\Delta mean');
% xlabel('target'); ylabel('\Delta s.d.');
xlabel(['\Delta mean neur ' num2str(neuronIndex)]); ylabel('correlation');
% xlabel(['\Delta mean neur ' num2str(neuronIndex)]); ylabel(['\Delta mean neur cur']);
