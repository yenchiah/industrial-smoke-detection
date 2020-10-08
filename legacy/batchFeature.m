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
load(fullfile(path,'data.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(path,'bbox.mat'));

% crop images
fprintf('Cropping images\n');
data = data(bbox_row,bbox_col,:,:);

% allocate spaces
num_imgs = size(data,4);
responses_all = cell(num_imgs,1);

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
    [responses,~] = computeFeature(img);
    responses_all{t} = responses;
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
save(fullfile(path,'feature.mat'),'feature');
fprintf('Done\n');
toc