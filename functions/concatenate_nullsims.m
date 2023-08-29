function Rsims = concatenate_nullsims(analysis)
% Load and Concatenate Rsims

funcDir     = fileparts(fileparts(mfilename('fullpath')));
dirName     = sprintf('nullsims_%s', analysis);
nullsimsDir = fullfile(funcDir, dirName);

a         = dir(fullfile(nullsimsDir, '*.mat'));
fileNames = {a.name};
fileNames = fileNames';
fileNames = strcat(nullsimsDir,filesep,fileNames);
Rsims     = cellfun(@load, fileNames);
Rsims     = [Rsims.R];

end