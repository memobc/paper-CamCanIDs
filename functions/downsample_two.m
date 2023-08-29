function smoothedMat = downsample_two(sig_mat, ROITbl)
    % function designed to count connections

networks    = ROITbl(:,{'network'});
networks    = unique(networks, 'stable');
smoothedMat = nan(height(networks), height(networks));

for r = 1:height(networks)
    rF = eq(ROITbl.network, networks.network(r));
    for c = 1:height(networks)
        cF = eq(ROITbl.network, networks.network(c));
        % find the intersection
        intersectionMat = rF .* cF' + cF .* rF';

        intersectionMat = tril(intersectionMat, -1);
        thisCombo       = sig_mat(logical(intersectionMat));
        numSig          = mean(thisCombo, 'omitnan');

        smoothedMat(r,c) = numSig;
    end
end

end