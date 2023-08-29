function [behav_pred, varargout] = run_cbpm(all_mats, all_behav, thresh, partialCor)
% Taken from Shen et al. 2017. With several custom modifications
% 
% ------------ INPUTS -------------------
% 
% all_mats = nSubjects x nConnections matrix.
%
% all_behav = nSubjects x 1 vector.
%
% thresh = numeric. p-value threshold for feature selection.
%
% varargin{1} = if desired, an nSubjects x 1 vector to control for during
%               feature selection. Ex: mean framewise displacement, age

n_sub  = size(all_mats, 1);

behav_pred = zeros(n_sub, 1);

num_pos_edges_vct = nan(1, n_sub);
num_neg_edges_vct = nan(1, n_sub);

parfor leftout = 1:n_sub

    fprintf('\n Leaving out subj # %6.3f', leftout);

    % leave out subject from predictors and behavior
    train_mats             = all_mats;
    train_mats(leftout, :) = [];

    train_behav          = all_behav;
    train_behav(leftout) = [];
    
    if ~isempty(partialCor)
       partCorCont = partialCor;
       partCorCont(leftout,:) = [];
    end

    % correlate all edges with behavior
    n_edge = size(train_mats, 2);
    r_mat  = zeros(1, n_edge);
    p_mat  = zeros(1, n_edge);

    for edge_i = 1:n_edge
        if isempty(partialCor)
            [r_mat(edge_i), p_mat(edge_i)] = corr(train_mats(:, edge_i), train_behav, 'rows', 'complete');
        else
            [r_mat(edge_i), p_mat(edge_i)] = partialcorr(train_mats(:, edge_i), train_behav, partCorCont, 'rows', 'complete');
        end
    end

    % select only sub threshold connections
    pos_mask = r_mat > 0 & p_mat < thresh;
    neg_mask = r_mat < 0 & p_mat < thresh;

    % record how many positive and negative edges survived threshold
    num_pos_edges_vct(leftout) = length(find(pos_mask));
    num_neg_edges_vct(leftout) = length(find(neg_mask));

    % get sum of all edges in TRAIN subs
    train_sumpos = zeros(n_sub-1, 1);
    train_sumneg = zeros(n_sub-1, 1);
    for ss = 1:size(train_sumpos)
        train_sumpos(ss) = sum(train_mats(ss, pos_mask));
        train_sumneg(ss) = sum(train_mats(ss, neg_mask));
    end

    % build model on TRAIN subs
    % combining both postive and negative features if available
    if all(pos_mask == 0) && all(neg_mask == 0)
        b = regress(train_behav, ones(n_sub-1,1));
    elseif all(neg_mask == 0)
        b = regress(train_behav, [train_sumpos, ones(n_sub-1,1)]);
    elseif all(pos_mask == 0)
        b = regress(train_behav, [train_sumneg, ones(n_sub-1,1)]);
    else
        b = regress(train_behav, [train_sumpos, train_sumneg, ones(n_sub-1,1)]);
    end

    % run model on TEST sub
    test_mat    = all_mats(leftout, :);
    test_sumpos = sum(test_mat(1,pos_mask));
    test_sumneg = sum(test_mat(1,neg_mask));

    if all(pos_mask == 0) && all(neg_mask == 0)
        behav_pred(leftout) = b(1);
    elseif all(pos_mask == 0)
        behav_pred(leftout) = b(1)*test_sumneg + b(2);
    elseif all(neg_mask == 0)
        behav_pred(leftout) = b(1)*test_sumpos + b(2);
    else
        behav_pred(leftout) = b(1)*test_sumpos + b(2)*test_sumneg + b(3);
    end

end

% report the number of connections that survived threshold that are
% positvely and negatively related to outcome variable, if desired
varargout{1} = num_pos_edges_vct;
varargout{2} = num_neg_edges_vct;

end
