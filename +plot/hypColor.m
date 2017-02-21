function clr = hypColor(hypnm)
    if strcmpi(hypnm, 'minimum')
%         clr = [0.3078 0.6922 0.5608];
%         clr = [0.2078 0.5922 0.5608];
%         clr = [53, 151, 143]/255;
%         clr = [224, 53, 76]/255;
%         clr = [241, 79, 101]/255;
        clr = [197, 27, 125]/255;
        clr = [197, 27, 25]/255;
        clr = 0.8*[197, 27, 25]/255;
    elseif strcmpi(hypnm, 'baseline')
%         clr = [0.2078    0.6922    0.6608];
%         clr = [0.7725 0.1059 0.4902];
%         clr = [53, 151, 189]/255;
%         clr = [197, 27, 125]/255;
        clr = [241, 79, 101]/255;
        clr = [197, 87, 125]/255;
        clr = [245, 110, 110]/255;
        clr = [197, 27, 25]/255;
    elseif strcmpi(hypnm, 'minimum-sample')
        clr = [0.2078 0.5922 0.5608];
    elseif strcmpi(hypnm, 'baseline-sample')
%         clr = [0.0078 0.3922 0.3608];
        clr = [0.7725 0.1059 0.4902];
    elseif strcmpi(hypnm, 'best-mean')
%         clr = [0.1078    0.4922    0.4608];
%         clr = [0.2078    0.3922    0.3608];
        clr = [1 0.4 0.4];
    elseif strcmpi(hypnm, 'uncontrolled-uniform')
%         clr = [0.6940    0.3840    0.7560];
%         clr = [0.4940    0.1840    0.5560];
%         clr = [119, 45, 134]/255;
%         clr = [169, 70, 189]/255;`
        clr = [135, 70, 189]/255;
        clr = 0.8*[169, 70, 189]/255;
    elseif strcmpi(hypnm, 'uncontrolled-empirical')
%         clr = [0.4940    0.1840    0.5560];
%         clr = [230, 105, 255]/255;
%         clr = [169, 70, 189]/255;
        clr = [169, 70, 189]/255;
    elseif strcmpi(hypnm, 'habitual-corrected')
%         clr = [0.7725 0.1059 0.4902];
        clr = [0.8500    0.3250    0.0980];
        clr = [0 155 189]/255;
        clr = 0.8*[0, 114, 189]/255;
%         clr = [53, 151, 143]/255;
    elseif strcmpi(hypnm, 'constant-cloud')
        clr = [0    0.4470    0.7410];
        clr = [0, 114, 189]/255;
    elseif strcmpi(hypnm, 'data')
%         clr = [0.5 0.5 0.5];
        clr = [0 0 0];
    else
        clr = [0 0 0];
    end
end