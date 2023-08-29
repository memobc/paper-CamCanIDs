% identifiy the null sims that do not have 100 sims and rerun the ones that
% failed

baseDir = fileparts(mfilename('fullpath'));
nullsimDir = fullfile(baseDir, 'nullsims');

A = dir(nullsimDir);

fileNames = {A.name}';
fileNames = fileNames(3:end);

T = table(fileNames);

T.analysis     = regexp(fileNames, '(?<=analysis-).*(?=_outcome)', 'match', 'once');
T.outcome      = regexp(fileNames, '(?<=outcome-).*(?=_connections)', 'match', 'once');
T.connections  = regexp(fileNames, '(?<=connections-).*(?=_connectome)', 'match', 'once');
T.connectome   = regexp(fileNames, '(?<=connectome-).*(?=_thresh)', 'match', 'once');
T.thresh       = regexp(fileNames, '(?<=thresh-).*(?=_partialCor)', 'match', 'once');
T.partialCor   = regexp(fileNames, '(?<=partialCor-).*(?=_nullsim)', 'match', 'once');
T.nullsim      = regexp(fileNames, '(?<=nullsim-)[0-9]{4}', 'match', 'once');

T.FullAnalysisStr = strcat(T.analysis, '_', T.outcome, '_', T.connections, '_', T.connectome, '_', T.thresh, '_', T.partialCor);
T.FullAnalysisStr = categorical(T.FullAnalysisStr);

cats        = categories(T.FullAnalysisStr);
counts      = countcats(T.FullAnalysisStr);
iterMissing = cell(length(cats), 1);

for c = 1:length(cats)
    if counts(c) ~= 100
        % which iterations are missing?
        nullsims = T.nullsim(eq(T.FullAnalysisStr, cats{c}));
        nullsims = cellfun(@str2double, nullsims)';
        iterMissing{c} = setdiff(1:100, nullsims);
    end
end

Ttwo = table(cats, counts, iterMissing)