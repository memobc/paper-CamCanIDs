% run all the minus network cbpms

addpath('functions')

atlasDir = fullfile(fileparts(mfilename('fullfile')), 'atlas');
ROIdir   = fullfile(atlasDir, 'Parcellations', 'MNI', 'Centroid_coordinates');
ROIfile  = fullfile(ROIdir, 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv');
ROITbl   = load_roi_information(ROIfile);

networks = unique(ROITbl.network)';

for n = 1:length(networks)
    exclude_str = sprintf('%s_exclude', networks{n});
    D_cbpm('memoryability', exclude_str, 'gsr', 0.01, 'age+sex+fd');
end
