function pValue = calculate_pvalue(analysis)
% Function for calculating the pvalue of a cbpm analysis.
%
% analysis = string, corresponding to the cbpm analysis name

% concatenate the null simulations into a vector
Rsims    = concatenate_nullsims(analysis);

% load the cbpm analysis results, saves as a table variable
fileName   = sprintf('intermediate/cbpm_results_memoryability_%s.csv', analysis);
PredictTbl = readtable(fileName);

% if this is the fluidintellgence analysis, remove subjects
% who do not have fluidintellgence scores from the table first
if strcmp(analysis, 'fluidintelligence')
    F          = ~isnan(PredictTbl.all_behav);
    PredictTbl = PredictTbl(F,:);
end

% correlate observed and predicted behavior
Robs   = corr(PredictTbl.all_behav, PredictTbl.behav_pred);

% find out where in a sorted vector the observed R falls
Rsorted  = sort([Rsims Robs], 'descend');
position = find(Rsorted==Robs);
pValue   = position/length(Rsorted);

end