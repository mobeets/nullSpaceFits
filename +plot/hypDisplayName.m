function nm = hypDisplayName(nm, doAbbrev)
    if nargin < 2
        doAbbrev = false;
    end
    if ~doAbbrev
        if strcmpi(nm, 'minimum')
            nm = 'Minimal Firing';
        elseif strcmpi(nm, 'baseline')
            nm = 'Baseline Firing';
        elseif strcmpi(nm, 'best-mean')
            nm = 'Minimal Deviation';
        elseif strcmpi(nm, 'habitual-corrected')
            nm = 'Persistent Strategy';
        elseif strcmpi(nm, 'constant-cloud')
            nm = 'Fixed Distribution';
        elseif strcmpi(nm, 'int-data')
            nm = 'Data, first mapping';
        elseif strcmpi(nm, 'pert-data')
            nm = 'Data, second mapping';
        end
        nm(1) = upper(nm(1));
    else
        if strcmpi(nm, 'minimum')
            nm = 'MF';
        elseif strcmpi(nm, 'baseline')
            nm = 'BF';
        elseif strcmpi(nm, 'best-mean')
            nm = 'MD';
        elseif strcmpi(nm, 'uncontrolled-uniform')
            nm = 'UU';
        elseif strcmpi(nm, 'uncontrolled-empirical')
            nm = 'UE';
        elseif strcmpi(nm, 'habitual-corrected')
            nm = 'PS';
        elseif strcmpi(nm, 'constant-cloud')
            nm = 'FD';
        end
    end
end
