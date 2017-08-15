
Tr = F.train;
Te = F.test;

mu = F.dec.spikeCountMean; % [1 x 88]
beta = speed.getBetaFromFA(F.dec); % [10 x 88]
M2 = Te.M2_spikes; % [2 x 88]
M0 = Te.M0_spikes; % [2 x 1]

Z1 = bsxfun(@plus, Tr.spikes*M2', M0');
Z2 = bsxfun(@plus, Te.spikes*M2', M0');

ths1 = Tr.thetaActualGrps;
ths2 = Te.thetaActualGrps;
ths1 = tools.thetaGroup(Tr.thetas, tools.thetaCenters);
ths2 = tools.thetaGroup(Te.thetas, tools.thetaCenters);

grps = tools.thetaCenters;
clrs = cbrewer('div', 'RdYlGn', numel(grps));

bnd1 = clouds.getBoundary(Z1);
bnd2 = clouds.getBoundary(Z2);

plot.init;
for ii = 1:numel(grps)
    subplot(4,2,ii); hold on;
    Zc1 = Z1(ths1 == grps(ii),:);
    Zc2 = Z2(ths2 == grps(ii),:);
    
    bnd1c = clouds.getBoundary(Zc1);
    bnd2c = clouds.getBoundary(Zc2);
    
    plot(0, 0, 'k+');
    plot(bnd1.x, bnd1.y, '--', 'Color', 0.5*ones(3,1), 'LineWidth', 1);
    plot(bnd2.x, bnd2.y, '-', 'Color', 0.5*ones(3,1), 'LineWidth', 1);
    plot(bnd1c.x, bnd1c.y, '--', 'Color', clrs(ii,:), 'LineWidth', 2);
    plot(bnd2c.x, bnd2c.y, '-', 'Color', clrs(ii,:), 'LineWidth', 2);    
end
