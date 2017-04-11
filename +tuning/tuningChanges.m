
% [Ss,Fs] = plot.getScoresAndFits('Int2Pert_nIme');

pds = cell(numel(Fs),2);
grps = tools.thetaCenters;
for ii = 1:numel(Fs)
    F = Fs(ii);
    
    Y0 = F.test.latents;
    gsa0 = F.test.thetas;
    Y1 = F.train.latents;
    gsa1 = F.train.thetas;    
%     Y1 = F.fits(strcmp({F.fits.name}, 'constant-cloud')).latents;
%     gsa1 = gsa0;
    
    Y0 = bsxfun(@minus, Y0, mean(Y0));
    Y1 = bsxfun(@minus, Y1, mean(Y1));
    NB = F.test.NB;
    RB = F.test.RB;
%     NB = tuning.rotateBasesWithSvd(NB, Y0);
%     B = [RB NB];
    B = eye(size(NB,1));
    B = tuning.rotateBasesWithSvd(B, Y0);
    
    gs0 = tools.thetaGroup(gsa0, grps);
    [mus0, ths0] = tuning.getTuning(Y0*B, gs0, grps);
    gs1 = tools.thetaGroup(gsa1, grps);
    [mus1, ths1] = tuning.getTuning(Y1*B, gs1, grps);
    
    pds{ii,1} = ths0(:,2);
    pds{ii,2} = ths1(:,2);

end

pds0 = cell2mat(pds(:,1)');
pds1 = cell2mat(pds(:,2)');

%%

dims = 1:4;
plot.init;
plot(pds0(dims,:)', pds1(dims,:)', '.');
axis equal;
set(gca, 'XTick', grps);
set(gca, 'XTickLabel', arrayfun(@num2str, grps, 'uni', 0));
set(gca, 'XTickLabelRotation', 45);
set(gca, 'YTick', grps);
set(gca, 'YTickLabel', arrayfun(@num2str, grps, 'uni', 0));
set(gca, 'YTickLabelRotation', 45);
xlim([0 360]); ylim(xlim);
plot(xlim, ylim, 'k--');
