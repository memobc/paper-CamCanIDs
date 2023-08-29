% Write the conditions files out for later importing into Conn

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

% where are my condition regressors?
condDir   = fullfile(baseDir, 'conditions');
if ~exist(condDir, 'dir')
    mkdir(condDir);
end

subjs  = cellstr(spm_select('List', derivDir, 'dir', 'sub-CC[0-9]{6}'));
nsubjs = length(subjs);

sessions = {'movie', 'rest', 'smt'};

%% write conditions file
% see help conn_importcondition for more information

condition_name = {};
subject_number = [];
session_number = [];
onsets         = [];
durations      = [];
c              = 0;

for nsub = 1:length(subjs)
    for nses = 1:length(sessions)
        if nses == 1
            c = c + 1;
            condition_name{c,1} = 'movie';
            subject_number(c,1) = nsub;
            session_number(c,1) = nses;
            onsets(c,1)         = 0;
            durations(c,1)      = Inf;
        elseif nses == 2
            c = c + 1;
            condition_name{c,1} = 'rest';
            subject_number(c,1) = nsub;
            session_number(c,1) = nses;
            onsets(c,1)         = 0;
            durations(c,1)      = Inf;
        elseif nses == 3

            c = c + 1;
            condition_name{c,1} = 'smt';
            subject_number(c,1) = nsub;
            session_number(c,1) = nses;
            onsets(c,1)         = 0;
            durations(c,1)      = Inf;

            this_subj_dir          = fullfile(bidsDir, 'rawdata', subjs{nsub}, 'func');
            assert(exist(this_subj_dir, 'dir'))
            this_subject_event_tsv = spm_select('FPList', this_subj_dir, '.*_events.tsv');
            if isempty(this_subject_event_tsv)
                disp('skip')
                continue
            else
                eventsTbl                = readtable(this_subject_event_tsv, 'FileType', 'text', 'Delimiter', '\t');
                eventsTbl.subject_number = repmat(nsub, height(eventsTbl), 1);
                eventsTbl.session_number = repmat(nses, height(eventsTbl), 1);
                condition_name           = vertcat(condition_name, eventsTbl.trial_type);
                subject_number           = vertcat(subject_number, eventsTbl.subject_number);
                session_number           = vertcat(session_number, eventsTbl.session_number);
                onsets                   = vertcat(onsets, eventsTbl.onset);
                durations                = vertcat(durations, eventsTbl.duration);
                c                        = c + height(eventsTbl);
            end
        end
    end
end

condTbl = table(condition_name, subject_number, session_number, onsets, durations);

writetable(condTbl, fullfile(condDir, 'conditions.csv'))