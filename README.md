Memolab’s CamCan Individual Differences Project
================

# Scripts Overview

Below is a table of scripts contained in this repository alongside a
short written description. The scripts or organized in the order in
which they were intended to be run. This is because some scripts, for
example, depend on the output of previous scripts.

| Script                          | Type       | Description                                                                                                                    | Key Output                                                                                     |
|---------------------------------|------------|--------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `0_tidy.R`                      | R          | Creates a tidyverse compatible data frame from available data from the raw CamCan data and from MRIQC outputs                  | data.rds, motion.rds                                                                           |
| `1_subject_numbers.Rmd`         | R markdown | Illustrates subject numbers based on various selection criteria.                                                               |                                                                                                |
| `1_inclusion_criteria.Rmd`      | R markdown | Alternative to previous script, this time using a parameterized report format.                                                 |                                                                                                |
| `1_subjects_to_prep.R`          | R          | Based on a selection of inclusion criteria, writes out a text file with a list of CamCan subject IDs to preprocess in fmriprep | subjects_to_prep.txt                                                                           |
| `2_fix_bids.R`                  | R          | Script that fixes the formatting of the raw BIDS data to comply with BIDS formatting                                           |                                                                                                |
| `2_fix_fmaps.R`                 | R          | Script that fixes the formatting of the fieldmaps to comply with BIDS formatting                                               |                                                                                                |
| `A_write_conditions.m`          | MATLAB     | Script for writing out conditions text file for use by the conn toolbox                                                        | `conditions.csv`                                                                               |
| `A_write_covariates.m`          | MATLAB     | Script for writing out covariates text files for use by the conn toolbox                                                       | `sub-###_task-TASK_standard_motion.txt`                                                        |
| `B_conn.m`                      | MATLAB     | Script for running conn toolbox on preprocessed fMRI data.                                                                     |                                                                                                |
| `C_tidy_conn.m`                      | MATLAB     | script for importing scan run specific connectivity matrices into a tidy format                                                | `ConnTbl.mat`                                                                                  |
| `D_tidy.m`                      | MATLAB     | Script for further tidying connectivity data. Calculates within, between, extra, and hipp means.                               | `PredictTbl.mat`, `PredictTbl.csv`                                                             |
| `E_bayesModels.R`                      | R     | Script for further tidying connectivity data. Calculates within, between, extra, and hipp means.                               | `PredictTbl.mat`, `PredictTbl.csv`                                                             |
| `E_CreateTable1.R`                      | R     | Script for further tidying connectivity data. Calculates within, between, extra, and hipp means.                               | `PredictTbl.mat`, `PredictTbl.csv`                                                             |
| `E_linearModels.Rmd.m`                      | R     | Script for further tidying connectivity data. Calculates within, between, extra, and hipp means.                               | `PredictTbl.mat`, `PredictTbl.csv`                                                             |
| `F_cbpm.m`                      | MATLAB     | Script for running the CBPM analysis                                                                                           | `analysis-cbpm_outcome-%s_connections-%s_connectome-%s_thresh-%.03f_partialCor-%s.csv`; `.mat` |
| `F_cbpm.slurm`                  | bash       | Script for submitting a CBPM analysis to the SLURM batch queuing system                                                        |                                                                                                |
| `F_cbpm_nullsim.m`              | MATLAB     | Script for running a single null simulation for a CBPM analysis                                                                |                                                                                                |
| `F_cbpm_nullsim.slurm`          | bash       |  |                                                                                                |
| `F_cbpm_nullsim_jobarray.slurm` | bash       |  |                                                                                                |
| `F_cbpm_nullsim_jobarray.slurm` | bash       |    |    
| `F_downsample_and_pick.m` | MATLAB       |     |   
| `F_howsimilar.R` | R       |   |   
| `F_null_sim.m` | MATLAB       |   |   
| `F_predict_behavior.m` | MATLAB       |   |   
| `F_visualize.m` | MATLAB       |   |   
| `G_CreateFigure2.R` | R       |    |   
| `G_CreateFigure5alt.R` | R       |   |   
| `G_CreateFigure6alt.R` | R       |    |   
| `G_CreateFigureS1.R` | R       |   |   
| `G_CreateFigureS2.R` | R       |   |   
| `G_CreateFigureS3.R` | R       |    |   
| `G_CreateFigure10.R` | R       |   |   
| `G_CreateFigure11.R` | R       |   |   
| `G_CreateFigure12.R` | R       |   |   
| `G_CreateFigure14.R` | R       |             |   
| `G_CreateFigure11.R` | R       |                               |   
| `G_Table1.R` | R       |                                  |   
| `G_Table3.R` | R       |                                  |   # paper-CamCanIDs
