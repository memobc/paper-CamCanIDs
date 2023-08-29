function summary_Val = summarise(connectivity, type)
% Speciality function

global ROITbl

if isempty(connectivity)
    summary_Val = NaN;
    return
end

% networks of interest
dmnc = strcmp(ROITbl.network, 'DefaultC');
dmna = strcmp(ROITbl.network, 'DefaultA');
hipp = strcmp(ROITbl.network, 'Hipp');

% lowerTriangle of the matrix
lowerTriFilter = ones(length(connectivity));
lowerTriFilter = tril(lowerTriFilter, -1);
lowerTriFilter = logical(lowerTriFilter);

switch type

    case 'within'

        % dmnc-dmnc connections
        within_Filter = dmnc .* dmnc';
        theFilter     = within_Filter & lowerTriFilter;

    case 'between'

        % dmnc-dmna connections
        between_Filter = dmnc .* dmna' | dmna .* dmnc';
        theFilter      = between_Filter & lowerTriFilter;

    case 'extra'

        % dmnc-other connections
        extra_Filter = dmnc .* ~(dmnc | dmna)' | ~(dmnc | dmna) .* dmnc';
        theFilter    = extra_Filter & lowerTriFilter;

    case 'hipp'

        % hipp connections
        hipp_Filter = hipp .* true(1, width(connectivity)) | true(height(connectivity), 1) .* hipp';
        theFilter   = hipp_Filter & lowerTriFilter;

    case 'dmnc'

        % all dmnc connections
        dmnc_Filter = dmnc .* true(1, width(connectivity)) | true(height(connectivity), 1) .* dmnc';
        theFilter   = dmnc_Filter & lowerTriFilter;

end

subset      = connectivity(theFilter);
summary_Val = mean(subset);

end

