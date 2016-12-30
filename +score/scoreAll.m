function S = scoreAll(F, gs, grpName)
% F is a fits object
% gs is a vector of groups for binning latents before scoring
%
% S is a score object:
%     S
%       grpName: 'thetaGrps'
%       gs: [5148x1 double]
%       grps: [8x1 double]
%       scores(:):
%         name: 'cloud'
%         meanError: 0.54
%         covError: 112.0
%         histError: 0.58
    
    % save info
    S.datestr = F.datestr;
    S.timestamp = datestr(datetime);
    S.grpName = grpName;
    S.gs = gs;
    S.grps = unique(gs);
    
    % gather output-null activity
    YN0 = F.test.latents*F.test.NB;
    YNcs = cell(numel(F.fits),1);
    for ii = 1:numel(F.fits)
        YNcs{ii} = F.fits(ii).latents*F.test.NB;
    end
    
    % compute mean, cov, and hist errors per hypothesis
    histErrs = score.histErrorsFcn(YNcs, YN0, gs);
    for ii = 1:numel(F.fits)
        S.scores(ii).name = F.fits(ii).name;        
        S.scores(ii).meanError = score.meanErrorFcn(YNcs{ii}, YN0, gs);
        S.scores(ii).covError = score.covErrorFcn(YNcs{ii}, YN0, gs);
        S.scores(ii).histError = histErrs(ii);
    end

end
