clear all;
addpath(genpath('libs'));
addpath(genpath('util'));

% set data source
date_path = '2015-05-02.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read ground truth and responses
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
load(fullfile(path,'label.mat'));
load(fullfile(path,'feature.mat'));

% read mask
load(fullfile(path,'bbox.mat'));

% parameters
[day_min_idx,day_max_idx] = getDayIdx();

% count the number of smoke pixels in each images
sum_smoke_pixel = sum(reshape(label(bbox_row,bbox_col,:,:),[],size(label,4)));

% rescale all features between 0 and 1 and apply smoothing
fields = fieldnames(feature);
for i=1:length(fields)
    vec = feature.(fields{i});
    vec = vec - min(vec(day_min_idx:day_max_idx));
    vec = vec/max(abs(vec(day_min_idx:day_max_idx)));
    feature.(fields{i}) = filter1D(vec,2);
end

% plot ground truth and features
img_cols = 1;
img_rows = 3;
figure(98)

subplot(img_rows,img_cols,1)
bar(sum_smoke_pixel,'r')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title(['Distribution of Smoke ( ',date_path,dataset_path,tile_path,' )'])

subplot(img_rows,img_cols,2)
plot(feature.img_s,'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Sum of S channel of HSV')

subplot(img_rows,img_cols,3)
plot(feature.img_DoG,'b')
xlim([day_min_idx day_max_idx])
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
title('Sum of DoG')

tightfig;

% plot prediction
% figure(101)
% 
% subplot(img_rows,img_cols,1)
% bar(uint8(sum_smoke_pixel>0),'r')
% xlim([day_min_idx day_max_idx])
% set(gca,'YTickLabel',[]);
% set(gca,'YTick',[]);
% set(gca,'XTickLabel',[]);
% set(gca,'XTick',[]);
% title(['Distribution of Smoke ( ',date_path,dataset_path,tile_path,' )'])