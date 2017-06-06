
[Ss,Fs] = plot.getScoresAndFits('Int2Pert_yIme');

%% mean firing rate per channel per session

sps = nan(numel(Fs), 1);
for ii = 1:numel(Fs)
    sps(ii) = mean(nanmean(Fs(ii).test.spikes));
end
sps = (1000/45)*sps; % convert spikes/timestep to spikes/sec

%% report mean and sdev per monkey

mnks = io.getMonkeys;
S = cell(numel(mnks),1);
for ii = 1:numel(mnks)
    ix = io.getMonkeyDateFilter({Fs.datestr}, mnks(ii));
    S{ii} = sps(ix);
end

mnks
arrayfun(@(x) str2double(num2str(x, '%0.1d')), ...
    [cellfun(@mean, S) cellfun(@std, S)]')
