function F = fitHyps(D, hyps)
% fit all hypothesis predictions
%
% D must have fields: datestr, train, test, simpleData.nullDecoder
%
% D.train and D.test must have fields:
%     - latents
%     - spikes
%     - NB, RB, M0, M1, M2
%     - thetas (for hab)
%     - vel, velNext (for min/bas)
%
% hyps is struct array with fields:
%     - name
%     - opts
%     - fitFcn 
%

    % save only the data critical for scoring
    F.datestr = D.datestr;
    F.train.latents = D.train.latents;
    F.train.NB = D.train.NB;
    F.train.RB = D.train.RB;
    F.test.latents = D.test.latents;
    F.test.NB = D.test.NB;
    F.test.RB = D.test.RB;
    
    % fit all hyp predictions
    for ii = 1:numel(hyps)
        F.fits(ii).name = hyps.name;
        F.fits(ii).opts = hyps.opts;
        F.fits(ii).latents = hyps.fitFcn(D.train, D.test, ...
            D.simpleData.nullDecoder, hyps.opts);
    end
    
end
