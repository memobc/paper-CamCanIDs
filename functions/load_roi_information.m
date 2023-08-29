function ROITbl = load_roi_information(ROIfile)

    % ROI information
    ROITbl  = readtable(ROIfile);

    network    = regexp(ROITbl.ROIName, '(?<=[LR]H_)[A-Za-z]*(?=_)', 'match');
    network    = cellfun(@char, network, 'UniformOutput', false);

    hemisphere = regexp(ROITbl.ROIName, '[LR]H', 'match');
    hemisphere = cellfun(@char, hemisphere, 'UniformOutput', false);

    ROITbl.network    = network;
    ROITbl.hemisphere = hemisphere;

    % append the hippocampal ROIs to the end
    ROILabel   = (401:406)';
    ROIName    = {'HIPP_BODY_L'; 'HIPP_BODY_R'; 'HIPP_HEAD_L'; 'HIPP_HEAD_R'; 'HIPP_TAIL_L'; 'HIPP_TAIL_R'};
    R          = NaN(6,1);
    A          = NaN(6,1);
    S          = NaN(6,1);
    network    = repmat({'Hipp'}, 6, 1);
    hemisphere = repmat({'LH'; 'RH'}, 3, 1);

    hipp_rois = table(ROILabel, ROIName, R, A, S, network, hemisphere);

    ROITbl = vertcat(ROITbl, hipp_rois);

end

