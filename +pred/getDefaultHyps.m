function hyps = getDefaultHyps(hnms)
    if nargin < 1
        hnms = {};
    end
    hyps = [];
    
    % minimum
    clear hyp;
    hyp.name = 'minimum';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', true);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % baseline
    clear hyp;
    hyp.name = 'baseline';
    hyp.opts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', true);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % minimum-sample
    clear hyp;
    hyp.name = 'minimum-sample';
    hyp.opts = struct('minType', 'minimum', ...
        'fitInLatent', false, 'kNN', nan, 'addSpikeNoise', true);
    hyp.fitFcn = @hypfit.minEnergySampleFit;
    hyps = [hyps hyp];

    % baseline-sample
    clear hyp;
    hyp.name = 'baseline-sample';
    hyp.opts = struct('minType', 'baseline', ...
        'fitInLatent', false, 'kNN', nan, 'addSpikeNoise', true);
    hyp.fitFcn = @hypfit.minEnergySampleFit;
    hyps = [hyps hyp];

    % uncontrolled-uniform
    clear hyp;
    hyp.name = 'uncontrolled-uniform';
    hyp.opts = struct('obeyBounds', true, 'boundsType', 'spikes');
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % uncontrolled-empirical
    clear hyp;
    hyp.name = 'uncontrolled-empirical';
    hyp.opts = struct('obeyBounds', true, 'boundsType', 'spikes');
    hyp.fitFcn = @hypfit.randNulValFit;
    hyps = [hyps hyp];

    % habitual-corrected
    clear hyp;
    hyp.name = 'habitual-corrected';
    hyp.opts = struct('thetaTol', 20, 'obeyBounds', true, ...
            'boundsType', 'spikes');
    hyp.fitFcn = @hypfit.randNulValInGrpFit;
    hyps = [hyps hyp];

    % constant-cloud
    clear hyp;
    hyp.name = 'constant-cloud';
    hyp.opts = struct('kNN', nan);
    hyp.fitFcn = @hypfit.closestRowValFit;
    hyps = [hyps hyp];
    
    % filter out unwanted hyps
    if ~isempty(hnms)
        hix = ismember({hyps.name}, hnms);
        hyps = hyps(hix);
    end
end
