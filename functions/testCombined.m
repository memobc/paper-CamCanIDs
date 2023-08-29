function out = testCombined(x)
    % test the fields of a structure for a field called 'Mask'. Returns
    % true if that 'Mask' field is 'combined'
    if isfield(x, 'Mask')
        out = strcmp(x.Mask, 'combined');
    else
        out = false;
    end
end
