
D = clouds.loadData('20160722', struct('unfiltered', false));

%%

dts = io.getDates;

corrs = cell(numel(dts), 2);
mues = nan(numel(dts), 2, 8);
vres = mues;
muzs = nan(numel(dts), 2, 8, 10);
vrzs = muzs;
mults = nan(numel(dts),1);
for ii = 1:numel(dts)
    dts{ii}
    D = io.quickLoadByDate(dts{ii});
    for bind = 1:2
        B = D.blocks(bind);
        ths = B.thetaGrps;
        
        trgs = round(B.targetAngle);
        trs = B.trial_index;
        atrgs = grpstats(trgs, trs, {'mode'});
        atms = grpstats(B.time, trs, {'numel'});
        vre = grpstats(atms, atrgs)*45/1000;
        
        errs = B.angError;
        mue = grpstats(abs(errs), ths, {'nanmean'});
%         vre = grpstats(errs, ths, {'nanvar'});
        
        [~, dat] = pca(D.blocks(bind).latents);
        [muz, vrz] = grpstats(dat, ths, {'nanmean', 'nanvar'});
        
        muz1 = grpstats(dat, trs);
        vrz = grpstats(muz1, atrgs);
        
        if abs(min(B.latents(:,1))) > max(B.latents(:,1))
            mult = -1;
        else
            mult = 1;
        end
        muz(:,1) = mult*muz(:,1);
        vrz(:,1) = mult*vrz(:,1); 
        
        corrs{ii,bind} = corr([mue vre muz vrz]);
        mues(ii,bind,:) = mue;
        vres(ii,bind,:) = vre;
        muzs(ii,bind,:,:) = muz;
        vrzs(ii,bind,:,:) = vrz;
        
        [bind mult corr(mue, muz(:,1)) corr(vre, vrz(:,1))]

%         plot.init;
%         imagesc(corr([mue vre muz vrz]));
%         caxis([-1 1]);
%         colormap(cbrewer('div', 'RdBu', 11));
%         colorbar;
%         set(gca, 'YDir', 'reverse');
% 
%         plot.init;
%         plot(muz(:,1), mue, 'o');
    end
end

%%

pcind = 1;

plot.init;
mnks = io.getMonkeys;
c = 0;
for ii = 1:2
    for jj = 1:numel(mnks)
        c = c+1;
        dtsc = dts(io.getMonkeyDateFilter(dts, mnks(jj)));
        subplot(2,3,c); hold on;
        for kk = 1:numel(dtsc)
            dtind = strcmp(dts, dtsc{kk});
            muz = squeeze(muzs(dtind,ii,:,pcind));
%             mue = squeeze(mues(dtind,ii,:));
            mue = squeeze(vres(dtind,ii,:));
            [~,ix] = sort(muz);
            xs = zscore(muz(ix));
            ys = zscore(mue(ix));
            d = dataset(xs, ys);
            mdl = fitlm(d, 'ys ~ 1 + xs + xs^2');
            plot(xs, mdl.predict(xs), 'k-');
            xlabel(['mean PC_' num2str(pcind) ', normalized']);
            ylabel('mean acq. time, normalized');
            ylabel('mean acq. time, normalized');
        end
    end
end

