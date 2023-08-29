% How similar are the connectomes calculated using each task?

%% requirements

% All directories are defined relative to the location of this script. See
% mfilename and fileparts help pages for more details
rootDir  = fileparts(mfilename('fullpath'));

% All software (spm12, conn, CoSMo) have symbolic links in the code
% directory.
spm12Dir = fullfile(rootDir, 'spm12');
connDir  = fullfile(rootDir, 'conn');
cosmoDir = fullfile(rootDir, 'cosmo');
atlasDir = fullfile(rootDir, 'atlas');
addpath(spm12Dir, connDir, genpath(cosmoDir));

load('results/ConnTbl_gsr.mat')

%% rest -- movie similarity

% Just the rest and movie connectomes
RestMovie = ConnTbl(:,{'rest', 'movie'});

% remove rows that are missing either
RestMovie(cellfun(@isempty, RestMovie.rest),:)  = [];
RestMovie(cellfun(@isempty, RestMovie.movie),:) = [];

% initalize similarity column
RestMovie.similarity = NaN(height(RestMovie), 1);

for s = 1:height(RestMovie)

    rest  = to_squareform(RestMovie.rest{s})';
    movie = to_squareform(RestMovie.movie{s})';

    RestMovie.similarity(s) = corr(rest, movie);

end

% write
RestMovie.rest     = [];
RestMovie.movie    = [];
RestMovie.taskPair = repmat({'rest-movie'}, height(RestMovie), 1);
writetable(RestMovie, 'restmovie.csv')

%% rest -- smt similarity

% Just the rest and smt connectomes
RestSmt = ConnTbl(:,{'rest', 'smt'});

% remove rows that are missing either
RestSmt(cellfun(@isempty, RestSmt.rest),:) = [];
RestSmt(cellfun(@isempty, RestSmt.smt),:)  = [];

% initalize similarity column
RestSmt.similarity = NaN(height(RestSmt), 1);

for s = 1:height(RestSmt)

    rest = to_squareform(RestSmt.rest{s})';
    smt  = to_squareform(RestSmt.smt{s})';

    RestSmt.similarity(s) = corr(rest, smt);

end

% write
RestSmt.rest     = [];
RestSmt.smt      = [];
RestSmt.taskPair = repmat({'rest-smt'}, height(RestSmt), 1);
writetable(RestSmt, 'restsmt.csv')

%% movie -- smt similarity

% Just the rest and movie connectomes
MovieSmt = ConnTbl(:,{'subject', 'movie', 'smt'});

% remove rows that are missing either
MovieSmt(cellfun(@isempty, MovieSmt.movie),:) = [];
MovieSmt(cellfun(@isempty, MovieSmt.smt),:)   = [];

% initalize similarity column
MovieSmt.similarity = NaN(height(MovieSmt), 1);

for s = 1:height(MovieSmt)

    movie  = to_squareform(MovieSmt.movie{s})';
    smt = to_squareform(MovieSmt.smt{s})';

    MovieSmt.similarity(s) = corr(movie, smt);

end

% write
MovieSmt.movie    = [];
MovieSmt.smt      = [];
MovieSmt.taskPair = repmat({'movie-smt'}, height(MovieSmt), 1);
writetable(MovieSmt, 'moviesmt.csv')
