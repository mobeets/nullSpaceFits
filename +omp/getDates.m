function dts = getDates(getOMP)
    if nargin < 1
        getOMP = true;
    end
    if ~getOMP
        dts = {'20150212', '20150308', '20160717'};
        return;
    end
    drs = dir('data/omp/');
    dts = {drs([drs.isdir]).name};
    dts = dts(3:(end-1)); % ignore '.', '..', and 'multiDayIntuitive'
end
