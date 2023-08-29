function R = calculate_results(results_file)

    T = readtable(results_file, 'FileType', 'text', 'Delimiter', ',');
    R = corr(T.behav_pred, T.all_behav);

end

