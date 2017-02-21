function plotSSSEllipseFig(CA, CB, opts)
    if nargin < 3
        opts = struct();
    end
    defopts = struct('width', 8, 'height', 6, 'margin', 0.125, ...
        'FontSize', 16, 'FontName', 'Helvetica', ...
        'TinyFontSize', 10, ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'SSS_ellipses', 'ext', 'pdf', ...
        'grps', tools.thetaCenters, 'dts', [], ...
        'clrs', [], 'sigMult', 2, 'dstep', 5.5);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init(opts.FontSize, opts.FontName);
    
    if ~isempty(opts.dts)
        mnks = io.getMonkeys();
        inds = nan(numel(mnks),1);
        dts = arrayfun(@num2str, opts.dts, 'uni', 0);
        for ii = 1:numel(mnks)
            % get first date for each monkey
            inds(ii) = find(io.getMonkeyDateFilter(dts, mnks(ii)), ...
                1, 'first');
        end
    else
        inds = [];
    end
    
    [nexps, ngrps] = size(CA);
    minx = inf; miny = inf; maxy = -inf;
    for ii = 1:nexps
        for jj = 1:ngrps
    %         [bpA, ~, ~] = plot.gauss2dcirc([], sigMult, C1s{ii,jj});
            [bpA, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CA{ii,jj});
            [bpB, ~, ~] = plot.gauss2dcirc([], opts.sigMult, CB{ii,jj});
            bpA(1,:) = bpA(1,:) + (ii-1)*opts.dstep;
            bpB(1,:) = bpB(1,:) + (ii-1)*opts.dstep;
            bpA(2,:) = bpA(2,:) - (jj-1)*opts.dstep;
            bpB(2,:) = bpB(2,:) - (jj-1)*opts.dstep;
            minx = min([bpA(1,:) bpB(1,:) minx]);
            miny = min([bpA(2,:) bpB(2,:) miny]);
            maxy = max([bpA(2,:) bpB(2,:) maxy]);

            plot(bpA(1,:), bpA(2,:), '-', 'Color', opts.clrs(1,:));
            plot(bpB(1,:), bpB(2,:), '-', 'Color', opts.clrs(2,:));
            
            if ii == 1 && ~isempty(opts.grps)
                % label cursor directions
                xc = min([bpA(1,:) bpB(1,:)]) - 1.3*opts.dstep;
                if numel(num2str(opts.grps(jj))) > 2
                    yc = min([bpA(2,:) bpB(2,:)]);
                elseif numel(num2str(opts.grps(jj))) > 1 
                    yc = mean([min([bpA(2,:) bpB(2,:)]), mean([bpA(2,:) bpB(2,:)])]);
                else
                    yc = mean([bpA(2,:) bpB(2,:)]);
                end
                cstr = [num2str(opts.grps(jj)) '^\circ'];
                text(xc, yc, cstr, 'FontSize', opts.TinyFontSize, 'Rotation', 45);
            end
        end
        if any(inds == ii)
            mnkNm = mnks{inds == ii};
            mnkNm = ['Monkey ' mnkNm(1) ' '];
            xc = min([bpA(1,:) bpB(1,:)]);
            yc = min([bpA(2,:) bpB(2,:)]) - 0.7*opts.dstep;
            text(xc, yc, mnkNm, 'FontSize', opts.TinyFontSize);
            yl = ylim;
            plot([xc xc] - 0.2*opts.dstep, [yl(1) maxy], 'k-');
        end
    end

    xt = minx - 2.2*opts.dstep; yt = miny; pad = 2;
    text(xt, yt + opts.dstep + pad, 'Output-potent angle', 'Rotation', 90, ...
        'FontSize', opts.FontSize);
    text(xt + (numel(dts)/2)*opts.dstep, yt - opts.dstep, 'Sessions', ...
        'FontSize', opts.FontSize);

    box off; axis off;
    plot.setPrintSize(fig, opts);
    if opts.doSave
        export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
end