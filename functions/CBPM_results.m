% consolidate the cbpm results and report them in the command window

addpath('functions')

files   = dir('newresults/analysis-*.csv');
filesN  = {files.name}';
filesD  = {files.folder}';
filesFF = cellfun(@(x,y) fullfile(x,y), filesD, filesN, 'UniformOutput', false);

results = cellfun(@calculate_results, filesFF);

analysis    = cell(length(results), 1);
outcome     = cell(length(results), 1);
connections = cell(length(results), 1);
connectome  = cell(length(results), 1);
partialCor  = cell(length(results), 1);
p           = cell(length(results), 1);
thresh      = cell(length(results), 1);
nsims       = cell(length(results), 1);

for r = 1:length(results)

    analysis{r}    = regexp(filesN{r}, '(?<=analysis-)[a-z]*(?=_outcome)', 'match', 'once');
    outcome{r}     = regexp(filesN{r}, '(?<=outcome-)[a-zA-Z_]*(?=_connections)', 'match', 'once');
    connections{r} = regexp(filesN{r}, '(?<=connections-)[a-zA-Z_]*(?=_connectome)', 'match', 'once');
    connectome{r}  = regexp(filesN{r}, '(?<=connectome-)[a-z]*(?=_thresh)', 'match', 'once');
    partialCor{r}  = regexp(filesN{r}, '(?<=partialCor-).*(?=\.csv)', 'match', 'once');
    thresh{r}      = regexp(filesN{r}, '(?<=thresh-).*(?=_partialCor)', 'match', 'once');

    try
        [R, p{r}, nsims{r}] = D_cbpm_significance(outcome{r}, connections{r}, connectome{r}, str2double(thresh{r}), partialCor{r});
    catch
        p{r} = NaN;
        nsims{r} = NaN;
    end

end

T = table(analysis, connectome, connections, outcome, thresh, partialCor, results, p, nsims);

% Only the useful ones

T = T(strcmp(T.analysis, 'cbpm') & strcmp(T.partialCor, 'age+sex+fd'), :);

T = sortrows(T, {'analysis', 'connectome', 'connections', 'outcome', 'thresh', 'partialCor'});

writetable(T,'cbpm_results.csv')