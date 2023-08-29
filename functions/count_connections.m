function [smoothedMat_collapsed, smoothedMat_collapsed_total] = count_connections(ROITbl, sig_mat)
% function designed to count connections

networks_hem      = ROITbl(:, {'hemisphere', 'network'});
networks_hem      = unique(networks_hem, 'stable');
smoothedMat       = nan(height(networks_hem), height(networks_hem));
smoothedMat_total = nan(height(networks_hem), height(networks_hem));

for r = 1:height(networks_hem)

    rF = eq(ROITbl.network, networks_hem.network(r)) & strcmp(ROITbl.hemisphere, networks_hem.hemisphere{r});

    for c = 1:height(networks_hem)

        cF = eq(ROITbl.network, networks_hem.network(c)) & strcmp(ROITbl.hemisphere, networks_hem.hemisphere{c});

        % find the intersection
        intersectionMat = rF .* cF';

        % divide by 2 at the digonal; take lower triangle at diagonal
        if r == c

            numSig = sum(sig_mat(logical(intersectionMat)));
            numSig = numSig / 2;

            % figure out the total number of connections in this sector
            total  = sum(tril(intersectionMat, -1), 'all');
            n      = sum(rF);
            assert(total == (n*(n-1))/2, 'invalid number of connections')

        else

            numSig = sum(sig_mat(logical(intersectionMat)));
            total  = sum(intersectionMat, 'all');
            n1     = sum(rF);
            n2     = sum(cF);
            assert(total == n1*n2, 'invalid number of connections');

        end

        smoothedMat(r,c)       = numSig;
        smoothedMat_total(r,c) = total;

    end
end

n = height(sig_mat);
assert(sum(tril(smoothedMat_total), 'all') == (n*(n-1))/2, 'invalid number of connections');

% Collapsed Over Hemisphere

networks = networks_hem(:, {'network'});
networks = unique(networks, 'stable');
smoothedMat_collapsed = nan(height(networks), height(networks));
smoothedMat_collapsed_total = smoothedMat_collapsed;

for r = 1:height(networks)

    rF = eq(networks_hem.network, networks.network(r));

    for c = 1:height(networks)

        cF = eq(networks_hem.network, networks.network(c));

        % find the intersection
        intersectionMat = rF .* cF' + cF .* rF';
        intersectionMat = tril(intersectionMat);
%         figure; imagesc(intersectionMat);
%         xticks(1:36); yticks(1:36);
%         xticklabels(cellstr(networks_hem.network));
%         xtickangle(90);
        numSig = sum(smoothedMat(logical(intersectionMat)));
        total  = sum(smoothedMat_total(logical(intersectionMat)));
        smoothedMat_collapsed(r,c)       = numSig;
        smoothedMat_collapsed_total(r,c) = total;

    end
end

n = height(sig_mat);
assert(sum(tril(smoothedMat_collapsed_total), 'all') == (n*(n-1))/2, 'invalid number of connections');

end