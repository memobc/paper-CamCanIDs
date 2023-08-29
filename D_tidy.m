% tidy data for analysis

%% requirements

global ROITbl

% All directories are defined relative to the location of this script. See
% mfilename and fileparts help pages for more details
rootDir  = fileparts(mfilename('fullpath'));
baseDir  = fileparts(rootDir);

behavDir   = fullfile(baseDir, 'new_sourcedata', 'dataman', 'useraccess', 'processed', 'Maureen_Ritchey_1109');
emoMemDir  = fullfile(baseDir, 'sourcedata', 'cc700-scored', 'EmotionalMemory', 'release001', 'summary');
cattellDir = fullfile(baseDir, 'sourcedata', 'cc700-scored', 'Cattell', 'release001', 'summary');
acerDir    = fullfile(baseDir, 'sourcedata', 'dataman', 'useraccess', 'processed', 'Maureen_Ritchey_1016');

% All software (spm12, conn, CoSMo) have symbolic links in the code
% directory.
spm12Dir = fullfile(rootDir, 'spm12');
connDir  = fullfile(rootDir, 'conn');
atlasDir = fullfile(rootDir, 'atlas');
addpath(spm12Dir, connDir, 'functions');

%% load data

% connectivity data
load('results/ConnTbl_gsr.mat')

% conn tbl
ConnTbl.subject = cellstr(ConnTbl.subject);

% roi information
ROIdir        = fullfile(atlasDir, 'Parcellations', 'MNI', 'Centroid_coordinates');
ROIfile       = fullfile(ROIdir, 'Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv');
ROITbl        = load_roi_information(ROIfile);

% behavior
Weschler_File = fullfile(behavDir, 'approved_data.tsv');
WeschlerTbl   = readtable(Weschler_File, 'FileType', 'text', 'Delimiter', '\t');

EmoMem_File   = fullfile(emoMemDir, 'EmotionalMemory_summary.txt');
EmoMemTbl     = readtable(EmoMem_File, 'FileType', 'text', 'Delimiter', '\t', 'Range', '9:339');
EmoMemTbl     = EmoMemTbl(:, {'CCID', 'DetPosPic', 'DetNeuPic', 'DetNegPic'});
EmoMemTbl.TotalDetRecall = sum([EmoMemTbl.DetPosPic, EmoMemTbl.DetNeuPic, EmoMemTbl.DetNegPic], 2);

Cattell_File  = fullfile(cattellDir, 'Cattell_summary.txt');
CattellTbl    = readtable(Cattell_File, 'FileType', 'text', 'Delimiter', '\t', 'Range', '9:669');
CattellTbl    = CattellTbl(:, {'CCID','TotalScore'});

acerFile      = fullfile(acerDir, 'approved_data.tsv');
acerTbl       = readtable(acerFile, 'FileType', 'text', 'Delimiter', '\t');
acerTbl       = acerTbl(:, {'CCID', 'additional_acer'});

% demographic
Demo_File = fullfile(behavDir, 'standard_data.csv');
DemoTbl   = readtable(Demo_File, 'FileType', 'text', 'Delimiter', ',');

% motion
fmriprep.dir      = '/mmfs1/data/kurkela/Desktop/CamCan/derivatives/fmriprep';
files             = cellstr(spm_select('FPListRec', fmriprep.dir, '.*desc-confounds_timeseries\.tsv'));
MotionTbl         = table();
MotionTbl.file    = files;
MotionTbl.task    = regexp(files, '(?<=task-)[a-z]{3,5}', 'match', 'once');
MotionTbl.subject = regexp(files, '(?<=sub-)CC[0-9]{6}', 'match', 'once');
MotionTbl.meanFD  = cellfun(@C_extract_motion, files);

%% Tidy Behavior

% left join the behavioral data into the connectivity data
ConnTbl.subject = erase(ConnTbl.subject, 'sub-');
PredictTbl      = innerjoin(ConnTbl, WeschlerTbl, 'LeftKeys', 'subject', 'RightKeys', 'CCID');

PredictTbl      = outerjoin(PredictTbl, EmoMemTbl, 'LeftKeys', 'subject', 'RightKeys', 'CCID');
PredictTbl      = PredictTbl(~cellfun(@isempty, PredictTbl.subject), :);

% Create the memory ability index
PredictTbl.memoryability = rowfun(@(x,y) mean([x y]), PredictTbl, ...
                                  'InputVariables', {'homeint_storyrecall_i', 'homeint_storyrecall_d'}, ...
                                  'OutputFormat', 'uniform');
% Create the memory persistence index
PredictTbl.memorypersistence = rowfun(@(x,y) (y - x)/x, PredictTbl, ...
                                    'InputVariables', {'homeint_storyrecall_i', 'homeint_storyrecall_d'}, ...
                                    'OutputFormat', 'uniform');

%% Tidy Demographics Data

PredictTbl = innerjoin(PredictTbl, DemoTbl, 'LeftKeys', 'subject', 'RightKeys', 'CCID');
PredictTbl = removevars(PredictTbl, {'homeint_v219', 'homeint_v515', 'Hand', 'Coil', 'MT_TR', 'CCID'});
PredictTbl = outerjoin(PredictTbl, CattellTbl, 'LeftKeys', 'subject', 'RightKeys', 'CCID', 'Type', 'left');
PredictTbl = outerjoin(PredictTbl, acerTbl, 'LeftKeys', 'subject', 'RightKeys', 'CCID', 'Type', 'left');
PredictTbl = removevars(PredictTbl, {'CCID_PredictTbl', 'CCID_acerTbl'});

%% Add Motion

subjects      = PredictTbl.subject;
PredictTbl.fd = nan(size(PredictTbl, 1), 1);
MotionTbl     = unstack(MotionTbl(:, {'subject', 'task', 'meanFD'}), 'meanFD', 'task');
PredictTbl    = innerjoin(PredictTbl, MotionTbl, 'LeftKeys', 'subject', 'RightKeys', 'subject');

oldnames      = {'movie_PredictTbl', 'rest_PredictTbl', 'smt_PredictTbl'};
newnames      = strrep(oldnames, '_PredictTbl', '_connectivity');
PredictTbl    = renamevars(PredictTbl, oldnames, newnames);
PredictTbl    = renamevars(PredictTbl, 'intrinsic', 'intrinsic_connectivity');

oldnames      = {'movie_MotionTbl', 'rest_MotionTbl', 'smt_MotionTbl'};
newnames      = strrep(oldnames, '_MotionTbl', '_fd');
PredictTbl    = renamevars(PredictTbl, oldnames, newnames);

for s = 1:height(PredictTbl)
    Row = PredictTbl(s, :);
    F   = [~isempty(Row.movie_connectivity{1}) ~isempty(Row.rest_connectivity{1}) ~isempty(Row.smt_connectivity{1})];
    FDs = [Row.movie_fd Row.rest_fd Row.smt_fd];
    PredictTbl.fd(s) = mean(FDs(F));
end

%% Calculate within/between/extra/hipp connectivity values

%%% Intrinsic
PredictTbl.intrinsic_within  = cellfun(@(x) summarise(x, 'within'), PredictTbl.intrinsic_connectivity);
PredictTbl.intrinsic_between = cellfun(@(x) summarise(x, 'between'), PredictTbl.intrinsic_connectivity);
PredictTbl.intrinsic_extra   = cellfun(@(x) summarise(x, 'extra'), PredictTbl.intrinsic_connectivity);
PredictTbl.intrinsic_hipp    = cellfun(@(x) summarise(x, 'hipp'), PredictTbl.intrinsic_connectivity);

%%% Movie
PredictTbl.movie_within  = cellfun(@(x) summarise(x, 'within'), PredictTbl.movie_connectivity);
PredictTbl.movie_between = cellfun(@(x) summarise(x, 'between'), PredictTbl.movie_connectivity);
PredictTbl.movie_extra   = cellfun(@(x) summarise(x, 'extra'), PredictTbl.movie_connectivity);
PredictTbl.movie_hipp    = cellfun(@(x) summarise(x, 'hipp'), PredictTbl.movie_connectivity);

%%% Rest
PredictTbl.rest_within  = cellfun(@(x) summarise(x, 'within'), PredictTbl.rest_connectivity);
PredictTbl.rest_between = cellfun(@(x) summarise(x, 'between'), PredictTbl.rest_connectivity);
PredictTbl.rest_extra   = cellfun(@(x) summarise(x, 'extra'), PredictTbl.rest_connectivity);
PredictTbl.rest_hipp    = cellfun(@(x) summarise(x, 'hipp'), PredictTbl.rest_connectivity);

%%% SMT
PredictTbl.smt_within  = cellfun(@(x) summarise(x, 'within'), PredictTbl.smt_connectivity);
PredictTbl.smt_between = cellfun(@(x) summarise(x, 'between'), PredictTbl.smt_connectivity);
PredictTbl.smt_extra   = cellfun(@(x) summarise(x, 'extra'), PredictTbl.smt_connectivity);
PredictTbl.smt_hipp    = cellfun(@(x) summarise(x, 'hipp'), PredictTbl.smt_connectivity);

%% write

% Write Data
save('results/PredictTbl_gsr.mat', 'PredictTbl')

% Write data as a csv for importing into R
allVars    = PredictTbl.Properties.VariableNames;
connVars   = allVars(contains(allVars, 'connectivity'));
PredictTbl = removevars(PredictTbl, connVars);

writetable(PredictTbl, 'results/PredictTbl_gsr.csv');