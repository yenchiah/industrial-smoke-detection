clear all;
addpath(genpath('libs'));
addpath(genpath('util'));
show_has_label_only = 0;

% set data source
date_path = '2015-12-22.timemachine/';
dataset_path = 'crf26-12fps-1424x800/';
tile_path = '1/2/2.mp4';

% read images
target_dir = 'frames';
path = fullfile(target_dir,date_path,dataset_path,tile_path);
load(fullfile(path,'info.mat'));
data_mat = matfile(fullfile(path,'data.mat'));
label_mat = matfile(fullfile(path,'label.mat'),'Writable',true);
has_label_mat = matfile(fullfile(path,'has_label.mat'),'Writable',true);

% find frames that have labels
has_label = has_label_mat.has_label;
has_label_idx = find(has_label==1);

% label images
global t
t = 13000;
fig = figure(1);
set(fig,'KeyPressFcn',{@keyDownListenerLabelData,r_json.frames,data_mat,label_mat,has_label_mat,has_label_idx,show_has_label_only});