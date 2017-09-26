
% [G,F,D] = lstmat.loadCleanSession('20120601', true, true);
B0 = G.train;
B = G.test;
Bc = D.blocks(2);
tr0 = 56;
[trL1, trL2, bs, ts] = clouds.identifyTopLearningRange(Bc, tr0, ...
    'progress', @max, 5, inf);
% tr1 = trL1; tr2 = trL2;
% tr1 = min(ts); tr2 = tr1 + tr0;
% tr1 = 0; tr2 = inf;
trRngs = [min(ts) min(ts) + tr0; trL1 trL2];

trgs0 = round(B0.targetAngle);
trgs = round(B.targetAngle);
alltrgs = sort(unique(trgs));
ntrgs = numel(alltrgs);
clrs = cbrewer('div', 'RdYlGn', ntrgs);
tmx = 20;
ymx = 150;

ixtE = (B.trial_index >= trRngs(1,1)) & (B.trial_index <= trRngs(1,2));
% ixtE = ixtE & B.isCorrect;

ixtL = (B.trial_index >= trRngs(2,1)) & (B.trial_index <= trRngs(2,2));
% ixtL = ixtL & B.isCorrect;

%% plot behavior per target

trs = B0.trial_index;
trgs = round(B0.targetAngle);
tms = B0.time;
ix = tms > 6;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgs = grpstats(trgs(ix), trs(ix));
beh1 = grpstats(atms, trgs);

trs = B.trial_index;
trgs = round(B.targetAngle);
tms = B.time;
ix = (tms > 6) & ixtE;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgs = grpstats(trgs(ix), trs(ix));
beh2 = grpstats(atms, trgs);

trs = B.trial_index;
trgs = round(B.targetAngle);
tms = B.time;
ix = (tms > 6) & ixtL;
atms = grpstats(trs(ix), trs(ix), 'numel');
trgs = grpstats(trgs(ix), trs(ix));
beh3 = grpstats(atms, trgs);

plot.init;
plot(unique(trgs), beh1*45/1000, 'k--');
plot(unique(trgs), beh2*45/1000);
plot(unique(trgs), beh3*45/1000);
set(gca, 'XTick', tools.thetaCenters);
legend({'intuitive', 'pert-early', 'pert-late'}); legend boxoff;
xlabel('target');
ylabel('acquisition time (s)');
title(D.datestr);

%% plot ramp up per target

blockNm = 'int';
usePertDec = false;

doSave = false;

if usePertDec
    cvel = @(y) bsxfun(@plus, B.M2*y, B.M0);
    decNm = 'pertDec';
else
    cvel = @(y) bsxfun(@plus, B0.M2*y, B0.M0);
    decNm = 'intDec';
end

ts = trgs;
tms = B.time;
lts = B.latents;
if strcmp(blockNm, 'int')
    ts = trgs0;
    tms = B0.time;
    lts = B0.latents;
    ixt = true(size(tms));
elseif strcmp(blockNm, 'pert-early')
    ixt = ixtE;
elseif strcmp(blockNm, 'pert-late')
    ixt = ixtL;
else
    error('invalid blockNm');
end

fnm = [D.datestr '-' decNm '-' blockNm];

h = plot.init;
axis tight manual;
filename = fullfile('data/plots/freezePeriod', [fnm '.gif']);
plot(0, 0, 'k+');
r = 1.0*ymx;
for jj = 1:ntrgs
    plot(r*cosd(alltrgs(jj)), -r*sind(alltrgs(jj)), '.', ...
        'Color', clrs(jj,:), 'MarkerSize', 50);
end

axis square;
title(fnm);
tlbl = text(0.8*ymx, ymx, 't = 1', 'FontSize', 14);
clrlns = cbrewer('seq', 'Greys', 8);
pssLast = [];
for ct = 1:6%20
    t = ct;
%     if ct > 6
%         t = 6;
%     end
    pss = [];
    for jj = 1:ntrgs
        ix = (ts == alltrgs(jj)) & ixt & tms == t;
        yms = grpstats(lts(ix,:), tms(ix));
        ps0 = cvel(yms');
        pss = [pss ps0];
        plot(ps0(1), ps0(2), '.', 'Color', clrs(jj,:), ...
            'MarkerSize', 20);
        if ~isempty(pssLast)
            plot([ps0(1) pssLast(1,jj)], [ps0(2) pssLast(2,jj)], '-', ...
                'Color', clrs(jj,:));
        end
    end
%     plot([pss(1,:) pss(1,1)], [pss(2,:) pss(2,1)], ...
%         'Color', clrlns(t,:));
    
    tlbl.String = ['t = ' num2str(t)];
    pssLast = pss;
    
    xlim([-ymx ymx]); ylim(xlim);
    xlabel('vel_x');
    ylabel('vel_y');
        
    if doSave
        frame = getframe(h);
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im, 256);
        if t == 1 
            imwrite(imind, cm, filename,'gif', 'Loopcount', inf); 
        else 
            imwrite(imind, cm, filename,'gif', 'WriteMode', 'append'); 
        end 
    else
        pause(0.5);
    end
end

%% plot all vels during prep

plot.init;

lts = B0.latents;
tms = B0.time;
cvel = @(y) bsxfun(@plus, B.M2*y, B.M0);
vs = cvel(lts');
vs0 = cvel(lts(tms < 7,:)');

subplot(1,2,1); hold on;
plot(vs0(1,:), vs0(2,:), '.');
plot(0,0,'k+');
title('int');

lts = B.latents;
tms = B.time;
trs = B.trial_index;
ixtE = (trs >= trRngs(1,1)) & (trs <= trRngs(1,2));
ixtL = (trs >= trRngs(2,1)) & (trs <= trRngs(2,2));
cvel = @(y) bsxfun(@plus, B.M2*y, B.M0);
vs = cvel(lts');
vs0 = cvel(lts(tms < 7,:)');

subplot(1,2,2); hold on;
plot(vs0(1,:), vs0(2,:), '.');
plot(0,0,'k+');
title('pert');

%%

tmGoal = 6;
plot.init;
for jj = 1:ntrgs
    ix = (trgs == alltrgs(jj)) & ixtE & B.time == tmGoal;
    yms = grpstats(B.latents(ix,:), B.time(ix));
    psE = cvel(yms');
    
    ix = (trgs == alltrgs(jj)) & ixtL & B.time == tmGoal;
    yms = grpstats(B.latents(ix,:), B.time(ix));
    psL = cvel(yms');
    
    ix = (trgs0 == alltrgs(jj)) & B0.time == tmGoal;
    yms = grpstats(B0.latents(ix,:), B0.time(ix));
    ps0 = cvel(yms');
    
    plot(0, 0, 'k+');
    plot([ps0(1) psE(1)], [ps0(2) psE(2)], '--', 'Color', clrs(jj,:));
    plot([psE(1) psL(1)], [psE(2) psL(2)], '-', 'Color', clrs(jj,:));
    plot(psE(1), psE(2), 'wo', 'MarkerFaceColor', clrs(jj,:));
    plot(psL(1), psL(2), 'wo', 'MarkerFaceColor', clrs(jj,:));
    plot(ps0(1), ps0(2), 'o', 'Color', clrs(jj,:));
    
    if jj == 1
        xlim([-ymx ymx]); ylim(xlim);
        xlabel('vel_x');
        ylabel('vel_y');
    end
end
if usePertDec
    title([D.datestr ' through pert. decoder']);
else
    title([D.datestr ' through int. decoder']);
end
