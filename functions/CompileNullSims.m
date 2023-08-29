% CompileNullSims into a tidy dataframe for plotting in R

rootDir     = fileparts(mfilename('fullpath'));
nullSimsDir = fullfile(rootDir, 'nullsims');

files = dir([nullSimsDir filesep '*.mat']);

fileN  = {files.name}';
fileD  = {files.folder}';
fileFF = strcat(fileD, filesep, fileN);

analysis    = regexp(fileN, '(?<=analysis-)[a-z]*(?=_outcome)', 'match', 'once');
outcome     = regexp(fileN, '(?<=outcome-)[a-zA-Z_]*(?=_connections)', 'match', 'once');
connections = regexp(fileN, '(?<=connections-)[a-zA-Z_]*(?=_connectome)', 'match', 'once');
connectome  = regexp(fileN, '(?<=connectome-)[a-z]*(?=_thresh)', 'match', 'once');
partialCor  = regexp(fileN, '(?<=partialCor-).*(?=_nullsim)', 'match', 'once');
nullSim     = regexp(fileN, '(?<=nullsim-)[0-9]{4}', 'match', 'once');
thresh      = regexp(fileN, '(?<=thresh-).*(?=_partialCor)', 'match', 'once');

R           = cellfun(@load, fileFF);
R           = struct2array(R);
R           = R';

T = table(analysis, outcome, connections, connectome, thresh, partialCor, nullSim, R);

T = T(strcmp(T.analysis, 'cbpm') & strcmp(T.connectome, 'gsr')  & strcmp(T.outcome, 'memoryability'), :);

T = sortrows(T, {'analysis', 'connectome', 'connections', 'outcome', 'thresh', 'partialCor'});

writetable(T, 'nullsims.csv');