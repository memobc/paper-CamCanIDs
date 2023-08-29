function denoisedFiles_lessExclusions = exclude_data(denoisedFiles)
% Exclude subjects/scans from the desnoisedFiles cellstring

% filter out scans that have mean FD > 0.3
include = nan(length(denoisedFiles), 1);

for s = 1:length(denoisedFiles)
    
    % this denoised file
    denoisedFile = denoisedFiles{s};
    
    % meta data from denoised file
    subject      = regexp(denoisedFile, 'sub-CC[0-9]{6}', 'match', 'once');
    task         = regexp(denoisedFile, 'task-[a-z]{3,5}', 'match', 'once');
    denoisedDir  = fileparts(denoisedFile);
    
    % the confounds file associated with this denoised file
    searchExpression      = sprintf('%s_%s_desc-confounds_timeseries.tsv', subject, task);
    fmriprepConfoundsFile = spm_select('FPList', denoisedDir, searchExpression);
    confoundsTbl          = readtable(fmriprepConfoundsFile, 'FileType', 'text', 'Delimiter', '\t');
    
    % only include this scan IF mean framewise displacement was <= 0.3
    include(s) = mean(confoundsTbl.framewise_displacement, 'omitnan') <= 0.3;

end

denoisedFiles_lessExclusions = denoisedFiles(logical(include));

end