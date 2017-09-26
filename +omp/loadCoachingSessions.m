function [blks, decs, ks, d] = loadCoachingSessions(dtstr)

    %% load files
    basedir = fullfile('data', 'omp', dtstr);
    fnm = fullfile(basedir, 'coaching.mat');
    tnm = fullfile(basedir, 'tags.mat');
    knmI = fullfile(basedir, ['kalmanInitParamsFA' dtstr '_6.mat']);
    knmP = fullfile(basedir, ['kalmanInitParamsFA' dtstr '_12.mat']);
    d = load(fnm);
    tags = load(tnm); tags = tags.days;
    kI = load(knmI);
    kP = load(knmP);
    ks(1) = kI;
    ks(2) = kP;

    %% activity during intuitive mappings
    
    blks = [];
    for ii = 1:numel(tags)        
        dayInd = tags(ii).dayInd;
        trialTags = tags(ii).trialTags;
        blk = omp.getSpikes(d.coaching{dayInd}.simpleData, trialTags);
        blk.name = tags(ii).name;
        blk.dayInd = dayInd;
        blk.trialTags = trialTags;
        if strcmp(blk.name, 'OMP')
            blk.name = [blk.name '-d' num2str(blk.dayInd)];
        end        
        blks = [blks blk];
    end

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
    
    decs(1) = decI;
    decs(2) = decP;
end
