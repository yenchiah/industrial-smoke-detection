clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;
use_gpu_array = false;

% t_start = [5756,7363,6437,4226,8831,12749,4928,7118,12386,4700];
% t_end = [6116,7723,6797,4586,9191,13109,5288,7478,12746,5060];

t_start = [4300,4660,5020,5380,5740,6100,6460,6820,7180,7540,7900,8260,8620,8980,9340,9700,10060,10420,10780,11140,11500,11860,12220,12580,12940,13300,13660];
t_end = [4660,5020,5380,5740,6100,6460,6820,7180,7540,7900,8260,8620,8980,9340,9700,10060,10420,10780,11140,11500,11860,12220,12580,12940,13300,13660,14020];

% t_start = [4300,5020,5740,6460,7180,7900,8620,9340,10060,10780,11500,12220,12940,13660];
% t_end = [5020,5740,6460,7180,7900,8620,9340,10060,10780,11500,12220,12940,13660,14380];

% t_start = 5756;
% t_end = 6116;

% t_start = 4300;
% t_end = 14000;

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

% compute and store feature images
L = numel(t_start);
imgs_min = cell(L,1);
imgs_max = cell(L,1);
imgs_median = cell(L,1);
for i=1:L
    i
    % crop images
    imgs = data_mat.data(bbox_row,bbox_col,:,t_start(i):t_end(i));
    imgs = imadjustRGB(imgs);
    % compute feature images
    img_min = min(imgs,[],4);
    img_max = max(imgs,[],4);
    img_median = median(imgs,4);
    % adjust images
%     img_min = imadjustRGB(img_min);
%     img_max = imadjustRGB(img_max);
%     img_median = imadjustRGB(img_median);
%     img_min = mat2gray(localnormalize(im2double(img_min),128,128));
%     img_max = mat2gray(localnormalize(im2double(img_max),128,128));
%     img_median = mat2gray(localnormalize(im2double(img_median),128,128));
	% save images
    imgs_min{i} = img_min;
    imgs_max{i} = img_max;
    imgs_median{i} = img_median;
end

% visualize feature images
fig = figure(52);
img_cols = L;
img_rows = 3;
fig_idx = 1;

for i=1:L
    I = imgs_min{i};
    str = num2str(i);
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
end

for i=1:L
    I = imgs_max{i};
    str = '';
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
end

for i=1:L
    I = imgs_median{i};
    str = [num2str(t_start(i)),'-',num2str(t_end(i))];
    math = '';
    fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);
end