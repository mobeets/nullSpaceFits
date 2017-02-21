function hyps = getDefaultHyps(hnms, grpName)
    if nargin < 1
        hnms = {};
    end
    if nargin < 2
        grpName = 'thetaActualGrps';
    end
    hyps = [];
    fitInLatent = false;    
    addNoise = true;
    obeyBounds = true;
    nanIfOutOfBounds = true;
    % n.b. minimum-sample and baseline-sample ignore nanIfOutOfBounds
    
    % minimum
    clear hyp;
    hyp.name = 'minimum';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % baseline
    clear hyp;
    hyp.name = 'baseline';
    hyp.opts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

%     % minimum-sample
%     clear hyp;
%     hyp.name = 'minimum-sample';
%     hyp.opts = struct('minType', 'minimum', ...
%         'fitInLatent', fitInLatent, 'kNN', nan, ...
%         'addSpikeNoise', addNoise, ...
%         'nanIfOutOfBounds', false);
%     hyp.fitFcn = @hypfit.minEnergySampleFit;
%     hyps = [hyps hyp];
% 
%     % baseline-sample
%     clear hyp;
%     hyp.name = 'baseline-sample';
%     hyp.opts = struct('minType', 'baseline', ...
%         'fitInLatent', fitInLatent, 'kNN', nan, ...
%         'addSpikeNoise', addNoise, ...
%         'nanIfOutOfBounds', false);
%     hyp.fitFcn = @hypfit.minEnergySampleFit;
%     hyps = [hyps hyp];
    
    % best-mean
    clear hyp;
    hyp.name = 'best-mean';
    hyp.opts = struct('grpName', grpName, ...
        'addNoise', addNoise, ...
        'obeyBounds', obeyBounds, 'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.bestMeanFit;
    hyps = [hyps hyp];
    
    % best-mean-per-target
    clear hyp;
    hyp.name = 'best-mean-per-target';
    hyp.opts = struct('grpName', grpName, ...
        'addNoise', addNoise, ...
        'obeyBounds', obeyBounds, 'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.bestMeanPerTargetFit;
    hyps = [hyps hyp];

    % uncontrolled-uniform
    clear hyp;
    hyp.name = 'uncontrolled-uniform';
    hyp.opts = struct('obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.uniformSampleFit;
    hyps = [hyps hyp];

    % uncontrolled-empirical
    clear hyp;
    hyp.name = 'uncontrolled-empirical';
    hyp.opts = struct('obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
    hyp.fitFcn = @hypfit.randNulValFit;
    hyps = [hyps hyp];

    % habitual-corrected
    clear hyp;
    hyp.name = 'habitual-corrected';
    hyp.opts = struct('thetaTol', 20, 'obeyBounds', obeyBounds, ...
        'nanIfOutOfBounds', nanIfOutOfBounds);
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
