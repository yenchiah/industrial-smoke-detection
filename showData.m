clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
show_has_label_predict_only = 0;

% set data source
date_path = '2015-05-01.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read images
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
load(fullfile(path,'info.mat'));
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'));
label_predict_mat = matfile(fullfile(path,'label_predict.mat'));
has_label_predict_mat = matfile(fullfile(path,'has_label_predict.mat'));
data_median_mat = matfile(fullfile(path,'data_median_60.mat'));

% read mask
fprintf('Loading bbox.mat\n');
load(fullfile(target_dir,'bbox.mat'));

% find frames that have labels
has_label_predict = has_label_predict_mat.has_label_predict;
has_label_predict_idx = find(has_label_predict==1);

% label images
global t
t = 13000;
fig = figure(1);
set(fig,'KeyPressFcn',{@keyDownListenerShowData,r_json.frames,data_mat,label_mat,has_label_predict_mat,has_label_predict_idx,show_has_label_predict_only,label_predict_mat,data_median_mat,bbox_row,bbox_col});