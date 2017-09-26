
saveDir = 'data/plots/dynamics/one_panel';

dts = io.getDates;
Cangs = cell(numel(dts),1);
for mm = 1:numel(dts)
    dtstr = dts{mm}
    try
        [G,F,D] = lstmat.loadCleanSession(dts{mm}, true, true);
%         lstmat.freezePeriodError;
%         Cangs{mm} = cangs;        
%         save(fullfile('data', 'dynamics', [D.datestr '.mat']), ...
%             'angs', 'behs', 'behNm', 'trRngs', 'dtstr');
        
        lstmat.plotProgressSession;
        Cangs{mm} = avgPrg;
        
%         lstmat.plotActualProgressDyns;
%         Cangs{mm} = vs;
        
        close all;
    catch
        warning(['Error for ' dts{mm}]);
    end
end
