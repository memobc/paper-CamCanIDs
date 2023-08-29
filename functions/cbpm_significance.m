function [observed_r, pvalue, nsims] = D_cbpm_significance(outcome, connections, connectome, threshold, partialCor)
% takes the results of a cbpm analysis and determines
% statistical significance using the null simulations

% results from the null simulations for this analysis
DIR = './nullsims';
FN  = sprintf('analysis-cbpm_outcome-%s_connections-%s_connectome-%s_thresh-%.03f_partialCor-%s', outcome, connections, connectome, threshold, partialCor);
nullsimsFF = fullfile(DIR, FN);

a         = dir([nullsimsFF, '*.mat']);
fileNames = {a.name};
fileNames = fileNames';
fileNames = strcat(unique({a.folder}),filesep,fileNames);
Rsims     = cellfun(@load, fileNames);
Rsims     = [Rsims.R];

DIR = './newresults';
FN = sprintf('analysis-cbpm_outcome-%s_connections-%s_connectome-%s_thresh-%.03f_partialCor-%s.csv', outcome, connections, connectome, threshold, partialCor);
observed_r = calculate_results(fullfile(DIR, FN));

% determine the pvalue -- the probability of observing a value more extreme
% simply due to chance alone
ascendingNulls = sort([Rsims observed_r]);
WhereRisInVect = find(ascendingNulls == observed_r);
percentile     = WhereRisInVect / length(ascendingNulls);
if percentile > .5
    pvalue = 1-percentile;
else
    pvalue = percentile;
end

observed_r = round(observed_r, 3);
pvalue     = round(pvalue, 3);
nsims      = length(Rsims);

end