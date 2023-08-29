function smoothedMat_collapsed = downsample(sig_mat, ROITbl)
    % function designed to count connections

networks_hem = ROITbl(:,{'hemisphere', 'network'});
networks_hem = unique(networks_hem, 'stable');
smoothedMat  = nan(height(networks_hem), height(networks_hem));

for r = 1:height(networks_hem)
    rF = eq(ROITbl.network, networks_hem.network(r)) & strcmp(ROITbl.hemisphere, networks_hem.hemisphere{r});
    for c = 1:height(networks_hem)
        cF = eq(ROITbl.network, networks_hem.network(c)) & strcmp(ROITbl.hemisphere, networks_hem.hemisphere{c});
        % find the intersection
        intersectionMat = rF .* cF';

        if c == r
            intersectionMat = tril(intersectionMat, -1);
            thisCombo       = sig_mat(logical(intersectionMat));
            numSig          = mean(thisCombo);
        else
            numSig = mean(sig_mat(logical(intersectionMat)));
        end
        smoothedMat(r,c) = numSig;
    end
end

% Collapsed Over Hemisphere

networks = networks_hem(:, {'network'});
networks = unique(networks, 'stable');
smoothedMat_collapsed = nan(height(networks), height(networks));

for r = 1:height(networks)
    rF = eq(networks_hem.network, networks.network(r));
    for c = 1:height(networks)
        cF = eq(networks_hem.network, networks.network(c));
        % find the intersection
        intersectionMat = rF .* cF';
        numSig = mean(smoothedMat(logical(intersectionMat)));
        smoothedMat_collapsed(r,c) = numSig;
    end
end


end