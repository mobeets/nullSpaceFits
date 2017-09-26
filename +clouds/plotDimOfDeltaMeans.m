function plotDimOfDeltaMeans(lts1, lts2, dEarly, dLate, ...
    pcsEarly, pcsLate, fnm, saveDir)
    if nargin < 8
        saveDir = '';
    end

    grps = tools.thetaCenters;
    clrs = cbrewer('div', 'RdYlGn', numel(grps));
    nrows = 2;
    ncols = 5;
    i2 = ncols; % index of second row
    
    plot.init;
    
    % plot in early PC subspace
    subplot(nrows, ncols, 1); hold on;
    d11 = dEarly*pcsEarly;
    d21 = dLate*pcsEarly;
    plot(d11(:,1), d11(:,2), 'o', 'MarkerSize', 5);
    plot(d21(:,1), d21(:,2), '.', 'MarkerSize', 20);
%     for ii = 1:numel(grps)
%         plot(d11(ii,1), d11(ii,2), 'o', ...
%             'MarkerSize', 5, 'Color', clrs(ii,:));
%         plot(d21(ii,1), d21(ii,2), '.', ...
%             'MarkerSize', 20, 'Color', clrs(ii,:));
%     end
    plot(0, 0, 'k+');
    xlabel('early, PC_1');
    ylabel('early, PC_2');
    
    subplot(nrows, ncols, 2); hold on;
    p1 = lts1*pcsEarly;
    p2 = p1 + d11;
    p3 = p2 + d21;
    for ii = 1:numel(grps)
        plot(p1(ii,1), p1(ii,2), '.', ...
            'MarkerSize', 5, 'Color', clrs(ii,:));
        plot([p1(ii,1) p2(ii,1)], [p1(ii,2) p2(ii,2)], ...
            '--', 'Color', clrs(ii,:));
        plot(p2(ii,1), p2(ii,2), 'o', ...
            'MarkerSize', 5, 'Color', clrs(ii,:));
        plot([p2(ii,1) p3(ii,1)], [p2(ii,2) p3(ii,2)], ...
            '-', 'Color', clrs(ii,:));
        plot(p3(ii,1), p3(ii,2), '.', 'MarkerSize', 20, ...
            'Color', clrs(ii,:));
    end
    plot(0, 0, 'k+');
    xlabel('early PC_1');
    ylabel('early PC_2');

    % plot in late PC subspace
    subplot(nrows, ncols, i2+1); hold on;
    d12 = dEarly*pcsLate;
    d22 = dLate*pcsLate;
    plot(d12(:,1), d12(:,2), 'o', 'MarkerSize', 5);
    plot(d22(:,1), d22(:,2), '.', 'MarkerSize', 20);
%     for ii = 1:numel(grps)
%         plot(d12(ii,1), d12(ii,2), 'o', ...
%             'MarkerSize', 5, 'Color', clrs(ii,:));
%         plot(d22(ii,1), d22(ii,2), '.', ...
%             'MarkerSize', 20, 'Color', clrs(ii,:));
%     end
    plot(0, 0, 'k+');
    xlabel('late PC_1');
    ylabel('late PC_2');
    
    subplot(nrows, ncols, i2+2); hold on;
    p1 = lts2{1}*pcsLate;
    p2 = p1 + d12;
    p3 = p2 + d22;
    for ii = 1:numel(grps)
        plot(p1(ii,1), p1(ii,2), '.', ...
            'MarkerSize', 5, 'Color', clrs(ii,:));
        plot([p1(ii,1) p2(ii,1)], [p1(ii,2) p2(ii,2)], ...
            '--', 'Color', clrs(ii,:));
        plot(p2(ii,1), p2(ii,2), 'o', ...
            'MarkerSize', 5, 'Color', clrs(ii,:));
        plot([p2(ii,1) p3(ii,1)], [p2(ii,2) p3(ii,2)], ...
            '-', 'Color', clrs(ii,:));
        plot(p3(ii,1), p3(ii,2), '.', 'MarkerSize', 20, ...
            'Color', clrs(ii,:));
    end
    plot(0, 0, 'k+');
    xlabel('late PC_1');
    ylabel('late PC_2');
    
    % variance explained
    v11 = sum(d11.^2);
    v21 = sum(d21.^2);
    v12 = sum(d12.^2);
    v22 = sum(d22.^2);
    vmx = max(max([v11; v21; v12; v22]));
    
    subplot(nrows, ncols, 3); hold on;
    plot(v11, '--');
    plot(v21);
    ylim([0 vmx]);
    xlabel('# dims');
    ylabel('variance explained by early PCs');
    legend({'early', 'late'});
    legend boxoff;

    subplot(nrows, ncols, i2+3); hold on;
    plot(v12, '--');
    plot(v22);
    ylim([0 vmx]);
    xlabel('# dims');
    ylabel('variance explained by late PCs');
    legend({'early', 'late'});
    legend boxoff;
    
    subplot(nrows, ncols, 4); hold on;
    plot(100*v11/sum(v11), '--');
    plot(100*v21/sum(v21));
    ylim([0 100]);
    xlabel('# dims');
    ylabel('% variance explained by early PCs');
    legend({'early', 'late'});
    legend boxoff;

    subplot(nrows, ncols, i2+4); hold on;
    plot(100*v12/sum(v12), '--');
    plot(100*v22/sum(v22));
    ylim([0 100]);
    xlabel('# dims');
    ylabel('% variance explained by late PCs');
    legend({'early', 'late'});
    legend boxoff;
    
    subplot(nrows, ncols, 5); hold on;
    plot(pcsEarly(:,1), '--');
    plot(pcsLate(:,1));
    plot(xlim, [0 0], '-', 'Color', 0.7*ones(3,1));
    xlabel('element of PC');
    ylabel('loading value');
    legend({'early PC_1', 'late PC_2'});
    legend boxoff;
    
    popts = struct('width', 12, 'height', 5, 'margin', 0.25);
    plot.setPrintSize(gcf, popts);
    if ~isempty(saveDir)
        fnm = fullfile(saveDir, [fnm '.pdf']);
        export_fig(gcf, fnm);
    end
end
