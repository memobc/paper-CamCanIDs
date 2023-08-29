function CompileNumberConnectionsAnalysis()
% Compile Number of Connections Analysis Results

% age+fd
two    = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-age+fd.mat');
twoTbl = toTbl(two, 'age+fd');

% none
none    = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-none.mat');
noneTbl = toTbl(none, 'none');

% acer
acer = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-acer.mat');
acerTbl = toTbl(acer, 'acer');

% fd
fd    = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-fd.mat');
fdTbl = toTbl(fd, 'fd');

% age
age    = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-age.mat');
ageTbl = toTbl(age, 'age');

% all
all    = load('analysis-cbpm_outcome-memoryability_connections-all_connectome-default_thresh-0.010_partialCor-age+fd+acer.mat');
allTbl = toTbl(all, 'age+fd+acer');

T = vertcat(twoTbl, acerTbl, noneTbl, fdTbl, ageTbl, allTbl);

writetable(T, 'numconnections.csv')

function T = toTbl(result_struct, name)
    result_struct.numneg = result_struct.numneg';
    result_struct.numpos = result_struct.numpos';
    T = struct2table(result_struct);
    T.partialCor = repmat({name}, height(T), 1);
    T.leaveout = (1:height(T))';
end

end