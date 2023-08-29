function dirName = create_dirName(ogDirName, analysis)
% change the directory name based on the current analysis

assert(ischar(analysis), 'input must be a character array')

if isempty(analysis)
    dirName = ogDirName;
else
    dirName = [ogDirName '_' analysis];
end

end