%% load
% runName = '';
% runName = '_20180606';
runName = '_20180619';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);

doSave = true;
saveDir = fullfile('data', 'fits', fitName);
fnm = fullfile(saveDir, 'errorFloor.mat');

%% compute error floors by splitting data in two

nboots = 100;
scs = nan(numel(F), nboots, 3);

grps = tools.thetaCenters;
for ii = 1:numel(F)
    f = F(ii);
    s = S(ii);
    f.datestr
    
    % get all output-null activity and groups
    ix = s.ixGs;
    gs = s.gs(ix);
    y = f.test.latents(ix,:);
    
    for kk = 1:nboots

        % shuffle data
        inds = randperm(numel(gs));
        y = y(inds,:);
        gs = gs(inds,:);
        
        % split data, compute errors
        Yn = [];
        Ynh = [];
        gsc = [];
        for jj = 1:numel(grps)
            ix = gs == grps(jj);
            yc = y(ix,:);
            n = size(yc,1);

            % correct to make divisible by div
            nignore = mod(n,2);
            yc = yc(1:end-nignore,:);
            n = n - nignore;
            nc = n/2;
            Yn = [Yn; yc(1:nc,:)];
            Ynh = [Ynh; yc(nc+1:nc+nc,:)];
            gsc = [gsc; grps(jj)*ones(nc,1)];

        end

        Ynh = Ynh*f.test.NB;
        Yn = Yn*f.test.NB;
        if kk == 1
            [scs(ii,kk,1), nbins] = score.histErrorsFcn({Ynh}, Yn, gsc);
        else
            scs(ii,kk,1) = score.histErrorsFcn({Ynh}, Yn, gsc, nbins);
        end
        scs(ii,kk,2) = score.meanErrorFcn(Ynh, Yn, gsc);
        scs(ii,kk,3) = score.covErrorFcn(Ynh, Yn, gsc);

    end
    pts = scs;
    sd = nanstd(squeeze(nanmean(pts,2)));
    mu = nanmean(squeeze(nanmean(pts,2)));
    [mu - sd./sqrt(ii); mu; mu + sd./sqrt(ii)]
    [mu - sd; mu; mu + sd]
end

dts = {F.datestr};
ndts = numel(F);
pts = scs;
sd = nanstd(squeeze(nanmean(pts,2)));
mu = nanmean(squeeze(nanmean(pts,2)));
se = sd./sqrt(ndts);

if doSave
    save(fnm, 'scs', 'mu', 'sd', 'se', 'dts', 'nboots', 'ndts', 'dts');
end

%%

runName = '';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);
dts1 = {F.datestr};
ss = cellfun(@(s) s(end), {S.scores});
es1 = [ss.meanError];

runName = '_20180606';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);
dts2 = {F.datestr};
ss = cellfun(@(s) s(end), {S.scores});
es2 = [ss.meanError];

runName = '_20180619';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);
dts3 = {F.datestr};
ss = cellfun(@(s) s(end), {S.scores});
es3 = [ss.meanError];

alldts = intersect(intersect(dts1, dts2), dts2);
ix1 = ismember(dts1, alldts);
ix2 = ismember(dts2, alldts);
ix3 = ismember(dts3, alldts);

%%

runName = '';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);
dts1 = {F.datestr};
ss = cellfun(@(s) s(end), {S.scores});
es1 = [ss.meanError];

runName = '_20180619';
fitName = ['Int2Pert_yIme' runName];
[S,F] = plot.getScoresAndFits(fitName);
dts3 = {F.datestr};
ss = cellfun(@(s) s(end), {S.scores});
es3 = [ss.meanError];

alldts = intersect(dts1, dts3);
ix1 = ismember(dts1, alldts);
ix3 = ismember(dts3, alldts);

%%

[es1(ix1)' es2(ix2)' es3(ix3)']
plot.init; plot(es3(ix3), es2(ix2), '.');
xlim([0 3]); ylim(xlim); plot(xlim, ylim, 'k--');

%%

'--------'

fnm = 'data/fits/Int2Pert_yIme/errorFloor.mat';
d = load(fnm); scs1 = d.scs;
scs = scs1(ix1,:,:);
sd = nanstd(squeeze(nanmean(scs,2)));
mu1 = squeeze(nanmean(scs,2));
mu = nanmean(mu1);
[mu - sd; mu; mu + sd]

fnm = 'data/fits/Int2Pert_yIme_20180606/errorFloor.mat';
d = load(fnm); scs2 = d.scs;
scs = scs2(ix2,:,:);
sd = nanstd(squeeze(nanmean(scs,2)));
mu2 = squeeze(nanmean(scs,2));
mu = nanmean(mu2);
[mu - sd; mu; mu + sd]

fnm = 'data/fits/Int2Pert_yIme_20180619/errorFloor_v2.mat';
d = load(fnm); scs3 = d.scs;
scs = scs3(ix3,:,:);
sd = nanstd(squeeze(nanmean(scs,2)));
mu3 = squeeze(nanmean(scs,2));
mu = nanmean(mu3);
[mu - sd; mu; mu + sd]

%% compute scores if just splitting data in two

maxdiv = 2;
nboots = 100;
scs = nan(numel(F), maxdiv-1, nboots, 3);
scsh = nan(numel(F), maxdiv-1, nboots, 3);

% plot.init;
grps = tools.thetaCenters;
for ii = numel(F)
    f = F(ii);
    s = S(ii);
    f.datestr
    
    % get all output-null activity and groups
    ix = s.ixGs;
    gs = s.gs(ix);
    y = f.test.latents(ix,:);%*f.test.NB;
    
    for kk = 1:nboots

        % shuffle data
        inds = randperm(numel(gs));
        y = y(inds,:);
        gs = gs(inds,:);
        
        for div = 2:maxdiv
            % split data, compute errors
            Yn = [];
            Ynh = [];
            gsc = [];
            for jj = 1:numel(grps)
                ix = gs == grps(jj);
                yc = y(ix,:);
                n = size(yc,1);

                % correct to make divisible by div
                yc = yc(1:end-mod(n,div),:);
                n = n-mod(n,div);
                nc = n/div;
                Yn = [Yn; yc(1:nc,:)];
                Ynh = [Ynh; yc(nc+1:nc+nc,:)];
                gsc = [gsc; grps(jj)*ones(nc,1)];
                
            end
            
%             Ynh2 = f.train.latents;
%             if size(Ynh2,1) > size(Ynh,1)
%                 inds = randperm(size(Ynh2,1));
%                 inds = inds(1:size(Ynh,1));
%                 Ynh2 = Ynh2(inds,:);
%             end
%             
%             tr = f.train;
%             tr.latents = Ynh2;
%             te = f.test;
%             te.latents = Yn;
%             Ynh2 = hypfit.closestRowValFit(tr, te);
%             
%             Ynh2 = Ynh2*f.test.NB;
            Ynh = Ynh*f.test.NB;
            Yn = Yn*f.test.NB;
            histErrs = score.histErrorsFcn({Ynh}, Yn, gsc);
            scs(ii,div-1,kk,1) = histErrs(1);
            scs(ii,div-1,kk,2) = score.meanErrorFcn(Ynh, Yn, gsc);
            scs(ii,div-1,kk,3) = score.covErrorFcn(Ynh, Yn, gsc);
            
%             [histErrs, nbins] = score.histErrorsFcn({Ynh2}, Yn, gsc);
%             scsh(ii,div-1,kk,1) = histErrs(1);
%             scsh(ii,div-1,kk,2) = score.meanErrorFcn(Ynh2, Yn, gsc);
%             scsh(ii,div-1,kk,3) = score.covErrorFcn(Ynh2, Yn, gsc);
            
%             x = squeeze(scs(ii,:,:,:))';
%             y = squeeze(scsh(ii,:,:,:))';
%             nms = {'histErr', 'meanErr', 'covErr'};
%             bnds = [0.2 3 2.5];
%             for ll = 1:3
%                 subplot(3,1,ll); hold on;
%                 plot(x(ll), y(ll), 'k.', 'MarkerSize', 15);
%                 ylim([0 bnds(ll)]);
%                 xlim(ylim);
%                 plot(xlim, ylim, 'k--');
%                 xlabel([nms{ll} ' - true']);
%                 ylabel([nms{ll} ' - cloud']);
%             end
%             plot.setPrintSize(gcf, struct('width', 3.5, 'height', 7));
%             pause(0.1);            
        end
    end
    pts = scs;
    sd = nanstd(squeeze(nanmean(pts,3)));
    mu = nanmean(squeeze(nanmean(pts,3)));
    [mu - sd./sqrt(ii); mu; mu + sd./sqrt(ii)]
    [mu - sd; mu; mu + sd]
end

if doSave
    save(fnm, 'scs', 'scsh');
end

% histErr   muErr     covErr
% ---------------------------
% 0.0783    0.3644    1.2304
% 0.0815    0.3833    1.2927
% 0.0848    0.4021    1.3550

% muErr = 8.5174 spikes/s

% 
% Repeated with +/- SD instead of SE:
% 
% histErr   muErr     covErr
% ---------------------------
% 0.0619    0.2622    0.8929
% 0.0821    0.3845    1.2923
% 0.1023    0.5068    1.6917
% 

%%

plot.init;
nms = {'histErr', 'meanErr', 'covErr'};
for jj = 1:3
    subplot(3,1,jj); hold on; set(gca, 'FontSize', 16);
    
    sc = squeeze(mean(scs(:,:,:,jj), 3));
    sc(sc == inf) = nan;
    mu = nanmean(sc);

    xs = 1./(2:(size(scs,2)+1));
%     plot(repmat(xs, size(sc,1), 1), sc, 'k.');
    plot(xs, mu, '-ro', 'MarkerFaceColor', 'r');
    
    yh = mean(scsh(:,jj));
    plot(xlim, [yh yh], 'b-');
    
    ylabel(nms{jj});
    yl = ylim;
    ylim([0 yl(2)]);
end
xlabel('fraction of points used in train and test');
plot.setPrintSize(gcf, struct('width', 3.5, 'height', 7));

%% error floors by monkey

mnks = io.getMonkeys;
for ii = 1:numel(mnks)
    ix = io.getMonkeyDateFilter({S.datestr}, mnks(ii));
    
    mnks{ii}
    
    pts = scs(ix,:,:,:);
    std = nanstd(squeeze(nanmean(pts,3)));
    mu = nanmean(squeeze(nanmean(pts,3)));
    [mu - std./sqrt(ii); mu; mu + std./sqrt(ii)]
    
    pts = scsh(ix,:,:,:);
    std = nanstd(squeeze(nanmean(pts,3)));
    mu = nanmean(squeeze(nanmean(pts,3)));
    [mu - std./sqrt(ii); mu; mu + std./sqrt(ii)]
    
    '-----'
end
