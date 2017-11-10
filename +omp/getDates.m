function dts = getDates()
    drs = dir('data/omp/');
    dts = {drs([drs.isdir]).name};
    dts = dts(3:(end-1)); % ignore '.', '..', and 'multiDayIntuitive'
end
