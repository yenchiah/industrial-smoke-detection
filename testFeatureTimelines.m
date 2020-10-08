clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
use_gpu_array = false;

t_start = [4300,4660,5020,5380,5740,6100,6460,6820,7180,7540,7900,8260,8620,8980,9340,9700,10060,10420,10780,11140,11500,11860,12220,12580,12940,13300,13660];
t_end = [4660,5020,5380,5740,6100,6460,6820,7180,7540,7900,8260,8620,8980,9340,9700,10060,10420,10780,11140,11500,11860,12220,12580,12940,13300,13660,14020];

% t_start = [4300,5020,5740,6460,7180,7900,8620,9340,10060,10780,11500,12220,12940,13660];
% t_end = [5020,5740,6460,7180,7900,8620,9340,10060,10780,11500,12220,12940,13660,14380];

% t_start = 5740;
% t_end = 6460;

% set data source
date_path = '2015-05-03.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(path,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(path,'bbox.mat'));
end

% compute feature timeline
L = numel(t_start);
timelines = cell(L,1);
for i=1:L
    i
    % crop and scale images
    imgs = data_mat.data(bbox_row,bbox_col,:,t_start(i):t_end(i));
    imgs = imadjustRGB(imgs);
    imgs = imresize(imgs,[32 16]);
    imgs_size = size(imgs);
    % compute feature timeline
    imgs_flat = permute(imgs,[1 2 4 3]);
    imgs_flat = reshape(imgs_flat,imgs_size(1)*imgs_size(2),imgs_size(4),imgs_size(3));
    % save image
    timelines{i} = imgs_flat;
end

% visualize feature timeline
for i=1:L
    figure(i);
    imshow(timelines{i});
end