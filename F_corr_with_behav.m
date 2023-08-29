% How correlated are intrinsic connections with memory ability?

addpath('functions')

% which variable?
variable = 'memoryability'; % Age, memoryability, TotalScore
thresh   = 0.01;

rootDir  = fileparts(mfilename('fullpath'));
atlasDir = fullfile(rootDir, 'atlas');

% load the prediction table
load('results/PredictTbl_gsr.mat')

% Dummy code sex variable
PredictTbl.Sex = strcmp(PredictTbl.Sex, 'FEMALE');
PredictTbl.Sex = double(PredictTbl.Sex);

% initialize variables
conn_mats  = cat(3, PredictTbl.intrinsic_connectivity{:}); % nROI x nROI x nSubs
corr_mat   = nan(size(conn_mats, 1), size(conn_mats, 2)); % nROI x nROI
p_mat      = nan(size(conn_mats, 1), size(conn_mats, 2)); % nROI x nROI
behav_vect = PredictTbl.(variable); % nSubs x 1

% roi information
ROIdir     = fullfile(atlasDir, 'Parcellations', 'MNI', 'Centroid_coordinates');
ROIfile    = fullfile(ROIdir, 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv');
ROITbl     = load_roi_information(ROIfile);
valueset   = unique(ROITbl.network, 'stable');
ROITbl.network = categorical(ROITbl.network, valueset);

% calculate correlation of each connection with memory ability
% controlling for age, sex, and average framewise displacement
for i = 1:size(conn_mats, 1)
    for j = 1:size(conn_mats, 2)
        conn_vect     = squeeze(conn_mats(i,j,:));
        [RHO, PVAL]   = partialcorr(conn_vect, behav_vect, [PredictTbl.Age PredictTbl.fd PredictTbl.Sex], 'rows', 'complete');
        corr_mat(i,j) = RHO;
        p_mat(i,j)    = PVAL;
    end
end

sig_mat = p_mat < thresh;

filter_cor_mat = corr_mat .* sig_mat;
filter_cor_mat(filter_cor_mat == 0) = NaN;

%%

% figure 1 -- corr(connection, memoryability)
F = figure('name', 'corr(connection, memoryability)', 'Position', [25 100 600 400]);
imagesc(filter_cor_mat,'AlphaData',~isnan(filter_cor_mat))
colorbar('ticks', -.3:.05:.2);
title(sprintf('corr(connection, %s)', variable))
xticks([1 100:100:400])
yticks([1 100:100:400])

figure;
histogram(corr_mat(:))

figure;
histogram(corr_mat(sig_mat))

sig_mat_pos = corr_mat > 0 & sig_mat;
sig_mat_neg = corr_mat < 0 & sig_mat;

%%% Count the number of significant connections within each cell

[total, count] = count_connections(ROITbl, sig_mat);
pos            = count_connections(ROITbl, sig_mat_pos);
neg            = count_connections(ROITbl, sig_mat_neg);
diff           = pos - neg;
assert(all((pos + neg) == total, 'all'), 'error')
assert(sum(tril(count), 'all') == (406*(406-1))/2, 'invalid number of connections')

networks = categories(ROITbl.network);

writecell(networks, 'results/networks.txt')

writematrix(total, 'results/total.txt')
writematrix(pos, 'results/pos.txt')
writematrix(neg, 'results/neg.txt')
writematrix(diff, 'results/diff.txt')
writematrix(count, 'results/count.txt')
writematrix(filter_cor_mat, 'results/thresholded_mat.txt')

%% Write out a downsampled version of the Conn, Behav matrix

down_corr_mat = downsample_two(corr_mat, ROITbl);
writematrix(down_corr_mat, 'results/downsampled_corr_with_behav_mat.txt')
