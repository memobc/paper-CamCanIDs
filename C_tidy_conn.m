% Tidy the results from the conn analysis

addpath('functions')
addpath('spm12')

%% organize directories

codeDir     = fileparts(mfilename('fullpath'));
camcanDir   = fileparts(codeDir);
derivDir    = fullfile(camcanDir, 'derivatives');
connDir     = fullfile(derivDir, 'conn_gsr', 'conn_gsr', 'results', 'firstlevel', 'SBC_01');
fmriprepDir = fullfile(derivDir, 'fmriprep');
rawDir      = fullfile(camcanDir, 'rawdata');

%% organize files

% files from conn output
movieFiles = dir(fullfile(connDir, '*Subject*Condition001.mat'));
restFiles  = dir(fullfile(connDir, '*Subject*Condition002.mat'));
smtFiles   = dir(fullfile(connDir, '*Subject*Condition008.mat'));

movieFiles = struct2table(movieFiles);
restFiles  = struct2table(restFiles);
smtFiles   = struct2table(smtFiles);

% tidying everything as a table
allFiles         = vertcat(movieFiles, restFiles, smtFiles);
allFiles         = allFiles(:, {'folder', 'name'});
allFiles.subject = regexp(allFiles.name, 'Subject[0-9]{3}', 'match', 'once');
allFiles.task    = regexp(allFiles.name, 'Condition[0-9]{3}', 'match', 'once');

% subject labels from fmriprep dir names
subjects         = spm_select('List', fmriprepDir, 'dir', 'sub-CC[0-9]{6}');
subjects         = cellstr(subjects);
valueset         = unique(allFiles.subject);
allFiles.subject = categorical(allFiles.subject, valueset, subjects);

catlabels     = {'movie', 'rest', 'smt'};
valueset      = {'Condition001', 'Condition002', 'Condition008'};
allFiles.task = categorical(allFiles.task, valueset, catlabels);

%% Load Connectivity Matrices

% initialize new column
allFiles.connectivity = cell(height(allFiles), 1);

% for each row...
for row = 1:height(allFiles)

    folder = allFiles.folder{row};
    name   = allFiles.name{row};

    % load connetivity matrix from conn
    load(fullfile(folder, name), 'Z')

    % convert from Z back to R
    R = tanh(Z);

    % force the diagonal to be 1
    selectDiag    = eye(length(R));
    selectDiag    = logical(selectDiag);
    R(selectDiag) = 1;

    allFiles.connectivity{row} = R;

end

%% Remove problematic tasks runs

include = true(height(allFiles), 1);

% for each row...
for row = 1:height(allFiles)

    % this subject/task
    subject = allFiles.subject(row);
    subject = char(subject);
    task    = allFiles.task(row);
    task    = char(task);

    % this counfounds file
    thisSs_fmriprep_dir     = fullfile(fmriprepDir, subject, 'func');
    search_expr             = sprintf('^sub.*task-%s.*desc-confounds.*\\.tsv', task);
    thisScan_confounds_File = spm_select('FPList', thisSs_fmriprep_dir, search_expr);

    T = readtable(thisScan_confounds_File, 'FileType', 'text', 'Delimiter', '\t');

    % what is the average framewise displacement for this scan?
    meanFD = mean(T.framewise_displacement, 'omitnan');

    % exclude this 
    if meanFD > 0.3
        include(row) = false;
    end

    % check that they have events data for the SMT task
    if strcmp(task, 'smt')
        thisRawDir = fullfile(rawDir, subject, 'func');
        eventsFile = spm_select('FPList', thisRawDir, '.*events\.tsv');
        if isempty(eventsFile)
           include(row) = false;
        end
    end

end

allFiles = allFiles(include, :);

%% Tidy

ConnTbl = allFiles(:,{'subject', 'task', 'connectivity'});
ConnTbl = unstack(ConnTbl, 'connectivity', 'task');
ConnTbl.intrinsic = cell(height(ConnTbl), 1);

for s = 1:height(ConnTbl)
    catMats = cat(3, ConnTbl.movie{s}, ConnTbl.rest{s}, ConnTbl.smt{s});
    ConnTbl.intrinsic{s} = mean(catMats, 3);
end

%% write

save('results/ConnTbl_gsr.mat', 'ConnTbl')