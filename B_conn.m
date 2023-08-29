% Run denoising with the CONN
% see help conn_batch
% Notes: denoises ALL available functional scans. Some scans will be
% excluded in the next step

% directories
codeDir     = fileparts(mfilename('fullpath')); % where this script is located
camcanDir   = fileparts(codeDir);
fmriprepDir = fullfile(camcanDir, 'derivatives', 'fmriprep');
rawdataDir  = fullfile(camcanDir, 'rawdata');
atlasDir    = fullfile(codeDir, 'atlas');
ritcheyDir  = fullfile(codeDir, 'Ritcheyetal2015_ROIs');

% software
spm         = fullfile(codeDir, 'spm12');
conn        = fullfile(codeDir, 'conn');
addpath(spm, conn);

%% Filename and parallel processing options

BATCH.filename = fullfile(camcanDir, 'derivatives', 'conn_gsr', 'conn_gsr.mat');

BATCH.parallel.N       = 243;
BATCH.parallel.profile = 'Slurm computer cluster';

%% Setup

% We first need to setup a conn project
BATCH.Setup.isnew     = 1;
BATCH.Setup.done      = 1;
BATCH.Setup.overwrite = 1;

% how many subjects?
subjects              = spm_select('List', fmriprepDir, 'dir', 'sub-CC[0-9]{6}');
subjects              = cellstr(subjects);
BATCH.Setup.nsubjects = length(subjects);

BATCH.Setup.RT              = NaN;
BATCH.Setup.acquisitiontype = 1;

% functionals
scans_vec = nan(1,length(subjects));
for nsub = 1:length(subjects)
    csub_dir        = fullfile(fmriprepDir, subjects{nsub}, 'func');
    scans           = spm_select('FPList', csub_dir, '^sub.*desc-preproc_bold\.nii$');
    scans           = cellstr(scans);
    scans_vec(nsub) = length(scans);
    for nses = 1:length(scans)
        BATCH.Setup.functionals{nsub}{nses} = scans{nses};
    end
end

% anatomicals
for nsub = 1:length(subjects)
    csub_dir = fullfile(fmriprepDir, subjects{nsub}, 'anat');
    scan     = spm_select('FPList', csub_dir, '^sub.*space-MNI.*desc-preproc_T1w\.nii$');
    BATCH.Setup.structurals{nsub} = scan;
end
BATCH.Setup.add = 0;

% masks
for nsub = 1:length(subjects)
    csub_dir = fullfile(fmriprepDir, subjects{nsub}, 'anat');
    grey     = spm_select('FPList', csub_dir, '^sub.*space-MNI.*label-GM.*\.nii$');
    BATCH.Setup.masks.Grey{nsub} = grey;
    white    = spm_select('FPList', csub_dir, '^sub.*space-MNI.*label-WM.*\.nii$');
    BATCH.Setup.masks.White{nsub} = white;
    csf      = spm_select('FPList', csub_dir, '^sub.*space-MNI.*label-CSF.*\.nii$');
    BATCH.Setup.masks.CSF{nsub} = csf;
end

% ROIs

roiNum = 1;
BATCH.Setup.rois.names{roiNum} = 'Schaefer Atlas';
schaferAtlasFile = fullfile(atlasDir, 'Parcellations', 'MNI', 'rSchaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.nii');
BATCH.Setup.rois.files{roiNum} = schaferAtlasFile;
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 1;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 2;
BATCH.Setup.rois.names{roiNum} = 'HIPP_BODY_L';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_BODY_L_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 3;
BATCH.Setup.rois.names{roiNum} = 'HIPP_BODY_R';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_BODY_R_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 4;
BATCH.Setup.rois.names{roiNum} = 'HIPP_HEAD_L';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_HEAD_L_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 5;
BATCH.Setup.rois.names{roiNum} = 'HIPP_HEAD_R';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_HEAD_R_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 6;
BATCH.Setup.rois.names{roiNum} = 'HIPP_TAIL_L';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_TAIL_L_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

roiNum = 7;
BATCH.Setup.rois.names{roiNum} = 'HIPP_TAIL_R';
BATCH.Setup.rois.files{roiNum} = fullfile(ritcheyDir, 'rHIPP_TAIL_R_mask.nii');
BATCH.Setup.rois.dimensions{roiNum} = 1;
BATCH.Setup.rois.weighted(roiNum) = 0;
BATCH.Setup.rois.multiplelabels(roiNum) = 0;
BATCH.Setup.rois.mask(roiNum) = 0;
BATCH.Setup.rois.regresscovariates(roiNum) = 0;
BATCH.Setup.rois.dataset(roiNum) = 0;

BATCH.Setup.rois.add = 0;

% conditions

BATCH.Setup.conditions.missingdata        = 1;
%BATCH.Setup.conditions.model{}            = ; % optional
BATCH.Setup.conditions.importfile         = fullfile(camcanDir, 'derivatives', 'conditions', 'conditions.csv');
%BATCH.Setup.conditions.importfile_options = ; % optional
BATCH.Setup.conditions.add                = 0;

% covariates
BATCH.Setup.covariates.names{1} = 'standard';
for nsub = 1:length(subjects)
    csub_dir = fullfile(camcanDir, 'derivatives', 'covariates_gsr');
    regExp   = sprintf('%s.*_standard_motion.txt', subjects{nsub});
    covFiles = spm_select('FPList', csub_dir, regExp);
    covFiles = cellstr(covFiles);
    for nses = 1:length(covFiles)
        BATCH.Setup.covariates.files{1}{nsub}{nses} = covFiles{nses};
    end
end
BATCH.Setup.covariates.add = 0;

BATCH.Setup.analyses                 = 1;
BATCH.Setup.voxelmask                = 2;
%BATCH.Setup.voxelmaskfile            = ;
BATCH.Setup.voxelresolution          = 3;
BATCH.Setup.analysisunits            = 2;
BATCH.Setup.outputfiles              = [0 0 0 0 0 0];
%BATCH.Setup.spmfiles                 = ;
%BATCH.Setup.spmfiles_options         = ;
%BATCH.Setup.vdm_functionals          = ;
%BATCH.Setup.fmap_functionals         = ;
%BATCH.Setup.coregsource_functionals  = ;
BATCH.Setup.localcopy                = 0;
%BATCH.Setup.binary_threshold         = ; % default, unneeded
%BATCH.Setup.binary_threshold_type    = ;
%BATCH.Setup.exclude_grey_matter      = ;
%BATCH.Setup.erosion_steps            = ;
%BATCH.Setup.erosion_neighb           = ;

%% Denoising

BATCH.Denoising.done       = 1;
BATCH.Denoising.overwrite  = 1;
BATCH.Denoising.filter     = [0.008, 0.1];
BATCH.Denoising.detrending = 1;
BATCH.Denoising.despiking  = 0;
BATCH.Denoising.regbp      = 1;
BATCH.Denoising.confounds.names      = {'standard', 'Effect of AudOnly', 'Effect of AudVid1200', 'Effect of AudVid300', 'Effect of AudVid600', 'Effect of VidOnly'};
BATCH.Denoising.confounds.dimensions = repmat({Inf}, 1, 6);
BATCH.Denoising.confounds.deriv      = repmat({0}, 1, 6);
BATCH.Denoising.confounds.power      = repmat({1}, 1, 6);
BATCH.Denoising.confounds.filter     = repmat({0}, 1, 6);

%% First Level Analysis

BATCH.Analysis.done       = 1;
BATCH.Analysis.overwrite  = 1;
BATCH.Analysis.name       = 'Analysis';
BATCH.Analysis.measure    = 1;
BATCH.Analysis.weight     = 1;
BATCH.Analysis.modulation = 0;
%BATCH.Analysis.conditions = ;
BATCH.Analysis.type = 1;
%BATCH.sources = ;

conn_batch(BATCH);