function [behav_pred] = run_pca(all_mats, all_behav)

% ---------------------------------------

n_sub  = size(all_mats, 3);
n_node = size(all_mats, 1);

behav_pred = zeros(n_sub, 1);

for leftout = 1:n_sub

    fprintf('\n Leaving out subj # %6.3f', leftout);

    % leave out subject from matrices and behavior
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];
    train_vcts = reshape(train_mats, [], size(train_mats, 3));
    train_vcts = shiftdim(train_vcts, 1);

    train_behav          = all_behav;
    train_behav(leftout) = [];

    [COEFF, SCORE] = pca(train_vcts, 'Centered', false, 'NumComponents', 2);

    % build model on TRAIN subs
    b = regress(train_behav, [SCORE ones(n_sub-1,1)]);

    % run model on TEST sub
    test_mat    = all_mats(:, :, leftout);
    test_vct    = reshape(test_mat, [], 1);
    test_vct    = shiftdim(test_vct, 1);

    test_SCORE  = test_vct * COEFF;

    behav_pred(leftout) = b(1)*test_SCORE(1) + b(2)*test_SCORE(2) + b(3);

end

end
