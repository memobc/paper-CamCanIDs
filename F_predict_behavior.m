% predict behavior

load('results/PredictTbl_gsr.mat', 'PredictTbl')

runExtra = false;

%% How correlated are the neural variables

TidyPredictTbl = PredictTbl(:, {'memoryability', 'memorypersistence', 'Age', 'fd', 'Sex' ,'within', 'between', 'extra', 'hipp'});
SexDummy = dummyvar(categorical(TidyPredictTbl.Sex));
SexDummy = SexDummy(:,2); % males = 1, females = 0;
TidyPredictTbl.Sex = SexDummy;
CorrTbl = corr(table2array(TidyPredictTbl));
CorrTbl = array2table(CorrTbl, 'RowNames', {'memoryability', 'memorypersistence', 'Age', 'Sex', 'fd', 'within', 'between', 'extra', 'hipp'}, ...
                                       'VariableNames', {'memoryability', 'memorypersistence', 'Age', 'Sex', 'fd', 'within', 'between', 'extra', 'hipp'});
CorrTbl

%% Memory Ability

% within: DMN-C connections
fitlm(PredictTbl, 'memoryability~within')
fitlm(PredictTbl, 'memoryability~within+Age+Sex+fd')
fitlm(PredictTbl, 'memoryability~within+TotalScore+additional_acer+Age+Sex+fd')

% between: DMN-C -- DMN-A Connections
fitlm(PredictTbl, 'memoryability~between')
fitlm(PredictTbl, 'memoryability~between+Age+Sex+fd')
fitlm(PredictTbl, 'memoryability~between+TotalScore+additional_acer+Age+Sex+fd')

% extra: DMN-C -- other connections
fitlm(PredictTbl, 'memoryability~extra')
fitlm(PredictTbl, 'memoryability~extra+Age+Sex+fd')
fitlm(PredictTbl, 'memoryability~extra+TotalScore+additional_acer+Age+Sex+fd')

% hippocampal connections
fitlm(PredictTbl, 'memoryability~hipp')
fitlm(PredictTbl, 'memoryability~hipp+Age+Sex+fd')
fitlm(PredictTbl, 'memoryability~hipp+TotalScore+additional_acer+Age+Sex+fd')

if runExtra

    % all DMN-C connections
    fitlm(PredictTbl, 'memoryability~dmnc')
    fitlm(PredictTbl, 'memoryability~dmnc+Age+Sex+fd')
    fitlm(PredictTbl, 'memoryability~dmnc+TotalScore+additional_acer+Age+Sex+fd')

end

%% Emotional Memory Task

if runExtra

% Subset of subjects who completed Emotional Memory Task
PredictTblEmoMem = PredictTbl(~isnan(PredictTbl.TotalDetRecall), :);

% predictive on their own?
fitlm(PredictTblEmoMem, 'TotalDetRecall~within')
fitlm(PredictTblEmoMem, 'TotalDetRecall~between')
fitlm(PredictTblEmoMem, 'TotalDetRecall~extra')
fitlm(PredictTblEmoMem, 'TotalDetRecall~hipp')

% models from the preregistration
fitlm(PredictTblEmoMem,'TotalDetRecall~within+Age+Sex+fd')
fitlm(PredictTblEmoMem,'TotalDetRecall~between+Age+Sex+fd')
fitlm(PredictTblEmoMem,'TotalDetRecall~extra+Age+Sex+fd')
fitlm(PredictTblEmoMem, 'TotalDetRecall~hipp+Age+Sex+fd')

% models controlling for cognitive capacity
fitlm(PredictTblEmoMem,'TotalDetRecall~within+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTblEmoMem,'TotalDetRecall~between+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTblEmoMem,'TotalDetRecall~extra+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTblEmoMem, 'TotalDetRecall~hipp+TotalScore+additional_acer+Age+Sex+fd')

%% Memory Persistence

% predictive on their own?
fitlm(PredictTbl, 'memorypersistence~within')
fitlm(PredictTbl, 'memorypersistence~between')
fitlm(PredictTbl, 'memorypersistence~extra')
fitlm(PredictTbl, 'memorypersistence~hipp')

% linear models testing the original predictions
fitlm(PredictTbl, 'memorypersistence~within+Age+Sex+fd')
fitlm(PredictTbl, 'memorypersistence~between+Age+Sex+fd')
fitlm(PredictTbl, 'memorypersistence~extra+Age+Sex+fd')
fitlm(PredictTbl, 'memorypersistence~hipp+Age+Sex+fd')

% Linear Models controlling for cognitive capacity
fitlm(PredictTbl,'memorypersistence~within+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTbl,'memorypersistence~between+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTbl,'memorypersistence~extra+TotalScore+additional_acer+Age+Sex+fd')
fitlm(PredictTbl, 'memorypersistence~hipp+TotalScore+additional_acer+Age+Sex+fd')

end
