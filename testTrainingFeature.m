tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

img_pos = cat(4,data_train.label_pos{:});
img_pos_bg = cat(4,data_train.label_pos_bg{:});
img_pos_pre = cat(4,data_train.label_pos_pre{:});
img_pos_pre2 = cat(4,data_train.label_pos_pre2{:});

img_neg = cat(4,data_train.label_neg{:});
img_neg_bg = cat(4,data_train.label_neg_bg{:});
img_neg_pre = cat(4,data_train.label_neg_pre{:});
img_neg_pre2 = cat(4,data_train.label_neg_pre2{:});

% feature information
[~,dimension] = computeFeature();

% compute positive features
idx = 100;
for i=idx
    warning('off','all')
    fprintf('Pos %d\n',i);
    img = img_pos(:,:,:,i);
    img_bg = img_pos_bg(:,:,:,i);
    img_pre = img_pos_pre(:,:,:,i);
    img_pre2 = img_pos_pre2(:,:,:,i);
    f = computeFeature(img,img_bg,img_pre,img_pre2,true);
end

toc