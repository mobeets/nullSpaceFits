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
    
    % minimum (L2 norm)
    clear hyp;
    hyp.name = 'minimum';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 2, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];
    
    % minimum (L1 norm)
    clear hyp;
    hyp.name = 'minimum-L1';
    hyp.opts = struct('minType', 'minimum', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 1, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];

    % baseline (L2 norm)
    clear hyp;
    hyp.name = 'baseline';
    hyp.opts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 2, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];
    
    % baseline (L1 norm)
    clear hyp;
    hyp.name = 'baseline-L1';
    hyp.opts = struct('minType', 'baseline', ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 1, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];
    
    % best-mean (L2 norm)
    clear hyp;
    hyp.name = 'best-mean';
    hyp.opts = struct('minType', 'best', ...
        'grpName', grpName, ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 2, ...
        'fitInLatent', fitInLatent, 'sigmaScale', 1.0, ...
        'obeyBounds', obeyBounds, 'addSpikeNoise', addNoise);
    hyp.fitFcn = @hypfit.minEnergyFit;
    hyps = [hyps hyp];
    
    % best-mean (L1 norm)
    clear hyp;
    hyp.name = 'best-mean-L1';
    hyp.opts = struct('minType', 'best', ...
        'grpName', grpName, ...
        'nanIfOutOfBounds', nanIfOutOfBounds, 'pNorm', 1, ...
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
    
%     % best-mean
%     clear hyp;
%     hyp.name = 'best-mean';
%     hyp.opts = struct('grpName', grpName, ...
%         'addNoise', addNoise, ...
%         'obeyBounds', obeyBounds, 'nanIfOutOfBounds', nanIfOutOfBounds);
%     hyp.fitFcn = @hypfit.bestMeanFit;
%     hyps = [hyps hyp];

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
    
%     % constant-cloud, slow speeds
%     clear hyp;
%     hyp.name = 'constant-cloud-slow';
%     hyp.opts = struct('kNN', nan, 'filterSpeed', true);
%     hyp.fitFcn = @hypfit.closestRowValFit;
%     hyps = [hyps hyp];
%     
%     % constant-cloud, fast speeds
%     clear hyp;
%     hyp.name = 'constant-cloud-fast';
%     hyp.opts = struct('kNN', nan, 'filterSpeed', false);
%     hyp.fitFcn = @hypfit.closestRowValFit;
%     hyps = [hyps hyp];

%     % constant-cloud-vel-slow
%     clear hyp;
%     hyp.name = 'constant-cloud-vel-slow';
%     hyp.opts = struct('kNN', nan, 'velFilter', 10', 'velLessThan', true);
%     hyp.fitFcn = @hypfit.closestRowValFit;
%     hyps = [hyps hyp];
    
%     % constant-cloud-swap
%     clear hyp;
%     hyp.name = 'constant-cloud-swap';
%     hyp.opts = struct('kNN', nan, 'swap', true);
%     hyp.fitFcn = @hypfit.closestRowValFit;
%     hyps = [hyps hyp];
    
    % filter out unwanted hyps
    if ~isempty(hnms)
        hix = ismember({hyps.name}, hnms);
        hyps = hyps(hix);
    end
end
