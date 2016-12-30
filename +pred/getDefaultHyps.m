function hyps = getDefaultHyps()
    hyps = [];
    
    % minimum
    clear hyp;
    hyp.name = 'minimum';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', true);
    hyp.fitFcn = @hyps.minEnergyFit;
    hyps = [hyps hyp];

    % baseline
    clear hyp;
    hyp.name = 'baseline';
    hyp.opts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', false, 'fitInLatent', false, ...
        'obeyBounds', true, 'boundsType', 'spikes', ...
        'addSpikeNoise', true);
    hyp.fitFcn = @hyps.minEnergyFit;
    hyps = [hyps hyp];

    % minimum-sample
    clear hyp;
    hyp.name = 'minimum-sample';
    hyp.opts = struct('minType', 'minimum', ...
        'fitInLatent', false, 'kNN', nan, 'addSpikeNoise', true);
    hyp.fitFcn = @hyps.minEnergySampleFit;
    hyps = [hyps hyp];

    % baseline-sample
    clear hyp;
    hyp.name = 'baseline-sample';
    hyp.opts = struct('minType', 'baseline', ...
        'fitInLatent', false, 'kNN', nan, 'addSpikeNoise', true);
    hyp.fitFcn = @hyps.minEnergySampleFit;
    hyps = [hyps hyp];

    % uncontrolled-uniform
    clear hyp;
    hyp.name = 'uncontrolled-uniform';
    hyp.opts = struct('obeyBounds', true, 'boundsType', 'spikes');
    hyp.fitFcn = @hyps.minEnergyFit;
    hyps = [hyps hyp];

    % uncontrolled-empirical
    clear hyp;
    hyp.name = 'uncontrolled-empirical';
    hyp.opts = struct('obeyBounds', true, 'boundsType', 'spikes');
    hyp.fitFcn = @hyps.randNulValFit;
    hyps = [hyps hyp];

    % habitual-corrected
    clear hyp;
    hyp.name = 'habitual-corrected';
    hyp.opts = struct('thetaTol', 20, 'obeyBounds', true, ...
            'boundsType', 'marginal');
    hyp.fitFcn = @hyps.randNulValInGrpFit;
    hyps = [hyps hyp];

    % constant-cloud
    clear hyp;
    hyp.name = 'constant-cloud';
    hyp.opts = struct('kNN', nan);
    hyp.fitFcn = @hyps.closestRowValFit;
    hyps = [hyps hyp];

end
