clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
warning('off','all')

target_dir = 'frames';
load(fullfile(target_dir,'data_train.mat'));

img_pos = cat(4,data_train.label_pos{:});
img_neg = cat(4,data_train.label_neg{:});

try
    figure(1)
    imdisp(img_pos(:,:,:,datasample(1:size(img_pos,4),231)),'Border',[0.01,0.01],'Size',[11,21]);
catch
end

try
    figure(2)
    imdisp(img_neg(:,:,:,datasample(1:size(img_neg,4),231)),'Border',[0.01,0.01],'Size',[11,21]);
catch
end