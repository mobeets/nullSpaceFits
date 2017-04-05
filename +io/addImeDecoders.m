function D = addImeDecoders(D)
    fnm = io.pathToIme(D.datestr);
    if ~exist(fnm, 'file')
        warning(['No IME files found for ' D.datestr]);
        return;
    end
    x = load(fnm);
    D.ime = x.ime;
    dt = 1/0.045; % 1/(sec per timestep)
    for ii = 1:numel(D.blocks)
        if ii > numel(D.ime)
            ime_ii = 1;
        else
            ime_ii = ii;
        end
        % load spike/factor decoder
        dc1 = D.ime(ime_ii);
        dc1.M0 = dc1.b0*dt;
        dc1.M1 = dc1.A;
        dc1.M2 = dc1.B*dt;
        
        % convert to the other decoder
        if size(dc1.B, 2) == 10
            ogImeIsLatent = true;
            dc2 = io.factorDecoderToSpikeDecoder(dc1, ...
                D.simpleData.nullDecoder);
        else
            ogImeIsLatent = false;
            dc2 = io.spikeDecoderToFactorDecoder(dc1, ...
                D.simpleData.nullDecoder, ...
                D.blocks(ii).spikes, D.blocks(ii).latents);
        end
        
        % make bases and add decoders to blocks
        [dc1.NulM2, dc1.RowM2] = io.getNulRowBasis(dc1.M2);
        [dc2.NulM2, dc2.RowM2] = io.getNulRowBasis(dc2.M2);
        if ogImeIsLatent
            D.blocks(ii).fImeDecoder = dc1;
            D.blocks(ii).nImeDecoder = dc2;
        else
            D.blocks(ii).nImeDecoder = dc1;
            D.blocks(ii).fImeDecoder = dc2;
        end
        
        % load various stats
        [pos_ime, vel_ime, vel_ime2] = io.cursorIme(D.blocks(ii), ...
            D.ime(ime_ii), ogImeIsLatent);
        [ths_ime, angErr_ime, thsact_ime, prog_ime] = addImeStats(...
            D.blocks(ii), pos_ime, vel_ime);
        D.blocks(ii).posIme = pos_ime;
        D.blocks(ii).velIme = vel_ime;
        D.blocks(ii).velNextIme = [vel_ime(2:end,:); [nan nan]];
        D.blocks(ii).velPrevIme = vel_ime2;
        D.blocks(ii).thetasIme = ths_ime;
        D.blocks(ii).thetaActualsIme = thsact_ime;
        D.blocks(ii).progressIme = prog_ime;
        D.blocks(ii).angErrorIme = angErr_ime;
        D.blocks(ii).thetaImeGrps = tools.thetaGroup(ths_ime, ...
            tools.thetaCenters(8));
        D.blocks(ii).thetaImeGrps16 = tools.thetaGroup(ths_ime, ...
            tools.thetaCenters(16));
        D.blocks(ii).thetaActualImeGrps = tools.thetaGroup(thsact_ime, ...
            tools.thetaCenters(8));
        D.blocks(ii).thetaActualImeGrps16 = tools.thetaGroup(thsact_ime, ...
            tools.thetaCenters(16));
    end
end

function [ths_ime, angErr_ime, thsact_ime, prog_ime] = addImeStats(...
    B, pos_ime, vel_ime)

    vec2trg = B.target - pos_ime;
%     movVec = diff(pos_ime); % or do we compare true pos to next pos_ime?
    movVec = vel_ime; % must also comment out line 57
    
    ths_ime = arrayfun(@(t) tools.computeAngle(vec2trg(t,:), [1; 0]), ...
        1:size(vec2trg,1))';
    ths_ime = mod(ths_ime, 360);
    
    angErr_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), ...
        vec2trg(t,:)), 1:size(vec2trg,1)-1);
    angErr_ime = [angErr_ime nan]'; % for last time step
    
    thsact_ime = arrayfun(@(t) tools.computeAngle(movVec(t,:), [1; 0]), ...
        1:size(movVec,1))';
%     thsact_ime = [thsact_ime; nan]; % for last time step
    thsact_ime = mod(thsact_ime, 360);
    
    prog_ime = diag(movVec*vec2trg')./sqrt(sum(vec2trg.^2,2));

    % thsact_ime needs to change at the or of the below;
    % (because time and trial changes have already been filtered out,
    % movVec's diff above is off)
    ix = diff(B.trial_index) ~= 0 | diff(B.time) ~= 1;
    thsact_ime(ix) = nan;
    angErr_ime(ix) = nan;
    prog_ime(ix) = nan;
end
