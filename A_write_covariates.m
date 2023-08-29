function A_write_covariates(task, analysis)
% Write the covariates files out for later importing into Conn
%   task = 'smt', 'rest', 'movie'
%   analysis = '', 'gsr'

%% organizing directories

% All directories are defined relative to the location of this script. See
% mfilename and fileparts help pages for more details
rootDir  = fileparts(mfilename('fullpath'));

% All software (spm12, conn, CoSMo) have symbolic links in the root
% directory.
spm12Dir = fullfile(rootDir, 'spm12');
connDir  = fullfile(rootDir, 'conn');
cosmoDir = fullfile(rootDir, 'cosmo');
addpath(spm12Dir, connDir, genpath(cosmoDir));

% More directories
bidsDir  = fileparts(rootDir); % this script's parent directory
baseDir  = fullfile(bidsDir, 'derivatives');

% where is preprocessed data?
derivDir = fullfile(baseDir, 'fmriprep');

% where are my confound regressors?
covDir   = fullfile(baseDir, 'covariates');
if strcmp(analysis, 'gsr')
    covDir = [covDir '_gsr'];
end
if ~exist(covDir, 'dir')
    mkdir(covDir);
end

subjs  = cellstr(spm_select('List', derivDir, 'dir', 'sub-CC[0-9]{6}'));
nsubjs = length(subjs);

%% organizing covariates

% The names of the covariates from the fmriprep confound *.tsv's. See
% Cooper et al. 2021 for a list of the covariates used for denoising
covarNames = {'trans_x', 'trans_x_derivative1', ...
              'trans_y', 'trans_y_derivative1', ...
              'trans_z', 'trans_z_derivative1', ...
              'rot_x', 'rot_x_derivative1', ...
              'rot_y', 'rot_y_derivative1', ...
              'rot_z', 'rot_z_derivative1', ...
              'framewise_displacement'};
if strcmp(analysis, 'gsr')
   covarNames = [covarNames, {'global_signal'}];
end

for c = 1:nsubjs

    if c == 1
        fprintf('%03d\n', c);
    else
        fprintf('\b\b\b\b%03d\n', c);
    end

    % current subject
    csub = subjs{c};

    % add onsets and durations per session for target events, as well as
    % all covariates
    csubDerivDir = fullfile(derivDir, csub, 'func');

    % grab FMRIPREP metrics associated with this session for this subject:
    regExpr = sprintf('.*task-%s_desc-confounds.*\\.tsv', task);
    covFile = spm_select('FPList', csubDerivDir, regExpr);
    covTbl  = readtable(covFile, 'FileType', 'delimitedtext', 'Delimiter', '\t');

    % grab associated JSON metadata
    regExpr = sprintf('.*task-%s_desc-confounds.*\\.json', task);
    covJSON = spm_select('FPlist', csubDerivDir, regExpr);
    covMeta = fileread(covJSON); % read file in as a character array
    covMeta = jsondecode(covMeta); % decode JSON --> structure

    % their are a LOT of fieldnames in the covMeta structure. Figure
    % out which ones correspond to the a_comp_corr* components AND have
    % a .Mask field = 'combined'
    fieldNames           = fieldnames(covMeta);
    hasMaskFieldCombined = structfun(@testCombined, covMeta); % see testCombined subfunction at end of script
    fieldIsAcompCorr     = contains(fieldNames, 'a_comp_cor');
    covMeta              = rmfield(covMeta, fieldNames(~(hasMaskFieldCombined & fieldIsAcompCorr)));

    % convert the structure covMeta --> table
    fieldnames_list      = fieldnames(covMeta);
    covMeta_table        = table();
    for f = 1:length(fieldnames_list)
        this_field = fieldnames_list{f};
        tmp = struct2table(covMeta.(this_field));
        covMeta_table = vertcat(covMeta_table, tmp); %#ok<AGROW>
    end
    covMeta_table.component = fieldnames_list;

    % sort by variance explained
    covMeta_table = sortrows(covMeta_table, 'VarianceExplained', 'descend');

    % select up to the top 6 components
    if size(covMeta_table, 1) < 6
        comp_corr_var_names  = covMeta_table.component;
    else
        comp_corr_var_names  = covMeta_table.component(1:6);
    end

    % Create a variable containing the covariate names for this subject
    % Each subject has different variable names, depending on their
    % number of principal components from aCompCor
    thisS_covarNames = [covarNames comp_corr_var_names'];

    % only select covaraites. See Cooper et al. 2021.
    % denoising
    covTbl = covTbl(:, [thisS_covarNames, {'std_dvars'}]);

    % fill in missing value at the beginning of columns
    covTbl = fillmissing(covTbl, 'constant', 0);

    % Censor volumes that have a framewise_displacement > 0.6 OR 
    % std_dvars > 2. See Cooper et al. 2021
    flaggedVols    = covTbl.framewise_displacement > 0.6 | covTbl.std_dvars > 2;
    flaggedVolsIDX = find(flaggedVols);
    censorRegressors = cell(1, length(flaggedVolsIDX));
    for v = 1:length(flaggedVolsIDX)
        cur_idx = flaggedVolsIDX(v);
        % initalize a vector of zeros
        censorRegressors{v} = zeros(size(covTbl, 1), 1);
        censorRegressors{v}(cur_idx) = 1;
    end

    % convert from cell --> matrix
    censorRegressors = cell2mat(censorRegressors);

    % convert from matrix --> table
    censorRegressors = array2table(censorRegressors);

    % write standard motion regressors to a filensubjs
    FN      = sprintf('%s_task-%s_standard_motion.txt', csub, task);
    covFile = fullfile(covDir, FN);
    covTbl  = covTbl(:, thisS_covarNames);

    if ~isempty(censorRegressors)
        covTbl = [covTbl censorRegressors];
    end

    writetable(covTbl, covFile, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', false)

end

function out = testCombined(x)
    % test the fields of a structure for a field called 'Mask'. Returns
    % true if that 'Mask' field is 'combined'
    if isfield(x, 'Mask')
        out = strcmp(x.Mask, 'combined');
    else
        out = false;
    end
end

end