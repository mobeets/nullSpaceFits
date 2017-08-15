function plotWhiskers(D, bind, trialNo, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('doLatents', true, 'doSave', false, ...
        'width', 5, 'height', 3, ...
        'saveDir', 'data/plots', 'ext', 'pdf', 'filename', 'imeWhiskers');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
    if isfield(D, 'simpleData') && opts.doLatents
        if isfield(D.simpleData.nullDecoder.FactorAnalysisParams, 'Lrot')
            error('D must be loaded without rotated latents.');
        end
    end
    % 20131205: 39 52 69 90

    TAU = 3;
    T_START = TAU + 2;
    TARGET_RADIUS = 20;% + 18;

    [U, Y, Xtarget] = imefit.prep(D.blocks(bind), opts.doLatents);
    [E_P, E_V] = velime_extract_prior_whiskers(U, Y, Xtarget, D.ime(bind));
    
    [~, ~, ~, by_trial] = imefit.imeErrs(U, Y, Xtarget, ...
        D.ime(bind), TARGET_RADIUS, T_START);
    [by_trial.cErrs{trialNo}; by_trial.mdlErrs{trialNo}]
    
    plot.init;
    center = Xtarget{trialNo};
    center = reshape(center,1,2);
    r = linspace(0,2*pi,3000);
    unit_circle = [cos(r)' sin(r)'];
    target_pts = bsxfun(@plus, TARGET_RADIUS*unit_circle, center);
    plot(target_pts(:,1), target_pts(:,2), 'Color', [0.2 0.8 0.2]);

%     fill_circle(Xtarget{trialNo}, TARGET_RADIUS, [0.2 0.8 0.2]);
%     text(Xtarget{trialNo}(1) - TARGET_RADIUS/2, ...
%         Xtarget{trialNo}(2), 'target', 'FontSize', 24);
    plot(Y{trialNo}(1,1:end-1), Y{trialNo}(2,1:end-1), 'k-o', ...
        'MarkerSize', 7, ...
        'MarkerFaceColor', 'k', 'LineWidth', 2);
    T = size(Y{trialNo}, 2);
    for t = T-1%T_START:T
        plot(E_P{trialNo}(1:2:end,t), E_P{trialNo}(2:2:end,t), ...
            'r-o', 'MarkerSize', 7, 'MarkerFaceColor', 'r', 'LineWidth', 2);
    end
    axis image;
    axis off;
    plot.setPrintSize(gcf, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end

end
