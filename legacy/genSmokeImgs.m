clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
select_box = 0;

t = [7000,5936,7543,6617,4406,9011,12929,4369,5969,4544,7111];

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read frames
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
data_median_mat = matfile(fullfile(path,'data_median_60.mat'));

% define mask
if(select_box == 1)
    t_ref = 5936;
    img = data_mat.data(:,:,:,t_ref);
    [bbox_row,bbox_col] = selectBound(img);
    save(fullfile(target_dir,'bbox.mat'),'bbox_row','bbox_col');
else
    load(fullfile(target_dir,'bbox.mat'));
end

% crop images
imgs = cell(size(t));
for i=1:numel(t)
    % crop an image and detect smoke
    imgs{i} = data_mat.data(bbox_row,bbox_col,:,t(i));
end

% visualize images
fig = figure(50);
img_cols = 4;
img_rows = 3;
fig_idx = 1;

I = imgs{fig_idx};
str = 'Background';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

I = imgs{fig_idx};
str = 'img';
math = '';
fig_idx = subplotSerial(I,img_rows,img_cols,fig_idx,'',str,math);

% print figure
print_dir = 'figs';
if ~exist(print_dir,'dir')
    mkdir(print_dir);
end
set(gcf,'PaperPositionMode','auto')
print(fig,fullfile(print_dir,'smoke'),'-dpng','-r0')