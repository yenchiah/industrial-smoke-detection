tic
clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-03.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
texture_mat = matfile(fullfile(path,'texture.mat'));

% create workers
try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'));
catch ME
    disp(ME.message);
end
local_cluster = parcluster('local');
num_workers = 3;
parpool('local',num_workers);

% compute median images over a time period
[day_min_idx,day_max_idx] = getDayIdx();
size_texture = size(texture_mat,'texture');
texture_median = zeros([size_texture(1),size_texture(2),size_texture(3)],'uint8');
parfor i=1:3
    fprintf('Processing channel %d\n',i);
    texture_median(:,:,i) = median(texture_mat.texture(:,:,i,day_min_idx:day_max_idx),4);
end

% save file
filename = 'texture_median.mat';
fprintf('Saving %s\n',filename);
save(fullfile(path,filename),'texture_median','-v7.3');

% close workers
delete(gcp('nocreate'));
toc