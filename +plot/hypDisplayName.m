function nm = hypDisplayName(nm, doAbbrev)
    if ~doAbbrev
        if strcmpi(nm, 'minimum')
            nm = 'minimal firing';
        elseif strcmpi(nm, 'baseline')
            nm = 'baseline firing';
        elseif strcmpi(nm, 'best-mean')
            nm = 'best-mean firing';
        end
        nm(1) = upper(nm(1));
    else
        if strcmpi(nm, 'minimum')
            nm = 'MF';
        elseif strcmpi(nm, 'baseline')
            nm = 'BF';
        elseif strcmpi(nm, 'uncontrolled-uniform')
            nm = 'UU';
        elseif strcmpi(nm, 'uncontrolled-empirical')
            nm = 'UE';
        elseif strcmpi(nm, 'habitual-corrected')
            nm = 'HC';
        elseif strcmpi(nm, 'constant-cloud')
            nm = 'CC';
        end
    end
end
