function null_sim(i, analysis)
% function for performing a single null simulation

addpath('functions')

% load data
switch analysis
    case {'memoryability', 'age'}
        load('results/PredictTbl.mat', 'PredictTbl')
    case 'fluidintelligence'
        load('results/PredictTbl.mat', 'PredictTbl')
        F = ~isnan(PredictTbl.TotalScore);
        PredictTbl = PredictTbl(F,:);
    case {'EmoMem', 'EmoMem_noAgeSex'}
        load('results/PredictTbl.mat', 'PredictTbl')
        F = ~isnan(PredictTbl.TotalDetRecall);
        PredictTbl = PredictTbl(F,:);
    case 'gsr'
        load('results/PredictTbl_gsr.mat', 'PredictTbl')
    case 'noMovie'
        load('results/PredictTbl_noMovie.mat', 'PredictTbl')
end

% all_mats = nROI x nROI x nSUB connectivity matrix
all_mats  = cat(3, PredictTbl.connectivity{:});

% all_behav = nSUB x 1 vector of behavior to predict
switch analysis
    case {'memoryability', 'gsr', 'noMovie'}
        all_behav = PredictTbl.memoryability;
    case 'age'
        all_behav = PredictTbl.Age;
    case 'fluidintelligence'
        all_behav = PredictTbl.TotalScore;
    case 'EmoMem'
        all_behav = PredictTbl.TotalDetRecall;
    case 'EmoMem_noAgeSex'
        % Regress out Age and Sex
        lmfit = fitlm(PredictTbl, 'TotalDetRecall ~ Age + Sex');
        all_behav = lmfit.Residuals.Raw;
end

% threshold for feature selection
thresh = 0.01;

% generate random shuffles
% Fix random number generator to a seed for replicability.
rng(123)
null_perm = cell(1000,1);
for k = 1:1000
   null_perm{k} = randperm(length(all_behav));
end

% randomly shuffle the behavior vector. Run the analysis
random_behav = all_behav(null_perm{i});
behav_pred   = run_cbpm(all_mats, random_behav, thresh);
R            = corr(behav_pred, random_behav);

% save the results
fileDir  = sprintf('/mmfs1/data/kurkela/Desktop/CamCan/code/nullsims_%s', analysis);
if ~exist(fileDir, 'dir')
    mkdir(fileDir)
end
fileName = sprintf('cbpm_memoryability_randperms_%04d', i);
full_file_name = fullfile(fileDir, fileName);
save(full_file_name, 'R')

end
