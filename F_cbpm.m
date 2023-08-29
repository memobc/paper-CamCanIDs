function D_cbpm(outcome, connections, connectome, threshold, partialCor)
% ------------ INPUTS -------------------
% outcome = string. Which behavioral/demographic variable are we attempting
%                   to predict? Options: [memoryability, age,
%                   fluidintelligence, EmoMemory, EmoMemory_AgeSexControl,
%                   memorypersistence]
% 
% connections = string. Which part of the functional connectome are we
%                       using to predict the outcome variable? Options:
%                       [HippDMN_withinrelated, HippDMN_within,
%                       HippDMN_exclude, Hipp_exclude]
% 
% connectome = string. Which method for estimating the functional
%                      connectome? Options: [default, gsr, noMovie]
% 
% threshold = double. What should be the threshold for including
%                     connections in the CBPM analysis? P value. 
%                     Example: 0.01.
% 
% partialCor = string. Which behavioral/demographic variable should we
%                      control for when selecting connections for inclusion
%                      in the analysis? Options: [none, fd, age, age+fd]

% for custom functions
addpath('functions')

% load ROI information
atlasDir = fullfile(fileparts(mfilename('fullfile')), 'atlas');
ROIdir   = fullfile(atlasDir, 'Parcellations', 'MNI', 'Centroid_coordinates');
ROIfile  = fullfile(ROIdir, 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv');
ROITbl   = load_roi_information(ROIfile);

%% Setting up analysis
% based on the input options: connectome, connections, outcome

% Prediction Table
switch connectome

    case 'default'
        % the default method for estimating the functional connectome. See
        % description in Kurkela & Ritchey in prep

        load('results/PredictTbl.mat', 'PredictTbl')
        PredictTbl.conn_sqf = cellfun(@to_squareform, PredictTbl.intrinsic_connectivity, 'UniformOutput', false);

    case 'gsr'
        % Same as the default method, with the addition of global signal
        % regression.

        load('results/PredictTbl_gsr.mat', 'PredictTbl')
        PredictTbl.conn_sqf = cellfun(@to_squareform, PredictTbl.intrinsic_connectivity, 'UniformOutput', false);

    case 'movie'

        load('results/PredictTbl_gsr.mat', 'PredictTbl')
        PredictTbl.conn_sqf = cellfun(@to_squareform, PredictTbl.movie_connectivity, 'UniformOutput', false);
        PredictTbl = PredictTbl(~cellfun(@isempty, PredictTbl.conn_sqf), :);

    case 'rest'

        load('results/PredictTbl_gsr.mat', 'PredictTbl')
        PredictTbl.conn_sqf = cellfun(@to_squareform, PredictTbl.rest_connectivity, 'UniformOutput', false);
        PredictTbl = PredictTbl(~cellfun(@isempty, PredictTbl.conn_sqf), :);

    case 'smt'

        load('results/PredictTbl_gsr.mat', 'PredictTbl')
        PredictTbl.conn_sqf = cellfun(@to_squareform, PredictTbl.smt_connectivity, 'UniformOutput', false);
        PredictTbl = PredictTbl(~cellfun(@isempty, PredictTbl.conn_sqf), :);

end

switch connections

    case 'all'

        % do not do anything
        
    otherwise
    
        % remove the network from the connectome
        network_to_exclude = erase(connections, '_exclude');
        exclude(network_to_exclude);

end

switch outcome

    case 'memoryability'
        % average of Weschler Memory Scale immediate and delayed.

        all_behav  = PredictTbl.memoryability;

    case 'age'
        % self reported chronological age

        all_behav  = PredictTbl.Age;

    case 'fluidintelligence'
        % fluid intellgence scores. Some participants had missing data

        PredictTbl = PredictTbl(~isnan(PredictTbl.TotalScore), :);
        all_behav  = PredictTbl.TotalScore;

    case 'EmoMemory'
        % Emotional Memory Task scores. Some participants had missing data

        % limit to subjects that have Emotional Memory Scores
        PredictTbl = PredictTbl(~isnan(PredictTbl.TotalDetRecall), :);
        all_behav  = PredictTbl.TotalDetRecall;

    case 'memorypersistence'
        % Weschler immediate - Weschler delayed. How much information was
        % retained over time.

        all_behav = PredictTbl.memorypersistence;

end

%% Routine

% an nSubjects x nConnections matrix. Used as predictors.
all_mats   = cat(1, PredictTbl.conn_sqf{:});

% set up paralell pool
pc = parcluster('local');
pc.JobStorageLocation = '/tmp/';
mypool = parpool(pc, 4);

% Run the analysis. Report how long it took to run.
switch partialCor
    case 'none'

        % time it
        tic
        [behav_pred, numpos, numneg] = run_cbpm(all_mats, all_behav, threshold, []);
        toc

    case 'age+sex+fd'

        % Code sex using effects coding; 0 = male, 1 = female
        PredictTbl.Sex = strcmp(PredictTbl.Sex, 'FEMALE');
        PredictTbl.Sex = double(PredictTbl.Sex);

        % time it
        tic
        [behav_pred, numpos, numneg] = run_cbpm(all_mats, all_behav, threshold, [PredictTbl.Age PredictTbl.Sex PredictTbl.fd]);
        toc

    case 'age+sex+fd+acer+fluidintel'

        % time it
        tic
        [behav_pred, numpos, numneg] = run_cbpm(all_mats, all_behav, threshold, [PredictTbl.Age PredictTbl.Sex PredictTbl.fd]);
        toc

end

% close the parallel pool
delete(mypool)

% write results
ResultsTbl = table(behav_pred, all_behav);
FN         = sprintf('analysis-cbpm_outcome-%s_connections-%s_connectome-%s_thresh-%.03f_partialCor-%s.csv', outcome, connections, connectome, threshold, partialCor);
writetable(ResultsTbl, FN)

FN         = sprintf('analysis-cbpm_outcome-%s_connections-%s_connectome-%s_thresh-%.03f_partialCor-%s.mat', outcome, connections, connectome, threshold, partialCor);
save(FN, 'numpos', 'numneg');

%% subfunctions

function exclude(network)

    % boolean filter of the hippocampus
    netFilter = contains(ROITbl.network, network);

    % boolean filter excluding the hippocampus
    notnetFilter = ~netFilter;

    % turn the boolean filter into a matrix to select the right
    % connections in the connectome. visualize it to make sure it looks
    % correct.
    asMat = notnetFilter .* notnetFilter';
    asMat(logical(eye(length(asMat)))) = 0;

    % turn this matrix into a squareform vector. make it a boolean
    % filter
    notnetFilter_sqf = squareform(asMat);
    notnetFilter_sqf = logical(notnetFilter_sqf);
    
    % remove the hippocampus connections
    for r = 1:height(PredictTbl)
        PredictTbl.conn_sqf{r} = PredictTbl.conn_sqf{r}(1, notnetFilter_sqf);
    end

end

end