tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'feature.mat'));
do_cross_validation = false;

% random permute data points
% feature.pos = feature.pos(randperm(size(feature.pos,1)),:);
% feature.neg = feature.neg(randperm(size(feature.neg,1)),:);

% cross validation
if(do_cross_validation)
    fprintf('Cross Validation\n');
    num_folds = 5;
    num_pos = size(feature.pos,1);
    num_neg = size(feature.neg,1);
    fold_size_pos = round(num_pos/10);
    fold_size_neg = round(num_neg/10);
    fold_pos = mat2cell(feature.pos,[fold_size_pos*ones(1,9),num_pos-fold_size_pos*9]);
    fold_neg = mat2cell(feature.neg,[fold_size_neg*ones(1,9),num_neg-fold_size_neg*9]);
    accuracy_all = zeros(num_folds,1);
    for i=1:num_folds
        fprintf('Fold %d\n',i);
        feature_test = [fold_pos{i};fold_neg{i}];
        label_test = [ones(size(fold_pos{i},1),1);-ones(size(fold_neg{i},1),1)];
        idx = 1:num_folds;
        idx(idx==i) = [];
        feature_pos_train = cell2mat(fold_pos(idx));
        feature_neg_train = cell2mat(fold_neg(idx));
        feature_train = [feature_pos_train;feature_neg_train];
        label_train = [ones(size(feature_pos_train,1),1);-ones(size(feature_neg_train,1),1)];
        % scale training data to range [0,1]
        [feature_train,feature_max,feature_min] = scaleFeature(feature_train);
        % scale testing data to range [0,1]
        feature_test = normalizeFeature(feature_test,feature_max,feature_min);
        % train a SVM
%         model = svmtrain(label_train,feature_train,'-s 0 -t 2 -c 1 -g 0.07');
        model = svmtrain(label_train,feature_train,'-s 0 -t 0 -c 1');
        % compute testing accuracy
        [label_predict,accuracy,decision_values] = svmpredict(label_test,feature_test,model);
        accuracy_all(i) = accuracy(1);
    end
    accuracy_avg = mean(accuracy_all)
else
    fprintf('Training SVM model...\n');
    label = [ones(size(feature.pos,1),1);-ones(size(feature.neg,1),1)];
    feature = [feature.pos;feature.neg];
    % scale training data to range [0,1]
    [feature,feature_max,feature_min] = scaleFeature(feature);
    % train a SVM
    smoke_classifier = svmtrain(label,feature,'-s 0 -t 2 -c 1 -g 0.07'); 
    % save the model
    save(fullfile(target_dir,'smoke_classifier.mat'),'smoke_classifier','feature_max','feature_min','-v7.3');
end

fprintf('Done');
toc