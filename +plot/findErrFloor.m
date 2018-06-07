%% load
[S,F] = plot.getScoresAndFits('Int2Pert_yIme');

%% compute scores if just splitting data in two

maxdiv = 2;
nboots = 10;
scs = nan(numel(F), maxdiv-1, nboots, 3);
scsh = nan(numel(F), maxdiv-1, nboots, 3);

% plot.init;
grps = tools.thetaCenters;
for ii = 1:numel(F)
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
            
            Ynh2 = f.train.latents;
            if size(Ynh2,1) > size(Ynh,1)
                inds = randperm(size(Ynh2,1));
                inds = inds(1:size(Ynh,1));
                Ynh2 = Ynh2(inds,:);
            end
            
            tr = f.train;
            tr.latents = Ynh2;
            te = f.test;
            te.latents = Yn;
            Ynh2 = hypfit.closestRowValFit(tr, te);
            
            Ynh2 = Ynh2*f.test.NB;
            Ynh = Ynh*f.test.NB;
            Yn = Yn*f.test.NB;
            histErrs = score.histErrorsFcn({Ynh}, Yn, gsc);
            scs(ii,div-1,kk,1) = histErrs(1);
            scs(ii,div-1,kk,2) = score.meanErrorFcn(Ynh, Yn, gsc);
            scs(ii,div-1,kk,3) = score.covErrorFcn(Ynh, Yn, gsc);
            
            [histErrs, nbins] = score.histErrorsFcn({Ynh2}, Yn, gsc);
            scsh(ii,div-1,kk,1) = histErrs(1);
            scsh(ii,div-1,kk,2) = score.meanErrorFcn(Ynh2, Yn, gsc);
            scsh(ii,div-1,kk,3) = score.covErrorFcn(Ynh2, Yn, gsc);
            
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
    pts = scsh;
    std = nanstd(squeeze(nanmean(pts,3)));
    mu = nanmean(squeeze(nanmean(pts,3)));
    [mu - std./sqrt(ii); mu; mu + std./sqrt(ii)]
end

% histErr   muErr     covErr
% ---------------------------
% 0.0783    0.3644    1.2304
% 0.0815    0.3833    1.2927
% 0.0848    0.4021    1.3550

% muErr = 8.5174 spikes/s

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

%% 

scsh2 = nan(numel(S), 3);
for ii = 1:numel(S)
    s = S(ii).scores(end);
    scsh2(ii,:) = [s.histError s.meanError s.covError];
end

mean(scsh2)

%%

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
