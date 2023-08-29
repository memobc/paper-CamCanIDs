function [t] = run_lasso(all_mats, all_behav, nWorkers)

% ---------------------------------------

n_sub      = size(all_mats, 3);
behav_pred = zeros(n_sub, 1);

% set up parallel computing pool
mypool = parpool(nWorkers);

stream = RandStream('mrg32k3a');

opts = statset('UseParallel',true,'UseSubstreams',true,'Streams',stream);

for leftout = 1%:n_sub

    %fprintf('\n Leaving out subj # %6.3f', leftout);

    % leave out subject from matrices and behavior
    train_mats = all_mats;
    train_mats(:,:,leftout) = [];

    % squareform each connectivity matrix
    train_vcts = nan(size(train_mats,3), 82215);
    for i = 1:size(train_mats, 3)
        train_vcts(i,:) = to_squareform(train_mats(:,:,i));
    end

    train_behav          = all_behav;
    train_behav(leftout) = [];

    mask = nan(1,size(train_vcts, 2));
    for i = 1:size(train_vcts, 2)
        [~, p] = corr(train_behav, train_vcts(:, i));
        mask(i) = p < 0.01;
    end
    
    mask = logical(mask);
    
    tic;
    [B, S] = lasso(train_vcts(:, mask), train_behav, 'CV', 10, 'Alpha', 1e-6, 'Options', opts);
    t = toc;

    % run model on TEST sub
%     test_mat    = all_mats(:, :, leftout);
%     test_vct    = reshape(test_mat, [], 1);
%     test_vct    = shiftdim(test_vct, 1);
% 
%     behav_pred(leftout) = b(1)*test_SCORE(1) + b(2)*test_SCORE(2) + b(3);

end

delete(mypool)

end
