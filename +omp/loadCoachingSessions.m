function [blks, decs, ks, d] = loadCoachingSessions(dtstr, ...
    ignoreIncorrects, skipFreeze, isAllIntuitive)
    if nargin < 2
        ignoreIncorrects = true;
    end
    if nargin < 3
        skipFreeze = true;
    end
    if nargin < 4
        isAllIntuitive = false;
    end

    %% load files
    basedir = fullfile('data', 'omp', dtstr);
    
    if isAllIntuitive % a multi-day intuitive session
        basedir = fullfile('data', 'omp', 'multiDayIntuitive');
        fnm = fullfile(basedir, [dtstr '.mat']);
        tnm = fullfile(basedir, [dtstr '-tags.mat']);
        knmI = fullfile(basedir, ['kalmanInitParamsFA' dtstr '_6.mat']);
        strNm = 'longTerm';
    else % multi-day OMP (coaching)
        fnm = fullfile(basedir, 'coaching.mat');
        tnm = fullfile(basedir, 'tags.mat');
        knmI = fullfile(basedir, ['kalmanInitParamsFA' dtstr '_6.mat']);
        strNm = 'coaching';
    end
    
    d = load(fnm);
    tags = load(tnm); tags = tags.days;
    kI = load(knmI);
    ks(1) = kI;
    
    % load OMP decoder
    knmP = fullfile(basedir, ['kalmanInitParamsFA' dtstr '_12.mat']);
    if exist(knmP, 'file') % for multi-day intuitive sessions
        kP = load(knmP);    
        ks(2) = kP;
    else
        kP = struct();
    end

    %% activity during intuitive mappings
    
    blks = [];
    for ii = 1:numel(tags)        
        dayInd = tags(ii).dayInd;
        trialTags = tags(ii).trialTags;
        cd = d.(strNm);
        blk = omp.getSpikes(cd{dayInd}.simpleData, trialTags, ...
            nan, ignoreIncorrects, skipFreeze, true);
        blk.name = tags(ii).name;
        blk.dayInd = dayInd;
        blk.trialTags = trialTags;
        if strcmp(blk.name, 'OMP')
            blk.name = [blk.name '-d' num2str(blk.dayInd)];
        end        
        blks = [blks blk];
    end
    blks = omp.setColorsByDay(blks);

    % 20160617
    % best 40 trials for each OMP, start trial:
    % 220 (day 1)
    % 47 (day 6)
    % 199 (day 7)
    % 348 (day 8)

    %% decoder(s)

    decI.M0 = kI.kalmanInitParams.M0;
    decI.M1 = kI.kalmanInitParams.M1;
    decI.M2 = kI.kalmanInitParams.M2;
    decI.RB = orth(kI.kalmanInitParams.M2');
    decI.NB = null(kI.kalmanInitParams.M2);
    decI.vfcn = @(y) bsxfun(@plus, decI.M2*y, decI.M0);
    decs(1) = decI;
    
    if isfield(kP, 'kalmanInitParams')
        decP.M0 = kP.kalmanInitParams.M0;
        decP.M1 = kP.kalmanInitParams.M1;
        decP.M2 = kP.kalmanInitParams.M2;
        decP.RB = orth(kP.kalmanInitParams.M2');
        decP.NB = null(kP.kalmanInitParams.M2);
        decP.vfcn = @(y) bsxfun(@plus, decP.M2*y, decP.M0);
        decs(2) = decP;
    end
    
end
