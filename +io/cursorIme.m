function [pos_ime, vel_ime, vel_ime2] = cursorIme(B, ime, doLatents)
% cursor movement using ime decoder

    dt = 0.045;
    [U, Y, Xtarget, ~] = imefit.prep(B, doLatents, false, true);
    [E_P, V_P] = velime_extract_prior_whiskers(U, Y, Xtarget, ime);
    % n.b. E_P{t} always has at least T_START cols, but Y{t} may have fewer
    pos_ime = arrayfun(@(t) E_P{t}(end-1:end,1:size(Y{t},2)), ...
        1:numel(E_P), 'uni', 0); % n.b. rows 1:2 are cursor pos TAU timesteps ago
    pos_ime = cell2mat(pos_ime)';
    vel_ime = arrayfun(@(t) V_P{t}(end-1:end,1:size(Y{t},2)), ...
        1:numel(V_P), 'uni', 0);
    vel_ime = cell2mat(vel_ime)';
         
    % expand pos_ime to have nans at start of trial
    ix = B.time >= 6;
    assert(isequal(cell2mat(Y)', B.pos(ix,:)));
    pos2 = nan(size(B.pos));
    pos2(ix,:) = pos_ime;
    pos_ime = pos2;
    
    vel2 = nan(size(B.pos));
    vel2(ix,:) = vel_ime;
    vel_ime = vel2/dt; % /dt or *dt ?? -- only affects progressIme & minFireFit

    % attempt to get velNext or velPrev equivalent
    vel_ime2 = arrayfun(@(t) V_P{t}(end-3:end-2,1:size(Y{t},2)), ...
        1:numel(V_P), 'uni', 0);
    vel_ime2 = cell2mat(vel_ime2)';
    vel2 = nan(size(B.pos));
    vel2(ix,:) = vel_ime2;
    vel_ime2 = vel2/dt;
    
end

function pos = cursorIme2(B, dec)
    nt = numel(B.time);
    pos = nan(nt,2);
    dt = 0.045;
    for t = 2:nt
        ixSameTrial = B.trial_index(t-1) == B.trial_index(t);
        ixTimePair = B.time(t-1) == B.time(t) - 1;
        if ~ixSameTrial || ~ixTimePair
            if ixSameTrial && ~ixTimePair
                error(['cursorIme must have all timesteps to calculate' ...
                    'cursor pos.']);
            end
            continue;
        end
        x1 = dec.M1*B.vel(t-1,:)' + dec.M2*B.spikes(t-1,:)' + dec.M0;
        pos(t,:) = B.pos(t-1,:) + (x1*dt)';
    end
end
