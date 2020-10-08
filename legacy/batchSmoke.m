tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
fprintf('Loading data.mat\n');
data = load(fullfile(path,'data.mat'));
fprintf('Loading data_median_60.mat\n');
data_median = load(fullfile(path,'data_median_60.mat'));
fprintf('Loading texture.mat\n');
texture = load(fullfile(path,'texture.mat'));
fprintf('Loading texture_median.mat\n');
texture_median = load(fullfile(path,'texture_median.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(path,'bbox.mat'));

% crop images
fprintf('Cropping images\n');
data = data.data(bbox_row,bbox_col,:,:);
data_median = data_median.median(bbox_row,bbox_col,:,:);
texture = texture.texture(bbox_row,bbox_col,:,:);
tex_bg = texture_median.texture_median(bbox_row,bbox_col,:);

% allocate spaces
num_imgs = size(data,4);
responses_all = cell(num_imgs,1);
label_predict = false(size(data,1),size(data,2),1,size(data,4));
has_label_predict = false(1,size(data,4));

% create workers
try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'));
catch ME
    disp(ME.message);
end
local_cluster = parcluster('local');
num_workers = 3;
if(local_cluster.NumWorkers > num_workers + 1)
    num_workers = local_cluster.NumWorkers;
end
parpool('local',num_workers);

parfor t=3:num_imgs
    fprintf('Processing frame %d\n',t);
    img = data(:,:,:,t);
    img_bg = data_median(:,:,:,t);
    tex = texture(:,:,:,t);
    [responses,imgs_filtered] = detectSmoke(img,img_bg,tex,tex_bg);
    responses_all{t} = responses;
    label_predict(:,:,:,t) = imgs_filtered.img_bs_mask_clean;
    if(sum(imgs_filtered.img_bs_mask_clean(:))>0)
        has_label_predict(t) = true;
    end
end

% close workers
delete(gcp('nocreate'));

% process features
fprintf('Computing feature vector\n');
fields = fieldnames(responses_all{3});
for i=1:length(fields)
    feature.(fields{i}) = zeros(num_imgs,1);
end
for j=3:num_imgs
    for k=1:length(fields)
        feature.(fields{k})(j) = responses_all{j}.(fields{k});
    end
end

% save file
fprintf('Saving feature.mat\n');
save(fullfile(path,'feature.mat'),'feature','-v7.3');
fprintf('Saving label_predict.mat\n');
save(fullfile(path,'label_predict.mat'),'label_predict','-v7.3');
fprintf('Saving has_label_predict.mat\n');
save(fullfile(path,'has_label_predict.mat'),'has_label_predict','-v7.3');
fprintf('Done\n');
toc