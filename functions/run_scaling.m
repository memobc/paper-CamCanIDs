function run_scaling(numCPUs)

    numWorkers = [2 4 6 8 12];
    t = nan(1, length(numWorkers));
    for n = 1:length(numWorkers)
        t(n) = D_Lasso('memoryability', numWorkers(n));
    end

    filename = sprintf('scaling-analysis_numCPUs-%d_startupCost_Substream.mat', numCPUs);
    save(filename, 'numWorkers', 't')

end